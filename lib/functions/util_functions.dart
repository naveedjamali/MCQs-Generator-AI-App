import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mcqs_generator_ai_app/models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

///Contains utility functions
class UtilFunctions {
  ///The functions converts all the question to text form, and return the String containing text.
  ///[subject] of mcqs,
  ///[topic] of mcqs,
  ///[questionsList] list containing all the questions
  static String questionToText(
    String subject,
    String topic,
    List<Question> questionsList,
  ) {
    const answerOptions = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
    ];

    String mcqs =
        "Subject: $subject, Topic: $topic, total questions: ${questionsList.length}\n";
    String keys = "\n\nKeys of correct Answers\n\n";

    for (int i = 0; i < questionsList.length; i++) {
      String rawContent = questionsList[i].body?.content.toString() ?? '';
      String questionText = rawContent;
      String explanationText = '';

      if (rawContent.contains('[[EXPL]]')) {
        List<String> parts = rawContent.split('[[EXPL]]');
        questionText = parts[0].trim();
        explanationText = parts[1].trim();
      } else if (rawContent.contains('Explanation:')) {
        List<String> parts = rawContent.split('Explanation:');
        questionText = parts[0].trim();
        explanationText = parts[1].trim();
      }

      String q = "\nQ# ${i + 1}: $questionText";

      int totalAnswers = questionsList[i].answerOptions!.length;
      for (int j = 0; j < totalAnswers; j++) {
        q +=
            "\n\t${answerOptions[j]}: ${questionsList[i].answerOptions?[j].body?.content.toString()}";
        if (questionsList[i].answerOptions![j].isCorrect ?? false) {
          int qNum = i + 1;
          String keyLine = "$qNum: ${answerOptions[j]}";
          if (explanationText.isNotEmpty) {
            keyLine += " - $explanationText";
          }
          keys += "\n$keyLine";
        }
      }
      mcqs += q;
    }

    final allText = mcqs + keys;
    return allText;
  }

  ///Saves the mcqs in a file on local storage
  ///[subject] of mcqs,
  ///[topic] of mcqs,
  ///bool [saveAsJSON] to set flag for saving as JSON or Text
  static Future<void> saveMCQs(
      String subject,
      String topic,
      List<Question> questionsList,
      BuildContext? context,
      bool saveAsJSON) async {
    String fileName =
        '${topic}_subject_${subject}_questions_${questionsList.length}'
            .replaceAll(RegExp(r'[^\w\s-]'), '')
            .replaceAll(' ', '_')
            .toLowerCase();

    String extension = saveAsJSON ? 'json' : 'txt';
    String fullFileName = '$fileName.$extension';

    // Get output content
    String content;
    if (saveAsJSON) {
      for (Question q in questionsList) {
        q.topicId = topic;
        q.subjectId = subject;
      }
      content = jsonEncode(questionsList);
    } else {
      content = questionToText(subject, topic, questionsList);
    }

    try {
      // Convert content to bytes as required by some platforms
      Uint8List bytes = Uint8List.fromList(utf8.encode(content));

      // Use saveFile with bytes parameter as required by modern mobile platforms
      String? filePath = await FilePicker.saveFile(
        dialogTitle: 'Save MCQs',
        fileName: fullFileName,
        type: FileType.custom,
        allowedExtensions: [extension],
        bytes: bytes,
      );

      if (filePath == null) {
        // User canceled the picker
        return;
      }

      // Note: On some platforms, saveFile already handles writing if bytes are provided
      // but we ensure it's written if filePath is returned and differs from expected behavior
      final file = File(filePath);
      if (!(await file.exists()) || (await file.length()) == 0) {
        await file.writeAsBytes(bytes);
      }

      if (context != null && context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('File Saved'),
              icon: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 40,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Your MCQs have been saved successfully to:'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      filePath,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'))
              ],
            );
          },
        );
      }
    } catch (e) {
      // Fallback: try saving to application documents directory if everything else failed
      try {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String fallbackPath = '${appDocDir.path}/$fullFileName';
        final file = File(fallbackPath);
        await file.writeAsString(content);

        if (context != null && context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Save Error / Fallback'),
              content: Text(
                  'Could not save to selected location ($e). File saved to internal app storage instead:\n\n$fallbackPath'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                )
              ],
            ),
          );
        }
      } catch (e2) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fatal Error saving file: $e2'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  static String removeCommas(String original) {
    // Regular expression to remove commas at the beginning
    RegExp regex = RegExp(r'^,+');
    String newString = original.replaceAll(regex, '');
    return newString;
  }

  static Future<void> exportToPdf(
      String subject, String topic, List<Question> questionsList) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text("MCQs: $subject - $topic",
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            ...questionsList.asMap().entries.map((entry) {
              int index = entry.key;
              Question q = entry.value;

              String rawContent = q.body?.content ?? '';
              String questionText = rawContent;
              if (rawContent.contains('[[EXPL]]')) {
                questionText = rawContent.split('[[EXPL]]')[0].trim();
              } else if (rawContent.contains('Explanation:')) {
                questionText = rawContent.split('Explanation:')[0].trim();
              }

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("${index + 1}. $questionText",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  ...q.answerOptions!.asMap().entries.map((aEntry) {
                    int aIndex = aEntry.key;
                    AnswerOptions a = aEntry.value;
                    String label = String.fromCharCode(65 + aIndex);
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 20, bottom: 2),
                      child: pw.Text("$label) ${a.body?.content ?? ''}"),
                    );
                  }),
                  pw.SizedBox(height: 15),
                ],
              );
            }),
            pw.NewPage(),
            pw.Header(level: 1, text: "Answer Key & Explanations"),
            pw.SizedBox(height: 10),
            ...questionsList.asMap().entries.map((entry) {
              int index = entry.key;
              Question q = entry.value;

              String rawContent = q.body?.content ?? '';
              String explanationText = '';
              if (rawContent.contains('[[EXPL]]')) {
                explanationText = rawContent.split('[[EXPL]]')[1].trim();
              } else if (rawContent.contains('Explanation:')) {
                explanationText = rawContent.split('Explanation:')[1].trim();
              }

              int correctIndex =
                  q.answerOptions!.indexWhere((a) => a.isCorrect ?? false);
              String correctLabel = correctIndex != -1
                  ? String.fromCharCode(65 + correctIndex)
                  : "?";

              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: "Q${index + 1}: $correctLabel",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      if (explanationText.isNotEmpty)
                        pw.TextSpan(text: " - $explanationText"),
                    ],
                  ),
                ),
              );
            }).toList(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}

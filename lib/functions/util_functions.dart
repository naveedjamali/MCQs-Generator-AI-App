import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/models.dart';
import 'package:mcqs_generator_ai_app/widgets/save_json_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class UtilFunctions {
  /// Strips all comma characters from text to ensure CSV integrity
  static String removeCommas(String text) {
    return text.replaceAll(',', '');
  }

  /// Converts a List of Question objects into a plain text formatted string
  static String questionToText(
    String subjectID,
    String topicID,
    List<Question> questions,
  ) {
    const options = [
      '(A)',
      '(B)',
      '(C)',
      '(D)',
      '(E)',
      '(F)',
      '(G)',
      '(H)',
      '(I)',
      '(J)',
      '(K)',
    ];
    String mcqs =
        "Subject: $subjectID, Chapter: $topicID, Total Questions: ${questions.length}\n";
    String keys = "\n\nAnswer Key\n\n";

    for (int i = 0; i < questions.length; i++) {
      // Strip explanation tag for text export if present
      String rawBody = questions[i].body?.content.toString() ?? '';
      String questionBody = rawBody;
      if (rawBody.contains('[[EXPL]]')) {
        questionBody = rawBody.split('[[EXPL]]')[0].trim();
      } else if (rawBody.contains('Explanation:')) {
        questionBody = rawBody.split('Explanation:')[0].trim();
      }

      String questionText = "\nQ# ${i + 1}: $questionBody";

      if (questions[i].answerOptions != null) {
        int totalAnswers = questions[i].answerOptions!.length;
        for (int j = 0; j < totalAnswers; j++) {
          String optLabel = j < options.length ? options[j] : '(${j + 1})';
          questionText +=
              "\n\t$optLabel: ${questions[i].answerOptions?[j].body?.content.toString()}";
          if (questions[i].answerOptions![j].isCorrect ?? false) {
            keys +=
                "Q# ${i + 1}: $optLabel ${(i + 1) % 10 == 0 ? '' : '\n'}";
          }
        }
      }
      mcqs += questionText;
    }

    final completeText = mcqs + keys;
    return completeText;
  }

  /// Converts a List of Question objects into a JSON string
  static String questionsToJSON(
      List<Question> questionsList, String subject, String topic) {
    List<Map<String, dynamic>> jsonList = questionsList.map((q) {
      Map<String, dynamic> qMap = q.toJson();

      // Strip explanation from the JSON output for external compatibility
      String bodyContent = qMap['body']?['content'] ?? '';
      if (bodyContent.contains('[[EXPL]]')) {
        qMap['body']['content'] = bodyContent.split('[[EXPL]]')[0].trim();
      } else if (bodyContent.contains('Explanation:')) {
        qMap['body']['content'] = bodyContent.split('Explanation:')[0].trim();
      }

      qMap['topicId'] = topic;
      qMap['subjectId'] = subject;
      qMap.remove('rawCsv'); // Strip original AI response for external systems
      return qMap;
    }).toList();

    return jsonEncode(jsonList);
  }

  /// Saves the mcqs in a file on local storage
  static Future<void> saveMCQs(
      String subject,
      String topic,
      List<Question> questionsList,
      BuildContext? context,
      bool saveAsJSON) async {
    if (questionsList.isEmpty) {
      Get.snackbar(
        'No Questions',
        'There are no questions available to save.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    if (saveAsJSON) {
      if (context != null && context.mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => SaveJsonDialog(
            subject: subject,
            topic: topic,
            questionsList: questionsList,
          ),
        );
      }
      return;
    }

    // Saving as Text
    String fileName =
        '${topic}_subject_${subject}_questions_${questionsList.length}'
            .replaceAll(RegExp(r'[^\w\s-]'), '')
            .replaceAll(' ', '_')
            .toLowerCase();

    String extension = 'txt';
    String fullFileName = '$fileName.$extension';
    String content = questionToText(subject, topic, questionsList);

    try {
      Uint8List bytes = Uint8List.fromList(utf8.encode(content));

      String? filePath = await FilePicker.saveFile(
        dialogTitle: 'Save MCQs Text File',
        fileName: fullFileName,
        type: FileType.custom,
        allowedExtensions: [extension],
        bytes: bytes,
      );

      if (filePath == null) return;

      final file = File(filePath);
      if (!(await file.exists()) || (await file.length()) == 0) {
        if (!filePath.toLowerCase().endsWith('.$extension')) {
          filePath = '$filePath.$extension';
        }
        await File(filePath).writeAsBytes(bytes);
      }

      if (context != null && context.mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) {
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
                      filePath!,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
              actions: [
                FilledButton(
                  autofocus: true,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      try {
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String fallbackPath = '${appDocDir.path}/$fullFileName';
        final file = File(fallbackPath);
        await file.writeAsString(content);

        if (context != null && context.mounted) {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Saved to Documents'),
              content: SelectableText(fallbackPath),
              actions: [
                FilledButton(
                  autofocus: true,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (err) {
        Get.snackbar('Save Error', err.toString(),
            snackPosition: SnackPosition.TOP);
      }
    }
  }

  static Future<void> processSaveJsonAll(
      String subject,
      String topic,
      List<Question> questionsList,
      BuildContext? context) async {
    processSaveJsonRange(
        subject, topic, questionsList, 1, questionsList.length, context);
  }

  static Future<void> processSaveJsonRange(
      String subject,
      String topic,
      List<Question> sublist,
      int from,
      int to,
      BuildContext? context) async {
    String cleanTopic = topic
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_')
        .toLowerCase();
    String cleanSubject = subject
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_')
        .toLowerCase();

    String fileName =
        '${cleanTopic}_subject_${cleanSubject}_q_$from-$to.json';
    String content = questionsToJSON(sublist, subject, topic);
    Uint8List bytes = Uint8List.fromList(utf8.encode(content));

    try {
      String? filePath = await FilePicker.saveFile(
        dialogTitle: 'Save JSON Range ($from - $to)',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (filePath == null) return;

      final file = File(filePath);
      if (!(await file.exists()) || (await file.length()) == 0) {
        if (!filePath.toLowerCase().endsWith('.json')) {
          filePath = '$filePath.json';
        }
        await File(filePath).writeAsBytes(bytes);
      }

      if (context != null && context.mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('File Saved'),
            icon: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 40,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Your JSON file has been saved successfully to:'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    filePath!,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                ),
              ],
            ),
            actions: [
              FilledButton(
                autofocus: true,
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    }
  }

  static Future<void> processSaveJsonChunks(
      String subject,
      String topic,
      List<Question> questionsList,
      int chunkSize,
      BuildContext? context) async {
    if (questionsList.isEmpty) return;

    try {
      String? dirPath = await FilePicker.getDirectoryPath(
        dialogTitle: 'Choose folder to save JSON chunk files',
      );

      if (dirPath == null) {
        return; // User cancelled
      }

      int total = questionsList.length;
      List<String> createdFilePaths = [];

      for (int i = 0; i < total; i += chunkSize) {
        int from = i + 1;
        int to = (i + chunkSize > total) ? total : (i + chunkSize);
        List<Question> sublist = questionsList.sublist(i, to);

        String cleanTopic = topic
            .replaceAll(RegExp(r'[^\w\s-]'), '')
            .replaceAll(' ', '_')
            .toLowerCase();
        String cleanSubject = subject
            .replaceAll(RegExp(r'[^\w\s-]'), '')
            .replaceAll(' ', '_')
            .toLowerCase();

        String fileName =
            '${cleanTopic}_subject_${cleanSubject}_q_$from-$to.json';
        String filePath = '$dirPath/$fileName';

        String jsonContent = questionsToJSON(sublist, subject, topic);
        File file = File(filePath);
        await file.writeAsString(jsonContent);
        createdFilePaths.add(filePath);
      }

      if (context != null && context.mounted && createdFilePaths.isNotEmpty) {
        showDialog(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Chunk Files Saved'),
              icon: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 40,
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Successfully saved ${createdFilePaths.length} JSON chunk files to:'),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 180),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: createdFilePaths.length,
                        itemBuilder: (ctx, idx) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: SelectableText(
                            createdFilePaths[idx],
                            style: const TextStyle(
                                fontSize: 11, color: Colors.blueGrey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                FilledButton(
                  autofocus: true,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error Saving Chunks',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  /// Alias for printMCQs
  static Future<void> exportToPdf(
          String subject, String topic, List<Question> questions) =>
      printMCQs(subject, topic, questions);

  /// Generates a PDF document for printing
  static Future<void> printMCQs(
      String subject, String topic, List<Question> questions) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subject: $subject',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Topic: $topic',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            ...questions.asMap().entries.map((entry) {
              int index = entry.key;
              Question q = entry.value;

              String rawBody = q.body?.content ?? '';
              String questionBody = rawBody;
              if (rawBody.contains('[[EXPL]]')) {
                questionBody = rawBody.split('[[EXPL]]')[0].trim();
              } else if (rawBody.contains('Explanation:')) {
                questionBody = rawBody.split('Explanation:')[0].trim();
              }

              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 12),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Q${index + 1}: $questionBody',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    pw.SizedBox(height: 4),
                    if (q.answerOptions != null)
                      ...q.answerOptions!.asMap().entries.map((optEntry) {
                        int optIndex = optEntry.key;
                        AnswerOptions opt = optEntry.value;
                        String optLabel =
                            String.fromCharCode(65 + optIndex); // A, B, C...
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 12, top: 2),
                          child: pw.Text(
                            '($optLabel) ${opt.body?.content ?? ''}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        );
                      }),
                  ],
                ),
              );
            }),
            pw.Divider(),
            pw.SizedBox(height: 12),
            pw.Text('ANSWER KEY & EXPLANATIONS',
                style: pw.TextStyle(
                    fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            ...questions.asMap().entries.map((entry) {
              int index = entry.key;
              Question q = entry.value;

              String correctLabel = '';
              if (q.answerOptions != null) {
                for (int i = 0; i < q.answerOptions!.length; i++) {
                  if (q.answerOptions![i].isCorrect ?? false) {
                    correctLabel = String.fromCharCode(65 + i);
                    break;
                  }
                }
              }

              String explanationText = '';
              String rawBody = q.body?.content ?? '';
              if (rawBody.contains('[[EXPL]]')) {
                explanationText = rawBody.split('[[EXPL]]')[1].trim();
              } else if (rawBody.contains('Explanation:')) {
                explanationText = rawBody.split('Explanation:')[1].trim();
              }

              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.RichText(
                  text: pw.TextSpan(
                    style: const pw.TextStyle(fontSize: 9),
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
            }),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}

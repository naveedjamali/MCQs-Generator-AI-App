import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mcqs_generator_ai_app/models.dart';
import 'package:path_provider/path_provider.dart';

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
      String q = "\nQ# ${i + 1}: ${questionsList[i].body?.content.toString()}";

      int totalAnswers = questionsList[i].answerOptions!.length;
      for (int j = 0; j < totalAnswers; j++) {
        q +=
            "\n\t${answerOptions[j]}: ${questionsList[i].answerOptions?[j].body?.content.toString()}";
        if (questionsList[i].answerOptions![j].isCorrect ?? false) {
          int qNum = i + 1;
          keys += "$qNum: ${answerOptions[j]}, ${qNum % 10 == 0 ? '\n' : ''}";
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
}

import 'dart:convert';
import 'dart:io';

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
  ///bool [saveAsJson] to set flag for saving as JSON or Text
  static Function saveMCQs = (String subject,
      String topic,
      List<Question> questionsList,
      BuildContext context,
      bool saveAsJSON) async {
    String fileName =
        '$topic-subject_$subject-questions_${questionsList.length}.${saveAsJSON ? 'json' : 'txt'}'
            .toLowerCase();

    String? selectedDirectory = await FilePicker.getDirectoryPath(
      dialogTitle: 'Choose a location to save the file',
    );

    String filePath;

    if (selectedDirectory == null) {
      // User canceled directory picker, fallback to app documents
      Directory appDocDir = await getApplicationDocumentsDirectory();
      filePath = '${appDocDir.path}/$fileName';
    } else {
      filePath = '$selectedDirectory/$fileName';
    }

    File file = File(filePath);
    final directory = file.parent;
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }

    if (saveAsJSON) {
      for (Question q in questionsList) {
        q.topicId = topic;
        q.subjectId = subject;
      }
      await file.writeAsString(jsonEncode(questionsList));
    } else {
      await file.writeAsString(questionToText(subject, topic, questionsList));
    }

    if (!context.mounted) return;

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
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Note: You can open this file using your device\'s File Manager.',
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
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
  };

  static String removeCommas(String original) {
    // Regular expression to remove commas at the beginning
    RegExp regex = RegExp(r'^,+');
    String newString = original.replaceAll(regex, '');
    return newString;
  }
}

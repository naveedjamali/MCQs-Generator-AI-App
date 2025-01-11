import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mcqs_generator_ai_app/models.dart';
import 'package:url_launcher/url_launcher.dart';

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
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose a location to save the file',
    );
    if (selectedDirectory == null) {
//user canceled the picker
      return;
    }

// Create a file in the selected directory
    String filePath =
        '$selectedDirectory/subject_$subject-topic_$topic-questions_${questionsList.length}.${saveAsJSON ? 'json' : 'txt'}'
            .toLowerCase();

    File file = File(filePath);

    if (saveAsJSON) {
      for (Question q in questionsList) {
        q.topicId = topic;
        q.subjectId = subject;
      }
      await file.writeAsString(jsonEncode(questionsList));
    } else {
      await file.writeAsString(questionToText(subject, topic, questionsList));
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Examiter'),
          icon: const Icon(
            Icons.download_for_offline_sharp,
            color: Colors.green,
          ),
          content: Column(
            children: [
              const Text('File saved successfully'),
              TextButton(
                  onPressed: () {
                    Uri uri = Uri.file(filePath);
                    launchUrl(uri);
                    Navigator.of(context).pop();
                  },
                  child: Text(filePath)),
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

// jsonFileIo.writeJson('$subjectID-$topicID', jsonEncode(questions));
  };
}

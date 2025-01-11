import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mcqs_generator_ai_app/models.dart';
import 'package:url_launcher/url_launcher.dart';

class Save {
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
        "Subject: $subjectID, Chapter: $topicID, total questions: ${questions.length}\n";
    String keys = "\n\nKeys of correct Answers\n\n";

    for (int i = 0; i < questions.length; i++) {
      String questionText =
          "\nQ# ${i + 1}: ${questions[i].body?.content.toString()}";

      int totalAnswers = questions[i].answerOptions!.length;
      for (int j = 0; j < totalAnswers; j++) {
        questionText +=
            "\n\t${options[j]}: ${questions[i].answerOptions?[j].body?.content.toString()}";
        if (questions[i].answerOptions![j].isCorrect ?? false) {
          keys += "Q# ${i + 1}: ${options[j]} ${(i + 1) % 10 == 0 ? '' : '\n'}";
        }
      }
      mcqs += questionText;
    }

    final completeText = mcqs + keys;
    return completeText;
  }

  static Function saveMCQs = (String subjectID, String topicID,
      List<Question> questions, BuildContext context, bool saveAsJSON) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose a location to save the file',
    );
    if (selectedDirectory == null) {
//user canceled the picker
      return;
    }

// Create a file in the selected directory
    String filePath =
        '$selectedDirectory/subject_$subjectID-topic_$topicID-questions_${questions.length}.${saveAsJSON ? 'json' : 'txt'}'
            .toLowerCase();

    File file = File(filePath);

    if (saveAsJSON) {
      await file.writeAsString(jsonEncode(questions));
    } else {
      await file.writeAsString(questionToText(subjectID, topicID, questions));
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

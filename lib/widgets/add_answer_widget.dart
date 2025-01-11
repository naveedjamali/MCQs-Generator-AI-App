import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mcqs_generator_ai_app/models.dart';

class AddAnswerWidget extends StatefulWidget {
  const AddAnswerWidget({required this.question, super.key});

  final Question question;

  @override
  State<AddAnswerWidget> createState() => _AddAnswerWidgetState();
}

class _AddAnswerWidgetState extends State<AddAnswerWidget> {
  @override
  Widget build(BuildContext context) {
    TextEditingController newAnswerController = TextEditingController();
    return ListTile(
      title: ListTile(
        leading: const Text('Add new answer:'),
        title: TextField(
          controller: newAnswerController,
          textInputAction: TextInputAction.go,
          onSubmitted: (value) {
            if (newAnswerController.text.isNotEmpty) {
              AnswerOptions newAns = AnswerOptions();
              newAns.isCorrect = false;
              newAns.body =
                  Body(contentType: 'PLAIN', content: newAnswerController.text);
              setState(() {
                widget.question.answerOptions?.add(newAns);
              });
            }
            setState(() {
              log('Answer added');
            });
          },
        ),
      ),
    );
  }
}

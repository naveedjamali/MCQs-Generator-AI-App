import 'package:flutter/material.dart';

class DeleteAllQuestionsWidget extends StatelessWidget {
  const DeleteAllQuestionsWidget({
    super.key,
    required this.deleteQuestions,
  });

  final Function(BuildContext context) deleteQuestions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton.icon(
        onPressed: () => deleteQuestions(context),
        icon: const Icon(
          Icons.delete_outline,
          color: Colors.red,
          size: 20,
        ),
        label: const Text(
          'Delete All',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}

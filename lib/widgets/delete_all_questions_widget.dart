import 'package:flutter/material.dart';

class DeleteAllQuestionsWidget extends StatelessWidget {
  const DeleteAllQuestionsWidget({
    super.key,
    required this.deleteQuestions,
    this.isAppBar = false,
  });

  final bool isAppBar;
  final Function(BuildContext context) deleteQuestions;

  @override
  Widget build(BuildContext context) {
    final color = isAppBar ? Colors.red.shade200 : Colors.red;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: TextButton.icon(
        onPressed: () => deleteQuestions(context),
        icon: Icon(
          Icons.delete_outline,
          color: color,
          size: 18,
        ),
        label: Text(
          'Delete All',
          style: TextStyle(color: color, fontSize: 13),
        ),
      ),
    );
  }
}

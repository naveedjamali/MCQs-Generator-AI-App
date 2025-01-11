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
      padding: const EdgeInsets.all(8.0),
      child: MaterialButton(
        onPressed: () => deleteQuestions(context),
        child: const Row(
          children: [
            Icon(
              Icons.delete,
              color: Colors.red,
            ),
            Text(' Delete Questions'),
          ],
        ),
      ),
    );
  }
}

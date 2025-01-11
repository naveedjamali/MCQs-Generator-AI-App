import 'package:flutter/material.dart';

class OutputTextLabelWidget extends StatelessWidget {
  const OutputTextLabelWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
      "OUTPUT",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

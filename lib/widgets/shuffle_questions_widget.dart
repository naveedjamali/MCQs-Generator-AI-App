import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../get_controllers/home_controller.dart';

class ShuffleQuestionsWidget extends StatelessWidget {
  ShuffleQuestionsWidget({
    super.key,
  });

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton.icon(
        onPressed: () {
          controller.questions.shuffle();
        },
        icon: const Icon(Icons.shuffle, size: 20),
        label: const Text('Shuffle'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.blueGrey.shade700,
        ),
      ),
    );
  }
}

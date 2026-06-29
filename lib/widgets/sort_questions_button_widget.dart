import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/get_controllers/home_controller.dart';

class SortQuestionsButton extends StatelessWidget {
  SortQuestionsButton({
    super.key,
  });

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton.icon(
        onPressed: controller.sortByName,
        icon: const Icon(Icons.sort, size: 20),
        label: const Text('Sort'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.blueGrey.shade700,
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.all(4.0),
      child: MaterialButton(
          onPressed: controller.sortByName,
          child: const Row(
            children: [
              Icon(Icons.sort),
              Text(' Sort Questions'),
            ],
          )),
    );
  }
}

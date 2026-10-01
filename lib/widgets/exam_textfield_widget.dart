import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/get_controllers/home_controller.dart';

class ExamTextFieldWidget extends StatelessWidget {
  ExamTextFieldWidget({
    super.key,
  });

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: controller.examFocus,
      controller: controller.examController,
      onChanged: (text) => controller.updateExam(text),
      decoration: const InputDecoration(
        label: Text("Target Exam"),
        hintText: "e.g. MDCAT, ECAT, SAT, GRE",
        hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
      ),
    );
  }
}

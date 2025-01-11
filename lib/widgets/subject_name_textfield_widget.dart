import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/get_controllers/home_controller.dart';

class SubjectNameTextFieldWidget extends StatelessWidget {
  SubjectNameTextFieldWidget({
    super.key,
  });

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Flexible(
        flex: 1,
        child: Obx(
          () => TextField(
            focusNode: controller.subjectFocus,
            controller: controller.subjectController,
            canRequestFocus: true,
            onChanged: (text) => controller.updateSubject(text),
            decoration: const InputDecoration(
              label: Text("Subject Name"),
              hintText: "Subject Name",
              hintStyle:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
            ),
          ),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_controllers/home_controller.dart';

class ChapterNameTextFieldWidget extends StatelessWidget {
  ChapterNameTextFieldWidget({
    super.key,
  });

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Flexible(
        flex: 1,
        child: Obx(
          () => TextField(
            focusNode: controller.topicFocus,
            controller: controller.topicController,
            onChanged: (text) => controller.updateChapter(text),
            decoration: const InputDecoration(
              label: Text("Chapter Name"),
              hintText: "Chapter Name",
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

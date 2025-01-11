import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../get_controllers/home_controller.dart';

class QuestionsCountWidget extends StatelessWidget {
  QuestionsCountWidget({
    super.key,
  });

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Text(
          '${controller.questions.length} Questions',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../get_controllers/home_controller.dart';

class ShowQuestionsWithFourAnswersOnly extends StatelessWidget {
  ShowQuestionsWithFourAnswersOnly({
    super.key,
  });

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            const Text('Filter questions with not 4 answers '),
            Checkbox(
                value: controller.isFilteringFourAnswers.value,
                onChanged: (value) => controller.setFilteringFourOptions(value))
          ],
        ));
  }
}

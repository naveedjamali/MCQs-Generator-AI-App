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
    return Obx(() => SwitchListTile.adaptive(
          title: const Text(
            'Filter non-4 answer questions',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          value: controller.isFilteringFourAnswers.value,
          onChanged: (value) => controller.setFilteringFourOptions(value),
          activeTrackColor: Theme.of(context).colorScheme.primary,
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ));
  }
}

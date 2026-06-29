import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../get_controllers/home_controller.dart';

class ShowAnswers extends StatelessWidget {
  ShowAnswers({
    super.key,
  });

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => SwitchListTile.adaptive(
          title: const Text(
            'Show answers',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          value: controller.showAnswers.value,
          onChanged: (value) => controller.setShowAnswers(value),
          activeTrackColor: Theme.of(context).colorScheme.primary,
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ));
  }
}

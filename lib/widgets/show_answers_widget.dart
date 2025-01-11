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
    return Obx(() => Row(
          children: [
            const Text('Show answers'),
            Checkbox(
                value: controller.showAnswers.value,
                onChanged: (value) => controller.setShowAnswers(value))
          ],
        ));
  }
}

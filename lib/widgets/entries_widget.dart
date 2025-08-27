import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_controllers/home_controller.dart';

class EntriesWidget extends StatelessWidget {
  EntriesWidget({
    super.key,
  });

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
          itemCount: controller.useAiToGenerateEssay.value
              ? controller.entries.length
              : controller.essays.length,
          itemBuilder: (context, index) {
            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  subtitle: Text(
                    controller.useAiToGenerateEssay.value
                        ? controller.entries[index]
                        : controller.essays[index].substring(0, 50),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        scrollable: true,
                        content: SelectableText(
                            controller.useAiToGenerateEssay.value
                                ? controller.entries[index]
                                : controller.essays[index]),
                      ),
                    );
                  },
                ));
          },
        ));
  }
}

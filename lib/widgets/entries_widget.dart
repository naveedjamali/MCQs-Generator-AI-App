import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../get_controllers/home_controller.dart';

class EntriesWidget extends StatelessWidget {
  EntriesWidget({
    super.key,
  });

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDirectOrEssay = controller.useAiToGenerateEssay.value ||
          controller.useDirectMcqGeneration.value;
      final list = isDirectOrEssay ? controller.entries : controller.essays;

      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final entryText = list[index];
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: ListTile(
              subtitle: Text(
                isDirectOrEssay
                    ? entryText
                    : (entryText.length > 50
                        ? entryText.substring(0, 50)
                        : entryText),
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copy text',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: entryText));
                  Get.snackbar(
                    'Copied',
                    'History text copied to clipboard',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.green.shade600,
                    colorText: Colors.white,
                    icon: const Icon(Icons.check_circle_outline,
                        color: Colors.white),
                    margin: const EdgeInsets.all(12),
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    scrollable: true,
                    content: SelectableText(entryText),
                  ),
                );
              },
            ),
          );
        },
      );
    });
  }
}

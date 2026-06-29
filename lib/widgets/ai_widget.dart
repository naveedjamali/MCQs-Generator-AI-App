import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/get_controllers/home_controller.dart';

class AiWidget extends StatelessWidget {
  AiWidget({super.key});

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isKeyboardOpen = viewInsets.bottom > 0;
    final maxHeight =
        MediaQuery.of(context).size.height * (isKeyboardOpen ? 0.2 : 0.4);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() => ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: TextField(
                focusNode: controller.inputFocusNode,
                textInputAction: controller.isManualEssayMode.value
                    ? TextInputAction.newline
                    : TextInputAction.send,
                onSubmitted: (value) {
                  if (!controller.isManualEssayMode.value) {
                    _handleSubmission(context);
                  }
                },
                decoration: InputDecoration(
                  labelText: controller.isCovertCSVMode.value
                      ? 'Paste CSV content here'
                      : controller.isManualEssayMode.value
                          ? 'Write or Paste your Essay here'
                          : 'E.g. photosynthesis process, RAM vs ROM',
                  hintText: controller.isManualEssayMode.value
                      ? 'Paste full essay content...'
                      : 'Enter topic or CSV...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                maxLines: controller.isManualEssayMode.value
                    ? (isKeyboardOpen ? 4 : 6)
                    : 3,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                controller: controller.inputController,
              ),
            )),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () => controller.clearEntries(),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Clear History'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _handleSubmission(context),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate MCQs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleSubmission(BuildContext context) async {
    if (controller.inputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text first')),
      );
      return;
    }

    if (controller.isCovertCSVMode.value) {
      String text = controller.inputController.text;
      controller.addEntry(text);
      controller.setCSV(text);
      controller.addQuestions(context);
      controller.inputController.clear();
      controller.inputFocusNode.requestFocus();
    } else {
      String text = controller.inputController.text;
      controller.addEntry(text);
      controller.setGeneratingResponse(true);

      try {
        await controller.getAIDescription(text, context);
        controller.inputController.clear();
        controller.inputFocusNode.requestFocus();
      } catch (e) {
        // Errors are already handled inside getAIDescription
      }
    }
  }
}

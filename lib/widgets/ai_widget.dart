import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/get_controllers/home_controller.dart';

class AiWidget extends StatelessWidget {
  AiWidget({super.key});

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                focusNode: controller.inputFocusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (value) => _handleSubmission(context),
                decoration: InputDecoration(
                  labelText: controller.isCovertCSVMode.value
                      ? 'Paste CSV content here'
                      : 'E.g. photosynthesis process, RAM vs ROM',
                  hintText: 'Enter topic or CSV...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: () => _handleSubmission(context),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                maxLines: 3,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                controller: controller.inputController,
              ),
            ),
            IconButton(
              onPressed: () => controller.clearEntries(),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Clear History',
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

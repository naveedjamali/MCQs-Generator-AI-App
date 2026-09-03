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

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => controller.isPdfMode.value
              ? Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.blue.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.blue.shade100)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller.pdfPagesController,
                                decoration: InputDecoration(
                                  labelText: 'Target Pages',
                                  hintText: 'e.g. 1-5, 10',
                                  prefixIcon: const Icon(Icons.pages_outlined,
                                      color: Colors.blue),
                                  border: InputBorder.none,
                                  filled: false,
                                  isDense: true,
                                ),
                              ),
                            ),
                            const VerticalDivider(),
                            TextButton.icon(
                              onPressed: () =>
                                  controller.pickAndExtractFromPdf(context),
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('Pick File'),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue.shade800),
                            ),
                          ],
                        ),
                        const Divider(),
                        TextField(
                          controller: controller.pdfInstructionsController,
                          decoration: InputDecoration(
                            labelText: 'PDF Focus / Chapter Details',
                            hintText: 'e.g. focus on the third chapter only',
                            prefixIcon: const Icon(Icons.info_outline,
                                color: Colors.blue),
                            border: InputBorder.none,
                            filled: false,
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink()),
          Obx(() => (!controller.isCovertCSVMode.value &&
                  !controller.isPdfMode.value &&
                  !controller.isManualEssayMode.value)
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildCompactRadio('Essay First', false),
                      _buildCompactRadio('Direct MCQs', true),
                    ],
                  ),
                )
              : const SizedBox.shrink()),
          Obx(() => ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: TextField(
                  focusNode: controller.inputFocusNode,
                  textInputAction: (controller.isManualEssayMode.value ||
                          controller.isPdfMode.value)
                      ? TextInputAction.newline
                      : TextInputAction.send,
                  onSubmitted: (value) {
                    if (!controller.isManualEssayMode.value &&
                        !controller.isPdfMode.value) {
                      _handleSubmission(context);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: controller.isCovertCSVMode.value
                        ? 'Paste CSV content here'
                        : controller.isPdfMode.value
                            ? 'Extracted PDF Text (Editable)'
                            : controller.isManualEssayMode.value
                                ? 'Write or Paste your Essay here'
                                : 'E.g. photosynthesis process, RAM vs ROM',
                    hintText: controller.isCovertCSVMode.value
                        ? 'Paste CSV...'
                        : controller.isPdfMode.value
                            ? 'Extracted text will appear here after picking a file...'
                            : controller.isManualEssayMode.value
                                ? 'Paste full essay content...'
                                : 'Enter topic...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  maxLines: (controller.isManualEssayMode.value ||
                          controller.isPdfMode.value)
                      ? (isKeyboardOpen ? 4 : 6)
                      : 3,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  controller: controller.inputController,
                ),
              )),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!controller.isCovertCSVMode.value &&
                  !controller.isPdfMode.value) ...[
                IconButton(
                  onPressed: () => _showHistoryMenu(context),
                  icon: const Icon(Icons.history, color: Colors.blueGrey),
                  tooltip: 'History & Re-generate',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                IconButton(
                  onPressed: () => _handleSubmission(context, redo: true),
                  icon: const Icon(Icons.replay_outlined, color: Colors.blue),
                  tooltip: 'Redo last session',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                IconButton(
                  onPressed: () => controller.pickAndExtractFromImage(context),
                  icon: const Icon(Icons.camera_alt_outlined,
                      color: Colors.blueGrey),
                  tooltip: 'Extract from Image (OCR)',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ],
              TextButton(
                onPressed: () => controller.clearEntries(),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    minimumSize: const Size(40, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 8)),
                child: const Text('Clear', style: TextStyle(fontSize: 12)),
              ),
              ElevatedButton.icon(
                onPressed: () => _handleSubmission(context),
                icon: const Icon(Icons.auto_awesome, size: 14),
                label: const Text('Generate', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  elevation: 0,
                  minimumSize: const Size(80, 36),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactRadio(String title, bool value) {
    return Obx(() => InkWell(
          onTap: () {
            if (value) {
              controller.saveDirectMcqState(true);
            } else {
              controller.saveAiEssayState(true);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<bool>(
                  value: value,
                  groupValue: controller.useDirectMcqGeneration.value,
                  onChanged: (val) {
                    if (value) {
                      controller.saveDirectMcqState(true);
                    } else {
                      controller.saveAiEssayState(true);
                    }
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                Text(title, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ));
  }

  void _showHistoryMenu(BuildContext context) {
    final history = controller.entries;
    if (history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No generation history yet')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Select History to Re-generate',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: history.length,
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.history),
                title: Text(history[index],
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.pop(context);
                  controller.inputController.text = history[index];
                  _handleSubmission(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmission(BuildContext context, {bool redo = false}) async {
    final isSmallScreen = MediaQuery.of(context).size.width <= 600;
    String text = controller.inputController.text;
    if (redo) {
      if (controller.entries.isNotEmpty) {
        text = controller.entries.first;
        controller.inputController.text = text;
      } else if (controller.essays.isNotEmpty) {
        text = controller.essays.first;
        controller.inputController.text = text;
      }
    }

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text first')),
      );
      return;
    }

    if (isSmallScreen) {
      Navigator.pop(context); // Close the dialog on mobile
    }

    if (controller.isCovertCSVMode.value) {
      controller.addEntry(text);
      controller.setCSV(text);
      controller.addQuestions(context);
      controller.inputController.clear();
      controller.inputFocusNode.requestFocus();
    } else {
      controller.addEntry(text);

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

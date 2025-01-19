import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/get_controllers/home_controller.dart';

class AiWidget extends StatelessWidget {
  AiWidget({super.key});

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                controller.clearEntries();
              },
              label: const Text('Clear topics'),
              icon: const Icon(
                Icons.clear,
                color: Colors.red,
              ),
            )
          ],
        ),
        SizedBox(
          child: Row(
            children: [
              Flexible(
                flex: 1,
                child: TextField(
                  focusNode: controller.inputFocusNode,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (value) async {
                    if (controller.inputController.text.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          title: Text('input text first'),
                        ),
                      );
                    } else {
                      String text = controller.inputController.text;
                      controller.addEntry(text);
                      controller.setGeneratingResponse(true);

                      try {
                        controller.getAIDescription(text, context);
                        controller.getAIDescription(text, context);

                        controller.setInputControllerText('');
                        controller.inputFocusNode.requestFocus();
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final errorTextController = TextEditingController();

                            return AlertDialog(
                              title: const Text('Error'),
                              content: Column(
                                children: [
                                  Text(e.toString()),
                                  const Text(
                                      'Re-write your query and try again'),
                                  TextFormField(
                                    controller: errorTextController,
                                  ),
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {}, child: const Text('Go'))
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter your topic and press Enter',
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  controller: controller.inputController,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

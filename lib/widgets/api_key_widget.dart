import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/get_controllers/home_controller.dart';

class ApiKeyWidget extends StatelessWidget {
  const ApiKeyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();
    return Obx(() => Column(
          children: [
            const Text('Gemini API Key'),
            Text(controller.API_KEY.value),
            ElevatedButton(
                onPressed: () {
                  final TextEditingController apiKeyController =
                      TextEditingController();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Enter Gemini API Key'),
                      content: Column(
                        children: [
                          TextField(
                            controller: apiKeyController,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel')),
                        TextButton(
                          onPressed: () async {
                            bool saved = await controller
                                .saveApiKeyInStorage(apiKeyController.text);
                            if (saved) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('API Key Saved'),
                                ),
                              );
                              Navigator.of(context).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('error in saving API Key'),
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Save'),
                        )
                      ],
                    ),
                  );
                },
                child: const Text('Update API Key'))
          ],
        ));
  }
}

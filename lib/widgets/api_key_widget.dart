import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/get_controllers/home_controller.dart';

class ApiKeyWidget extends StatelessWidget {
  const ApiKeyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();
    return Obx(() => ListTile(
          title: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Gemini API Key'),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              controller.apiKey.value.isEmpty
                  ? 'No key set'
                  : controller.apiKey.value.length > 8
                      ? '${controller.apiKey.value.substring(0, 4)}...${controller.apiKey.value.substring(controller.apiKey.value.length - 4)}'
                      : '********',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
          trailing: ElevatedButton(
              onPressed: () {
                final TextEditingController apiKeyController =
                    TextEditingController(text: controller.apiKey.value);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Enter Gemini API Key'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: apiKeyController,
                          decoration: const InputDecoration(
                            hintText: 'Paste your API key here',
                          ),
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
                          if (!context.mounted) return;
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
              child: const Text('Update')),
        ));
  }
}

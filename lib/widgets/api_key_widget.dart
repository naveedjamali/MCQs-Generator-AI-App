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
              controller.API_KEY.value,
              style: const TextStyle(fontSize: 8),
            ),
          ),
          trailing: ElevatedButton(
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
              child: const Text('Update')),
        ));
  }
}

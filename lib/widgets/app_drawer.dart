import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_controllers/home_controller.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({
    required this.pickAndLoadQuestions,
    required this.setShowAnswers,
    required this.getShowAnswers,
    required this.searchController,
    required this.getIsSearchMode,
    required this.setSearchMode,
    required this.setFourAnswersFilter,
    required this.getFourAnswersFilter,
    super.key,
  });

  final void Function() pickAndLoadQuestions;
  final void Function(bool) setShowAnswers;
  final bool Function() getShowAnswers;
  final bool Function() getIsSearchMode;
  final void Function(bool) setSearchMode;
  final TextEditingController searchController;
  final void Function(bool) setFourAnswersFilter;
  final bool Function() getFourAnswersFilter;

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text('MCQs Generator AI APP')),
          ListTile(
            title: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Load questions from file'),
            ),
            subtitle: FilledButton(
              onPressed: widget.pickAndLoadQuestions,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Choose JSON File'),
              ),
            ),
          ),
          const ApiKeyWidget()
        ],
      ),
    );
  }
}

class ApiKeyWidget extends StatelessWidget {
  const ApiKeyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();
    return Obx(() => Column(
          children: [
            const Text('Gemini API Key'),
            Text(controller.API_KEY.value ?? 'KEY NOT FOUND'),
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

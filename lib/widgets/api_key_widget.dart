import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/get_controllers/home_controller.dart';

class ApiKeyWidget extends StatelessWidget {
  const ApiKeyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();
    return Obx(() {
      final apiKey = controller.apiKey.value;
      final hasKey = apiKey.trim().isNotEmpty;

      return ListTile(
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text('Gemini API Key',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            !hasKey
                ? 'No key set'
                : apiKey.length > 8
                    ? '${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}'
                    : '********',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasKey)
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copy API Key',
                onPressed: () => _copyApiKey(apiKey),
              ),
            ElevatedButton(
              onPressed: () => _showUpdateDialog(context, controller),
              child: const Text('Update'),
            ),
          ],
        ),
      );
    });
  }

  void _copyApiKey(String key) {
    if (key.trim().isEmpty) {
      Get.snackbar(
        'Empty Key',
        'No API Key set to copy',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: key.trim()));
    Get.snackbar(
      'Copied',
      'API Key copied to clipboard',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }

  void _showUpdateDialog(BuildContext context, AppController controller) {
    final TextEditingController apiKeyController =
        TextEditingController(text: controller.apiKey.value);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enter Gemini API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: apiKeyController,
              decoration: InputDecoration(
                hintText: 'Paste your API key here',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy current key',
                  onPressed: () => _copyApiKey(apiKeyController.text),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            autofocus: true,
            onPressed: () async {
              bool saved =
                  await controller.saveApiKeyInStorage(apiKeyController.text);
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
              if (saved) {
                Get.snackbar(
                  'Saved',
                  'API Key saved successfully',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.green.shade600,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(12),
                  duration: const Duration(seconds: 2),
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Failed to save API Key',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red.shade600,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(12),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

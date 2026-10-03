import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/functions/util_functions.dart';
import 'package:mcqs_generator_ai_app/models.dart';

enum JsonSaveMode { all, range, chunk }

class SaveJsonDialog extends StatefulWidget {
  final String subject;
  final String topic;
  final List<Question> questionsList;

  const SaveJsonDialog({
    super.key,
    required this.subject,
    required this.topic,
    required this.questionsList,
  });

  @override
  State<SaveJsonDialog> createState() => _SaveJsonDialogState();
}

class _SaveJsonDialogState extends State<SaveJsonDialog> {
  JsonSaveMode _mode = JsonSaveMode.all;
  late TextEditingController _fromController;
  late TextEditingController _toController;
  late TextEditingController _chunkSizeController;

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController(text: '1');
    _toController =
        TextEditingController(text: widget.questionsList.length.toString());
    _chunkSizeController = TextEditingController(text: '500');
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _chunkSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.questionsList.length;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.save, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Save JSON Options'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.quiz_outlined,
                      size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Total Questions Available: $total',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Mode 1: All
            RadioListTile<JsonSaveMode>(
              title: const Text('Save All Questions'),
              subtitle: Text('Save all $total questions in a single JSON file'),
              value: JsonSaveMode.all,
              groupValue: _mode,
              onChanged: (val) => setState(() => _mode = val!),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),

            // Mode 2: Range
            RadioListTile<JsonSaveMode>(
              title: const Text('Save Specific Question Range'),
              subtitle: const Text('e.g., questions 501 to 1000'),
              value: JsonSaveMode.range,
              groupValue: _mode,
              onChanged: (val) => setState(() => _mode = val!),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            if (_mode == JsonSaveMode.range)
              Padding(
                padding:
                    const EdgeInsets.only(left: 32.0, bottom: 8.0, top: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _fromController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'From Q#',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _toController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'To Q#',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Mode 3: Chunk Mode
            RadioListTile<JsonSaveMode>(
              title: const Text('Split into Chunks (Max Per File)'),
              subtitle: const Text('Set maximum questions per JSON file'),
              value: JsonSaveMode.chunk,
              groupValue: _mode,
              onChanged: (val) => setState(() => _mode = val!),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            if (_mode == JsonSaveMode.chunk)
              Padding(
                padding:
                    const EdgeInsets.only(left: 32.0, bottom: 8.0, top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _chunkSizeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max questions per file',
                        hintText: 'e.g. 500',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 6),
                    _buildChunkPreview(total),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Save JSON'),
          onPressed: () => _onConfirmSave(context),
        ),
      ],
    );
  }

  Widget _buildChunkPreview(int total) {
    int chunkSize = int.tryParse(_chunkSizeController.text.trim()) ?? 500;
    if (chunkSize <= 0) chunkSize = 500;
    int numFiles = (total / chunkSize).ceil();
    if (numFiles <= 0) numFiles = 1;

    int firstEnd = chunkSize > total ? total : chunkSize;
    return Text(
      'Will create $numFiles file(s) (e.g., 1-$firstEnd, etc.)',
      style: TextStyle(
          fontSize: 11,
          color: Colors.blue.shade800,
          fontWeight: FontWeight.bold),
    );
  }

  void _onConfirmSave(BuildContext context) {
    final total = widget.questionsList.length;

    if (_mode == JsonSaveMode.all) {
      Navigator.pop(context);
      UtilFunctions.processSaveJsonAll(
        widget.subject,
        widget.topic,
        widget.questionsList,
        context,
      );
    } else if (_mode == JsonSaveMode.range) {
      int? from = int.tryParse(_fromController.text.trim());
      int? to = int.tryParse(_toController.text.trim());

      if (from == null || to == null || from < 1 || to > total || from > to) {
        Get.snackbar(
          'Invalid Range',
          'Please enter a valid question range between 1 and $total',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        return;
      }

      Navigator.pop(context);
      List<Question> sublist = widget.questionsList.sublist(from - 1, to);
      UtilFunctions.processSaveJsonRange(
        widget.subject,
        widget.topic,
        sublist,
        from,
        to,
        context,
      );
    } else if (_mode == JsonSaveMode.chunk) {
      int? chunkSize = int.tryParse(_chunkSizeController.text.trim());
      if (chunkSize == null || chunkSize < 1) {
        Get.snackbar(
          'Invalid Chunk Size',
          'Please enter a valid chunk size greater than 0',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        return;
      }

      Navigator.pop(context);
      UtilFunctions.processSaveJsonChunks(
        widget.subject,
        widget.topic,
        widget.questionsList,
        chunkSize,
        context,
      );
    }
  }
}

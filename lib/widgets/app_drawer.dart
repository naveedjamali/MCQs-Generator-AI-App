import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/widgets/api_key_widget.dart';

import 'package:mcqs_generator_ai_app/widgets/chapter_name_textfield_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/show_answers_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/show_questions_with_four_answers_only_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/subject_name_textfield_widget.dart';

import '../functions/util_functions.dart';
import '../get_controllers/home_controller.dart';

class AppDrawer extends StatefulWidget {
  AppDrawer({
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

  final AppController controller = Get.find();
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
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.green),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Generation Settings',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  'Configure your MCQs',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Project Info",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      ChapterNameTextFieldWidget(),
                      const SizedBox(height: 12),
                      SubjectNameTextFieldWidget(),
                    ],
                  ),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Display Filters",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ShowAnswers(),
                ShowQuestionsWithFourAnswersOnly(),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Export & Actions",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  onTap: () {
                    UtilFunctions.saveMCQs(
                        widget.controller.subject.value,
                        widget.controller.topicID.value,
                        widget.controller.questions,
                        Get.context,
                        true);
                    Get.back();
                  },
                  leading: const Icon(Icons.save),
                  title: const Text('Save as JSON'),
                ),
                ListTile(
                  onTap: () {
                    UtilFunctions.saveMCQs(
                        widget.controller.subject.value,
                        widget.controller.topicID.value,
                        widget.controller.questions,
                        Get.context,
                        false);
                    Get.back();
                  },
                  leading: const Icon(Icons.save_as),
                  title: const Text('Save as TEXT'),
                ),
                ListTile(
                  onTap: () => copyQuestionsAsJSON(context),
                  leading: const Icon(Icons.copy),
                  title: const Text('Copy JSON'),
                ),
                ListTile(
                  onTap: () => copyQuestionsAsText(context),
                  leading: const Icon(Icons.copy_all),
                  title: const Text('Copy TEXT'),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Text('CSV Mode'),
                      const Spacer(),
                      Obx(() => Switch(
                            value: widget.controller.isCovertCSVMode.value,
                            onChanged: (value) =>
                                widget.controller.isCovertCSVMode.value = value,
                          )),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  title: FilledButton.icon(
                    onPressed: widget.pickAndLoadQuestions,
                    icon: const Icon(Icons.file_open),
                    label: const Text('Load JSON File'),
                  ),
                ),
                const Divider(),
                Obx(() => ListTile(
                      leading: const Icon(Icons.smart_toy_outlined),
                      title: const Text('AI Model'),
                      subtitle: Text(widget.controller.selectedModel.value),
                      trailing: const Icon(Icons.edit, size: 18),
                      onTap: () => _showModelSelectionDialog(context),
                    )),
                const ApiKeyWidget(),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Powered by: Effordea',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showModelSelectionDialog(BuildContext context) {
    final List<String> models = [
      'gemini-1.5-flash',
      'gemini-1.5-pro',
      'gemini-2.0-flash',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose AI Model'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: models
              .map((model) => Obx(() => RadioListTile<String>(
                    title: Text(model),
                    value: model,
                    groupValue: widget.controller.selectedModel.value,
                    onChanged: (value) async {
                      if (value != null) {
                        await widget.controller.saveModelToStorage(value);
                        Navigator.pop(context);
                      }
                    },
                  )))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void copyQuestionsAsJSON(BuildContext context) async {
    await Clipboard.setData(
        ClipboardData(text: jsonEncode(widget.controller.questions)));

    showQuestionsCopiedMessageOnScreen(context);
  }

  void copyQuestionsAsText(BuildContext context) async {
    await Clipboard.setData(ClipboardData(
        text: UtilFunctions.questionToText(widget.controller.subject.value,
            widget.controller.topicID.value, widget.controller.questions)));

    showQuestionsCopiedMessageOnScreen(context);
  }

  void showQuestionsCopiedMessageOnScreen(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      snackBarAnimationStyle: const AnimationStyle(
          duration: Duration(seconds: 1),
          curve: Curves.easeIn,
          reverseCurve: Curves.bounceIn,
          reverseDuration: Duration(seconds: 1)),
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
            '${widget.controller.questions.length} questions copied on the clipboard'),
        backgroundColor: Colors.green,
        padding: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        dismissDirection: DismissDirection.horizontal,
        showCloseIcon: true,
      ),
    );
  }
}

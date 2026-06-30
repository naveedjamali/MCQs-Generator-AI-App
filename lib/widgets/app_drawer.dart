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
    required this.showHistory,
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
  final void Function() showHistory;

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildModernHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildSectionTitle('Project Info'),
                _buildModernCard([
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        SubjectNameTextFieldWidget(),
                        const SizedBox(height: 12),
                        ChapterNameTextFieldWidget(),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSectionTitle('Display Filters'),
                _buildModernCard([
                  ShowAnswers(),
                  ShowQuestionsWithFourAnswersOnly(),
                ]),
                const SizedBox(height: 16),
                _buildSectionTitle('Export & Actions'),
                _buildModernCard([
                  _buildDrawerItem(
                    icon: Icons.save,
                    title: 'Save as JSON',
                    onTap: () {
                      UtilFunctions.saveMCQs(
                          widget.controller.subject.value,
                          widget.controller.topicID.value,
                          widget.controller.questions,
                          context,
                          true);
                      Get.back();
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.save_as,
                    title: 'Save as TEXT',
                    onTap: () {
                      UtilFunctions.saveMCQs(
                          widget.controller.subject.value,
                          widget.controller.topicID.value,
                          widget.controller.questions,
                          context,
                          false);
                      Get.back();
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.picture_as_pdf_outlined,
                    title: 'Export Print-Ready PDF',
                    onTap: () async {
                      widget.controller.setGeneratingResponse(true,
                          message: 'Generating Print-Ready PDF...');
                      try {
                        await UtilFunctions.exportToPdf(
                            widget.controller.subject.value,
                            widget.controller.topicID.value,
                            widget.controller.questions);
                      } finally {
                        widget.controller.setGeneratingResponse(false);
                        Get.back();
                      }
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.copy,
                    title: 'Copy JSON',
                    onTap: () => copyQuestionsAsJSON(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.copy_all,
                    title: 'Copy TEXT',
                    onTap: () => copyQuestionsAsText(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.history,
                    title: 'Generation History',
                    onTap: () {
                      Get.back();
                      widget.showHistory();
                    },
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSectionTitle('Customization'),
                _buildModernCard([
                  Obx(() => _buildDropdownItem<String>(
                        icon: Icons.language_outlined,
                        title: 'Target Language',
                        value: widget.controller.selectedLanguage.value,
                        items: [
                          'English',
                          'Urdu',
                          'Sindhi',
                          'Arabic',
                          'Spanish',
                          'French'
                        ],
                        onChanged: (val) =>
                            widget.controller.selectedLanguage.value = val!,
                      )),
                  Obx(() => _buildDropdownItem<String>(
                        icon: Icons.speed_outlined,
                        title: 'Difficulty Level',
                        value: widget.controller.selectedDifficulty.value,
                        items: ['Easy', 'Medium', 'Hard'],
                        onChanged: (val) =>
                            widget.controller.selectedDifficulty.value = val!,
                      )),
                ]),
                const SizedBox(height: 16),
                _buildSectionTitle('Content Import'),
                _buildModernCard([
                  _buildDrawerItem(
                    icon: Icons.picture_as_pdf,
                    title: 'Import from PDF',
                    onTap: () {
                      Get.back();
                      widget.controller.isPdfMode.value = true;
                      widget.controller.isCovertCSVMode.value = false;
                      widget.controller.isManualEssayMode.value = false;
                      widget.controller.pickAndExtractFromPdf(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.camera_alt_outlined,
                    title: 'Import from Image (OCR)',
                    onTap: () {
                      Get.back();
                      widget.controller.pickAndExtractFromImage(context);
                    },
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSectionTitle('Generation Modes'),
                _buildModernCard([
                  _buildSwitchTile(
                    'CSV Mode',
                    widget.controller.isCovertCSVMode,
                    (value) {
                      widget.controller.isCovertCSVMode.value = value;
                      if (value) {
                        widget.controller.isManualEssayMode.value = false;
                        widget.controller.isPdfMode.value = false;
                      }
                    },
                  ),
                  _buildSwitchTile(
                    'Manual Essay Mode',
                    widget.controller.isManualEssayMode,
                    (value) {
                      widget.controller.isManualEssayMode.value = value;
                      if (value) {
                        widget.controller.isCovertCSVMode.value = false;
                        widget.controller.isPdfMode.value = false;
                      }
                    },
                  ),
                  _buildSwitchTile(
                    'PDF Source Mode',
                    widget.controller.isPdfMode,
                    (value) {
                      widget.controller.isPdfMode.value = value;
                      if (value) {
                        widget.controller.isCovertCSVMode.value = false;
                        widget.controller.isManualEssayMode.value = false;
                      }
                    },
                  ),
                  Obx(() => !widget.controller.isManualEssayMode.value &&
                          !widget.controller.isCovertCSVMode.value &&
                          !widget.controller.isPdfMode.value
                      ? _buildSwitchTile(
                          'AI Write Essay First',
                          widget.controller.useAiToGenerateEssay,
                          (value) => widget
                              .controller.useAiToGenerateEssay.value = value,
                        )
                      : const SizedBox.shrink()),
                  ListTile(
                    title: FilledButton.icon(
                      onPressed: widget.pickAndLoadQuestions,
                      icon: const Icon(Icons.file_open, size: 20),
                      label: const Text('Load JSON File'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSectionTitle('AI Configuration'),
                _buildModernCard([
                  Obx(() => _buildDrawerItem(
                        icon: Icons.smart_toy_outlined,
                        title: 'AI Model',
                        subtitle: widget.controller.selectedModel.value,
                        onTap: () => _showModelSelectionDialog(context),
                      )),
                  _buildDrawerItem(
                    icon: Icons.description_outlined,
                    title: 'CSV Instructions',
                    onTap: () => _showInstructionsEditDialog(
                      context,
                      'CSV Instructions',
                      widget.controller.csvInstructions.value,
                      (val) =>
                          widget.controller.saveCsvInstructionsToStorage(val),
                    ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.article_outlined,
                    title: 'Essay Instructions',
                    onTap: () => _showInstructionsEditDialog(
                      context,
                      'Essay Instructions',
                      widget.controller.essayInstructions.value,
                      (val) =>
                          widget.controller.saveEssayInstructionsToStorage(val),
                    ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.restart_alt,
                    title: 'Reset AI Instructions',
                    onTap: () {
                      widget.controller.resetInstructions();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Instructions reset to default')),
                      );
                    },
                  ),
                  const ApiKeyWidget(),
                ]),
                const SizedBox(height: 16),
                _buildModernCard([
                  AboutListTile(
                    icon: const Icon(Icons.info_outline),
                    applicationName: 'MCQs Generator AI',
                    applicationVersion: '1.0.5',
                    applicationIcon: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/mcqs_generator_ai_app_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    aboutBoxChildren: const [
                      Text(
                          'A powerful AI-driven tool to generate MCQs from topics or essays.'),
                      SizedBox(height: 10),
                      Text(
                          'Developed for Govt: Boys Degree College Nawabshah.'),
                    ],
                  ),
                ]),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Powered by: Effordea',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 60, bottom: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.8)
            ],
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/mcqs_generator_ai_app_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'MCQs Generator AI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Advanced Generation Suite',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.green.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildModernCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.grey.shade50,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade700, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildSwitchTile(
    String title,
    RxBool value,
    Function(bool) onChanged,
  ) {
    return Obx(() => SwitchListTile.adaptive(
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          value: value.value,
          onChanged: onChanged,
          activeTrackColor: Colors.green.shade700,
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ));
  }

  Widget _buildDropdownItem<T>({
    required IconData icon,
    required String title,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade700, size: 22),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          DropdownButton<T>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            style: const TextStyle(
                fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
            items: items
                .map((item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(item.toString()),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
      dense: true,
    );
  }

  void _showInstructionsEditDialog(
    BuildContext context,
    String title,
    String currentInstructions,
    Future<bool> Function(String) onSave,
  ) {
    final TextEditingController instructionsController =
        TextEditingController(text: currentInstructions);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: instructionsController,
            maxLines: 15,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter instructions here...',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              bool saved = await onSave(instructionsController.text);
              if (saved && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title updated successfully')),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showModelSelectionDialog(BuildContext context) {
    final Map<String, String> modelMap = {
      'gemini-2.5-flash': 'Gemini 2.5 Flash',
      'gemini-3-flash-preview': 'Gemini 3 Flash (Preview)',
      'gemini-3.1-flash-lite-preview': 'Gemini 3.1 Flash Lite',
      'gemini-3.1-pro-preview': 'Gemini 3.1 Pro (Preview)',
      'gemini-3.5-flash': 'Gemini 3.5 Flash',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose AI Model'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: modelMap.entries
              .map((entry) => Obx(() => RadioListTile<String>(
                    title: Text(entry.value),
                    value: entry.key,
                    groupValue: widget.controller.selectedModel.value,
                    onChanged: (value) async {
                      if (value != null) {
                        await widget.controller.saveModelToStorage(value);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
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
    final questions = jsonEncode(widget.controller.questions);
    await Clipboard.setData(ClipboardData(text: questions));

    if (context.mounted) {
      showQuestionsCopiedMessageOnScreen(context);
    }
  }

  void copyQuestionsAsText(BuildContext context) async {
    final text = UtilFunctions.questionToText(widget.controller.subject.value,
        widget.controller.topicID.value, widget.controller.questions);
    await Clipboard.setData(ClipboardData(text: text));

    if (context.mounted) {
      showQuestionsCopiedMessageOnScreen(context);
    }
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

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/functions/util_functions.dart';
import 'package:mcqs_generator_ai_app/get_controllers/home_controller.dart';
import 'package:mcqs_generator_ai_app/models.dart';
import 'package:mcqs_generator_ai_app/widgets/ai_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/app_drawer.dart';
import 'package:mcqs_generator_ai_app/widgets/questions_list_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/search_history_panel_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/shuffle_questions_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/sort_questions_button_widget.dart';

import 'delete_all_questions_widget.dart';
import 'entries_widget.dart';

class Homepage extends StatelessWidget {
  final AppController controller = Get.find();

  Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width <= 600;

    return SafeArea(
      child: Scaffold(
        drawer: AppDrawer(
          pickAndLoadQuestions: () => pickAndLoadQuestions(context),
          getIsSearchMode: controller.getSearchMode,
          setSearchMode: controller.setSearchMode,
          searchController: controller.searchController,
          getShowAnswers: () => controller.showAnswers.value,
          setShowAnswers: (value) => controller.showAnswers.value = value,
          getFourAnswersFilter: () => controller.isFilteringFourAnswers.value,
          setFourAnswersFilter: (value) =>
              controller.isFilteringFourAnswers.value = value,
          showHistory: () => _showHistoryDialog(context),
        ),
        appBar: AppBar(
          title: Obx(
            () => controller.showSearchField.value
                ? TextField(
                    controller: controller.searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Filter questions...',
                      hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6)),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          controller.searchController.clear();
                          controller.queryText.value = '';
                        },
                      ),
                    ),
                    onChanged: (value) {
                      controller.queryText.value = value;
                      controller.setSearchMode(value.isNotEmpty);
                    },
                  )
                : Row(
                    children: [
                      if (!isSmallScreen) ...[
                        const Text(
                          "MCQs Gen",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        _buildAppBarTextField(
                          context: context,
                          label: 'Subject',
                          controller: controller.subjectController,
                          focusNode: controller.subjectFocus,
                          onChanged: (val) => controller.updateSubject(val),
                          width: 130,
                        ),
                        _buildAppBarTextField(
                          context: context,
                          label: 'Chapter/Topic',
                          controller: controller.topicController,
                          focusNode: controller.topicFocus,
                          onChanged: (val) => controller.updateChapter(val),
                          width: 130,
                        ),
                        _buildAppBarTextField(
                          context: context,
                          label: 'Exam',
                          controller: controller.examController,
                          focusNode: controller.examFocus,
                          onChanged: (val) => controller.updateExam(val),
                          width: 100,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Obx(() => Text(
                              '${controller.questions.length}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                      ),
                    ],
                  ),
          ),
          actions: [
            if (!isSmallScreen) ...[
              SortQuestionsButton(isAppBar: true),
              ShuffleQuestionsWidget(isAppBar: true),
              DeleteAllQuestionsWidget(
                deleteQuestions: (context) => deleteQuestions(context),
                isAppBar: true,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Show Answers',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                    Obx(() => Switch(
                          value: controller.showAnswers.value,
                          onChanged: (val) =>
                              controller.showAnswers.value = val,
                          activeThumbColor: Colors.white,
                        )),
                  ],
                ),
              ),
              Obx(() => _buildAppBarModelDropdown(context)),
              Obx(() => Tooltip(
                    message: controller.showSearchHistoryPanel.value
                        ? 'Hide Search History Panel'
                        : 'Show Search History Panel',
                    child: IconButton(
                      icon: Icon(
                        controller.showSearchHistoryPanel.value
                            ? Icons.history_toggle_off
                            : Icons.history,
                        color: controller.showSearchHistoryPanel.value
                            ? Colors.amber.shade300
                            : Colors.white,
                      ),
                      onPressed: () => controller.toggleSearchHistoryPanel(),
                    ),
                  )),
            ],
            Obx(() => IconButton(
                  icon: Icon(
                    controller.showSearchField.value
                        ? Icons.close
                        : Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    controller.showSearchField.toggle();
                    if (!controller.showSearchField.value) {
                      controller.searchController.clear();
                      controller.queryText.value = '';
                      controller.setSearchMode(false);
                    }
                  },
                )),
          ],
        ),
        floatingActionButton: isSmallScreen
            ? FloatingActionButton.extended(
                onPressed: () => _showGenerationDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Generate MCQs'),
              )
            : null,
        body: Column(
          children: [
            Obx(() => controller.generatingResponse.value
                ? LinearProgressIndicator(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary),
                  )
                : const SizedBox(height: 4)),
            // Controls (Mobile Only)
            if (isSmallScreen)
              Material(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SortQuestionsButton(),
                        ShuffleQuestionsWidget(),
                        DeleteAllQuestionsWidget(
                          deleteQuestions: (context) =>
                              deleteQuestions(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Main Content & Right Search History Panel
            Expanded(
              child: Row(
                children: [
                  // Left / Main Questions & Prompt Area
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: QuestionsListWidget(),
                        ),
                        if (!isSmallScreen)
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: AiWidget(),
                          ),
                      ],
                    ),
                  ),
                  // Right Panel (Desktop / Web only - Collapsible)
                  Obx(() =>
                      (controller.showSearchHistoryPanel.value && !isSmallScreen)
                          ? SearchHistoryPanelWidget()
                          : const SizedBox.shrink()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required ValueChanged<String> onChanged,
    required double width,
  }) {
    return Container(
      width: width,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 10,
              fontWeight: FontWeight.bold),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarModelDropdown(BuildContext context) {
    final Map<String, String> modelMap = {
      'gemini-2.5-flash': 'Gemini 2.5 Flash',
      'gemini-3-flash-preview': 'Gemini 3 Flash',
      'gemini-3.1-flash-lite-preview': 'Gemini 3.1 Flash Lite',
      'gemini-3.1-pro-preview': 'Gemini 3.1 Pro',
      'gemini-3.5-flash': 'Gemini 3.5 Flash',
    };

    final currentModel = controller.selectedModel.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: modelMap.containsKey(currentModel)
                ? currentModel
                : modelMap.keys.first,
            icon: const Icon(Icons.smart_toy_outlined,
                color: Colors.white, size: 18),
            dropdownColor: Theme.of(context).colorScheme.surface,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            items: modelMap.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: const TextStyle(color: Colors.black, fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                controller.saveModelToStorage(val);
              }
            },
          ),
        ),
      ),
    );
  }

  void _showGenerationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Generation Console',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              AiWidget(),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generation History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: EntriesWidget(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearEntries();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void showQuestionsCopiedMessageOnScreen(BuildContext context) {
    Get.snackbar(
      'Copied',
      '${controller.questions.length} questions copied to clipboard',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.copy_all, color: Colors.white),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }

  void copyQuestionsAsJSON(BuildContext context) async {
    final questions = UtilFunctions.questionsToJSON(controller.questions,
        controller.subject.value, controller.topicID.value);
    await Clipboard.setData(ClipboardData(text: questions));

    if (context.mounted) {
      showQuestionsCopiedMessageOnScreen(context);
    }
  }

  void copyQuestionsAsText(BuildContext context) async {
    final text = UtilFunctions.questionToText(controller.subject.value,
        controller.topicID.value, controller.questions);
    await Clipboard.setData(ClipboardData(text: text));

    if (context.mounted) {
      showQuestionsCopiedMessageOnScreen(context);
    }
  }

  void deleteQuestions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          icon: const Icon(
            Icons.warning,
            color: Colors.red,
          ),
          content: Text(
              'Do you want to remove all the ${controller.questions.length} questions from the list?'),
          title: const Text('Warning'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('No')),
            FilledButton(
                autofocus: true,
                style: ButtonStyle(
                  foregroundColor: WidgetStateColor.resolveWith(
                    (states) {
                      return Colors.white;
                    },
                  ),
                  backgroundColor: WidgetStateColor.resolveWith(
                    (states) {
                      return Colors.red;
                    },
                  ),
                ),
                onPressed: () {
                  controller.questions.clear();
                  Navigator.of(context).pop();
                  controller.inputFocusNode.requestFocus();
                },
                child: const Text(
                  'Yes',
                ))
          ],
        );
      },
    ).then((_) {
      controller.inputFocusNode.requestFocus();
    });
  }

  void pickAndLoadQuestions(BuildContext context) async {
    try {
      // Open the file picker
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        // Read the selected file
        File file = File(result.files.single.path!);
        String content = await file.readAsString();

        // Parse the JSON content
        final List<dynamic> data = jsonDecode(content);
        List<Question> loadedQuestions =
            data.map((item) => Question.fromJson(item)).toList();
        if (loadedQuestions.isNotEmpty) {
          Question firstQuestion = loadedQuestions[0];
          controller.topicID.value = firstQuestion.topicId ?? "";
          controller.subject.value = firstQuestion.subjectId ?? "";

          controller.subjectController.text = firstQuestion.subjectId ?? "";
          controller.topicController.text = firstQuestion.topicId ?? "";

          controller.saveSubjectToStorage(controller.subject.value);
          controller.saveTopicToStorage(controller.topicID.value);

          for (var q in loadedQuestions) {
            q.body?.content = UtilFunctions.removeCommas(q.body!.content!);
            controller.checkBodyForKatex(q.body);
            q.answerOptions?.forEach((a) {
              a.body?.content = UtilFunctions.removeCommas(a.body!.content!);
              controller.checkBodyForKatex(a.body);
            });
          }

          controller.questions.addAll(loadedQuestions);

          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: Text('${loadedQuestions.length} questions added'),
                actions: [
                  FilledButton(
                    autofocus: true,
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      controller.inputFocusNode.requestFocus();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          ).then((_) {
            controller.inputFocusNode.requestFocus();
          });
        } else {
          return;
        }
      } else {
        // User canceled the picker
        return;
      }
    } catch (e) {
      throw Exception("Failed to load questions: $e");
    }
  }

  Iterable<Widget> getAnswerList(List<Question> questions, int questionIndex) {
    return questions[questionIndex].answerOptions!.map<Widget>((answer) {
      return ListTile(
        leading: Container(
          width: 8,
          height: double.infinity,
          color: answer.isCorrect ?? false ? Colors.green : Colors.red[100],
        ),
        title: ListTile(
          leading: Switch(
              value: answer.isCorrect ?? false,
              onChanged: (value) {
                answer.isCorrect = value;
              }),
          title: Text(answer.body?.content ?? ''),
          trailing: IconButton(
            onPressed: () {
              questions[questionIndex].answerOptions?.remove(answer);
            },
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Colors.red,
            ),
          ),
        ),
      );
    });
  }
}

bool validateAllFieldsAreFilled(List<String> items) {
  for (int i = 0; i < items.length; i++) {
    if (items[i].isEmpty) {
      return false;
    }
  }
  return true;
}

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
import 'package:mcqs_generator_ai_app/widgets/questions_count_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/questions_list_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/shuffle_questions_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/sort_questions_button_widget.dart';

import 'delete_all_questions_widget.dart';
import 'entries_widget.dart';
import 'generating_questions_progress_indicator_widget.dart';

class Homepage extends StatelessWidget {
  final AppController controller = Get.find();

  Homepage({super.key});

  @override
  Widget build(BuildContext context) {
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
          title: Obx(() => controller.showSearchField.value
              ? TextField(
                  controller: controller.searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Filter questions...',
                    hintStyle:
                        TextStyle(color: Colors.white.withValues(alpha: 0.6)),
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
                    const Text(
                      "MCQs Gen",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${controller.questions.length}',
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )),
          actions: [
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
            GeneratingQuestionsProgressIndicator(),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Controls
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
                // Questions List
                Expanded(
                  child: QuestionsListWidget(),
                ),
                // Prompt Input at the bottom
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
            Obx(() => controller.generatingResponse.value
                ? Container(
                    color: Colors.black.withValues(alpha: 0.4),
                    child: Center(
                      child: Card(
                        margin: const EdgeInsets.all(32),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 20),
                              Text(
                                controller.loadingMessage.value,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Please wait a moment...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
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
    ScaffoldMessenger.of(context).showSnackBar(
      snackBarAnimationStyle: const AnimationStyle(
          duration: Duration(seconds: 1),
          curve: Curves.easeIn,
          reverseCurve: Curves.bounceIn,
          reverseDuration: Duration(seconds: 1)),
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
            '${controller.questions.length} questions copied on the clipboard'),
        backgroundColor: Colors.green,
        padding: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        dismissDirection: DismissDirection.horizontal,
        showCloseIcon: true,
      ),
    );
  }

  void copyQuestionsAsJSON(BuildContext context) async {
    final questions = jsonEncode(controller.questions);
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
            FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('No')),
            FilledButton(
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
                },
                child: const Text(
                  'Yes',
                ))
          ],
        );
      },
    );
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
            builder: (context) {
              return AlertDialog(
                title: Text('${loadedQuestions.length} questions added'),
              );
            },
          );
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

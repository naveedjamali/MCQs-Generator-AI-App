import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/functions/util_functions.dart';
import 'package:mcqs_generator_ai_app/get_controllers/home_controller.dart';
import 'package:mcqs_generator_ai_app/models.dart';
import 'package:mcqs_generator_ai_app/widgets/ai_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/app_drawer.dart';
import 'package:mcqs_generator_ai_app/widgets/chapter_name_textfield_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/copy_button_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/output_text_label_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/questions_count_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/questions_list_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/save_button_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/search_text_in_questions_form_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/show_answers_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/show_questions_with_four_answers_only_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/shuffle_questions_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/sort_questions_button_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/subject_name_textfield_widget.dart';

import 'boxed_widget.dart';
import 'delete_all_questions_widget.dart';
import 'entries_widget.dart';
import 'generating_questions_progress_indicator_widget.dart';

class Homepage extends StatelessWidget {
  final AppController controller = Get.find();

  Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQueryData query = MediaQuery.of(context);
    bool portrait = query.size.height > query.size.width;
    List<Widget> widgets = [
      Flexible(
        flex: 2,
        child: Padding(
          padding: !portrait
              ? const EdgeInsets.all(8.0)
              : const EdgeInsets.only(top: 8, left: 8, right: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!portrait)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ChapterNameTextFieldWidget(),
                      const SizedBox(
                        width: 16,
                      ),
                      SubjectNameTextFieldWidget(),
                    ],
                  ),
                ),
              Flexible(
                child: Row(
                  children: [
                    Flexible(
                      child: ShowAnswers(),
                    ),
                    ShowQuestionsWithFourAnswersOnly(),
                  ],
                ),
              ),
              SearchTextInQuestionsForm(),
              const SizedBox(
                height: 10,
              ),
              Boxed(
                child: AiWidget(),
              ),
              Flexible(
                flex: 1,
                child: EntriesWidget(),
              ),
            ],
          ),
        ),
      ),
      if (portrait)
        const Divider(
          color: Colors.black,
          height: 0,
          thickness: 1,
        ),
      if (!portrait)
        const VerticalDivider(
          width: 0,
          color: Colors.black,
          thickness: 1,
        ),
      Flexible(
        flex: 3,
        child: Padding(
          padding: !portrait
              ? const EdgeInsets.only(top: 8.0)
              : const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      const OutputTextLabelWidget(),
                      const SizedBox(
                        width: 20,
                      ),
                      QuestionsCountWidget(),
                      const SizedBox(
                        width: 16,
                      ),
                      SortQuestionsButton(),
                      ShuffleQuestionsWidget(),
                      DeleteAllQuestionsWidget(
                        deleteQuestions: (context) => deleteQuestions(context),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.black,
                  height: 0,
                  thickness: 1,
                ),
                QuestionsListWidget(),
              ],
            ),
          ),
        ),
      ),
    ];

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
          ),
          appBar: AppBar(
            backgroundColor: Colors.green,
            title: const Text(
              "MCQs Generator AI App",
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              GeneratingQuestionsProgressIndicator(),
              CopyButtonWidget(
                callBack: () => copyQuestionsAsText(context),
                label: 'Copy Text',
              ),
              CopyButtonWidget(
                callBack: () => copyQuestionsAsJSON(context),
                label: 'Copy JSON',
              ),
              if (!kIsWeb)
                SaveButtonWidget(
                    label: 'Save Text',
                    onPressed: () {
                      UtilFunctions.saveMCQs(
                          controller.subject.value,
                          controller.topicID.value,
                          controller.questions,
                          context,
                          false);
                    }),
              if (!kIsWeb)
                SaveButtonWidget(
                    label: 'Save JSON',
                    onPressed: () {
                      UtilFunctions.saveMCQs(
                          controller.subject.value,
                          controller.topicID.value,
                          controller.questions,
                          context,
                          true);
                    }),
            ],
          ),
          body: Column(
            children: [
              Flexible(
                flex: 1,
                child: portrait
                    ? Column(
                        children: widgets,
                      )
                    : Row(
                        children: widgets,
                      ),
              ),
            ],
          )),
    );
  }

  void showQuestionsCopiedMessageOnScreen(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      snackBarAnimationStyle: AnimationStyle(
          duration: const Duration(seconds: 1),
          curve: Curves.easeIn,
          reverseCurve: Curves.bounceIn,
          reverseDuration: const Duration(seconds: 1)),
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
            '${controller.questions.length} questions copied on the clipboard'),
        width: 600,
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
    await Clipboard.setData(
        ClipboardData(text: jsonEncode(controller.questions)));

    showQuestionsCopiedMessageOnScreen(context);
  }

  void copyQuestionsAsText(BuildContext context) async {
    await Clipboard.setData(ClipboardData(
        text: UtilFunctions.questionToText(controller.subject.value,
            controller.topicID.value, controller.questions)));

    showQuestionsCopiedMessageOnScreen(context);
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
      FilePickerResult? result = await FilePicker.platform.pickFiles(
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

          controller.questions.addAll(loadedQuestions);

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

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
import 'package:mcqs_generator_ai_app/widgets/question_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/save_button_widget.dart';
import 'package:mcqs_generator_ai_app/widgets/subject_name_textfield_widget.dart';

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
                      child: Row(
                        children: [
                          const Text('Show answers'),
                          Checkbox(
                              value: controller.showAnswers.value,
                              onChanged: (value) =>
                                  controller.showAnswers.value = value!)
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Text('Filter questions with not 4 answers '),
                        Checkbox(
                          value: controller.isFilteringFourAnswers.value,
                          onChanged: (value) =>
                              controller.isFilteringFourAnswers.value = value!,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: TextFormField(
                          // enabled: controller.searchBoxEnabled.value,
                          controller: controller.searchController,
                          decoration: const InputDecoration(
                              label: Text('filter questions with word',
                                  style: TextStyle(fontSize: 10))),
                        )),
                    IconButton(
                        onPressed: () {
                          if (!getSearchMode()) {
                            if (controller.searchController.text
                                .trim()
                                .isNotEmpty) {
                              setSearchMode(true);
                              controller.queryText.value =
                                  controller.searchController.text;
                            }
                          } else {
                            controller.searchController.text = '';
                            setSearchMode(false);
                          }
                        },
                        icon: getSearchMode()
                            ? const Icon(
                                Icons.close,
                                color: Colors.red,
                              )
                            : const Icon(
                                Icons.search,
                                color: Colors.grey,
                              )),
                  ],
                ),
              ),
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
                      const Text(
                        "OUTPUT",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        '${controller.questions.length} Questions',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: MaterialButton(
                            onPressed: _sortByName,
                            child: const Row(
                              children: [
                                Icon(Icons.sort),
                                Text(' Sort Questions'),
                              ],
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: MaterialButton(
                          onPressed: () {
                            controller.questions.shuffle();
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.shuffle),
                              Text(' Shuffle Questions'),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MaterialButton(
                          onPressed: () => deleteQuestions(context),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              Text(' Delete Questions'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.black,
                  height: 0,
                  thickness: 1,
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    //child: Text('Nothing to show'),
                    child: (controller.questions.isNotEmpty)
                        ? ListView.builder(
                            key: const PageStorageKey<String>('page'),
                            itemBuilder: (context, questionIndex) {
                              if (controller.isSearchMode.value) {
                                String questionBody = controller
                                        .questions[questionIndex].body?.content
                                        ?.toLowerCase() ??
                                    '';

                                bool condition = false;
                                if (controller.queryText.isEmpty) {
                                  condition = false;
                                } else {
                                  condition = questionBody.isNotEmpty &&
                                      controller.queryText.isNotEmpty &&
                                      questionBody.contains(
                                          controller.queryText.toLowerCase());
                                }

                                if (condition) {
                                  if (controller.isFilteringFourAnswers.value) {
                                    if (controller.questions[questionIndex]
                                                .answerOptions !=
                                            null &&
                                        controller.questions[questionIndex]
                                                .answerOptions?.length !=
                                            4) {
                                      return QuestionWidget(
                                        question:
                                            controller.questions[questionIndex],
                                        deleteQuestion:
                                            controller.deleteQuestion,
                                        index: questionIndex,
                                        showAnswers:
                                            controller.showAnswers.value,
                                        key: Key('$questionIndex'),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  } else {
                                    return QuestionWidget(
                                      question:
                                          controller.questions[questionIndex],
                                      deleteQuestion: controller.deleteQuestion,
                                      index: questionIndex,
                                      showAnswers: controller.showAnswers.value,
                                      key: Key('$questionIndex'),
                                    );
                                  }
                                } else {
                                  return Container();
                                }
                              } else {
                                if (controller.isFilteringFourAnswers.value) {
                                  if (controller.questions[questionIndex]
                                              .answerOptions !=
                                          null &&
                                      controller.questions[questionIndex]
                                              .answerOptions?.length !=
                                          4) {
                                    return QuestionWidget(
                                      question:
                                          controller.questions[questionIndex],
                                      deleteQuestion: controller.deleteQuestion,
                                      index: questionIndex,
                                      showAnswers: controller.showAnswers.value,
                                      key: Key('$questionIndex'),
                                    );
                                  } else {
                                    return Container();
                                  }
                                } else {
                                  return QuestionWidget(
                                    question:
                                        controller.questions[questionIndex],
                                    deleteQuestion: controller.deleteQuestion,
                                    index: questionIndex,
                                    showAnswers: controller.showAnswers.value,
                                    key: Key('$questionIndex'),
                                  );
                                }
                              }
                            },
                            itemCount: controller.questions.length,
                          )
                        : const Center(
                            child: Text(
                              'Your questions will be shown here!',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                  ),
                ),
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
            getIsSearchMode: getSearchMode,
            setSearchMode: setSearchMode,
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
              "MCQs Generator AI App | Govt. Boys Degree College Nawabshah ",
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              if (controller.generatingResponse.value)
                const Row(
                  children: [
                    Text(
                      'Generating MCQs with Google Gemini AI',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
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
                          controller.subject,
                          controller.topicID,
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

  void setSearchMode(bool value) {
    controller.isSearchMode.value = value;
  }

  bool getSearchMode() {
    return controller.isSearchMode.value;
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

  void _sortByName() {
    if (controller.isAscendingOrder.value) {
      controller.questions.sort((a, b) {
        if (a.body?.content == null && b.body?.content == null) {
          return 0;
        } else if (a.body?.content == null) {
          return 1;
        } else if (b.body?.content == null) {
          return -1;
        } else {
          return a.body!.content!.compareTo(b.body!.content!);
        }
      });
    } else {
      controller.questions.sort((a, b) {
        if (a.body?.content == null && b.body?.content == null) {
          return 0;
        } else if (a.body?.content == null) {
          return -1;
        } else if (b.body?.content == null) {
          return 1;
        } else {
          return b.body!.content!.compareTo(a.body!.content!);
        }
      });
    }
    controller.isAscendingOrder.value = controller.isAscendingOrder.value;
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

class EntriesWidget extends StatelessWidget {
  EntriesWidget({
    super.key,
  });

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
          itemCount: controller.entries.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: SelectableText(
                controller.entries[index],
              ),
            );
          },
        ));
  }
}

class Boxed extends StatelessWidget {
  const Boxed({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: Colors.grey, width: 1, style: BorderStyle.solid)),
      child: child,
    );
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

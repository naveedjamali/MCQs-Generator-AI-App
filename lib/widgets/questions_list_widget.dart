import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/get_controllers/home_controller.dart';
import 'package:mcqs_generator_ai_app/widgets/question_widget.dart';

class QuestionsListWidget extends StatelessWidget {
  QuestionsListWidget({
    super.key,
  });

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        bool isFilteringFourAnswers = controller.isFilteringFourAnswers.value;
        bool searchMode = controller.isSearchMode.value;
        bool showAnswers = controller.showAnswers.value;
        bool condition = false;

        return Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: (controller.questions.isNotEmpty)
                ? ListView.builder(
                    key: const PageStorageKey<String>('page'),
                    itemBuilder: (context, questionIndex) {
                      if (searchMode) {
                        String questionBody = controller
                                .questions[questionIndex].body?.content
                                ?.toLowerCase() ??
                            '';

                        if (controller.queryText.isEmpty) {
                          condition = false;
                        } else {
                          condition = controller.queryText.isNotEmpty &&
                              questionBody
                                  .contains(controller.queryText.toLowerCase());
                        }

                        if (condition) {
                          if (isFilteringFourAnswers) {
                            if (controller.questions[questionIndex]
                                        .answerOptions !=
                                    null &&
                                controller.questions[questionIndex]
                                        .answerOptions?.length !=
                                    4) {
                              return QuestionWidget(
                                question: controller.questions[questionIndex],
                                deleteQuestion: controller.deleteQuestion,
                                index: questionIndex,
                                showAnswers: showAnswers,
                                key: Key('$questionIndex'),
                              );
                            } else {
                              return Container();
                            }
                          } else {
                            return QuestionWidget(
                              question: controller.questions[questionIndex],
                              deleteQuestion: controller.deleteQuestion,
                              index: questionIndex,
                              showAnswers: showAnswers,
                              key: Key('$questionIndex'),
                            );
                          }
                        } else {
                          return Container();
                        }
                      } else {
                        if (isFilteringFourAnswers) {
                          if (controller
                                      .questions[questionIndex].answerOptions !=
                                  null &&
                              controller.questions[questionIndex].answerOptions
                                      ?.length !=
                                  4) {
                            return QuestionWidget(
                              question: controller.questions[questionIndex],
                              deleteQuestion: controller.deleteQuestion,
                              index: questionIndex,
                              showAnswers: showAnswers,
                              key: Key('$questionIndex'),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return QuestionWidget(
                            question: controller.questions[questionIndex],
                            deleteQuestion: controller.deleteQuestion,
                            index: questionIndex,
                            showAnswers: showAnswers,
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

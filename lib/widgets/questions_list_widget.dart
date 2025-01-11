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
    return Flexible(
        child: Obx(
      () => Padding(
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
                          questionBody
                              .contains(controller.queryText.toLowerCase());
                    }

                    if (condition) {
                      if (controller.isFilteringFourAnswers.value) {
                        if (controller.questions[questionIndex].answerOptions !=
                                null &&
                            controller.questions[questionIndex].answerOptions
                                    ?.length !=
                                4) {
                          return QuestionWidget(
                            question: controller.questions[questionIndex],
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
                          question: controller.questions[questionIndex],
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
                      if (controller.questions[questionIndex].answerOptions !=
                              null &&
                          controller.questions[questionIndex].answerOptions
                                  ?.length !=
                              4) {
                        return QuestionWidget(
                          question: controller.questions[questionIndex],
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
                        question: controller.questions[questionIndex],
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
      ),
    ));
  }
}

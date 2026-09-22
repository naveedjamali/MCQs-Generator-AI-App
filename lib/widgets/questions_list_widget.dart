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
        bool showAnswers = controller.showAnswers.value;
        final displayList = controller.filteredQuestions;
        final isTaskFiltered = controller.activeTaskFilterId.value.isNotEmpty;

        final activeTask = isTaskFiltered
            ? controller.searchTasks.firstWhereOrNull(
                (t) => t.id == controller.activeTaskFilterId.value)
            : null;

        return Column(
          children: [
            if (isTaskFiltered && activeTask != null)
              Container(
                margin: const EdgeInsets.all(8.0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.5),
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
                    Icon(Icons.filter_alt,
                        size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Filtered by task: "${activeTask.searchText}" (${displayList.length} questions)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => controller.activeTaskFilterId.value = '',
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Clear',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.close,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: displayList.isNotEmpty
                    ? ListView.builder(
                        key: const PageStorageKey<String>('page'),
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final question = displayList[index];
                          if (isFilteringFourAnswers) {
                            if (question.answerOptions != null &&
                                question.answerOptions?.length != 4) {
                              return QuestionWidget(
                                question: question,
                                deleteQuestion: controller.deleteQuestion,
                                index: index,
                                showAnswers: showAnswers,
                                key: Key('${question.hashCode}_$index'),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          } else {
                            return QuestionWidget(
                              question: question,
                              deleteQuestion: controller.deleteQuestion,
                              index: index,
                              showAnswers: showAnswers,
                              key: Key('${question.hashCode}_$index'),
                            );
                          }
                        },
                      )
                    : Center(
                        child: Text(
                          isTaskFiltered
                              ? 'No questions found for this search task'
                              : 'Your questions will be shown here!',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

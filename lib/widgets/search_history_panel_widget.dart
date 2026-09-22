import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/get_controllers/home_controller.dart';
import 'package:mcqs_generator_ai_app/models.dart';

class SearchHistoryPanelWidget extends StatelessWidget {
  SearchHistoryPanelWidget({super.key});

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.history_toggle_off,
                    color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Search Tasks',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const Spacer(),
                Obx(() => controller.activeTaskFilterId.value.isNotEmpty
                    ? TextButton.icon(
                        onPressed: () => controller.activeTaskFilterId.value = '',
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('Show All',
                            style: TextStyle(fontSize: 11)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
          const Divider(height: 1),

          // Search Tasks List
          Expanded(
            child: Obx(() {
              final tasks = controller.searchTasks;
              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_outlined,
                          size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'No search tasks yet',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enter a topic to start searching',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 11),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildTaskCard(context, task);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, SearchTask task) {
    return Obx(() {
      final isSelected = controller.activeTaskFilterId.value == task.id;
      final colorScheme = Theme.of(context).colorScheme;

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        elevation: isSelected ? 2 : 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : colorScheme.surface,
        child: InkWell(
          onTap: () => controller.toggleTaskFilter(task.id),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Status Icon & Badge + Re-run Button
                Row(
                  children: [
                    _buildStatusBadge(task),
                    const Spacer(),
                    Tooltip(
                      message: 'Run search again',
                      child: IconButton(
                        icon: const Icon(Icons.replay, size: 18),
                        color: colorScheme.primary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => controller.reRunTask(task, context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Search Prompt Text
                Text(
                  task.searchText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),

                // Status Message / Progress
                Text(
                  task.statusMessage,
                  style: TextStyle(
                    fontSize: 11,
                    color: task.status == SearchTaskStatus.failed
                        ? Colors.red.shade700
                        : Colors.blueGrey.shade600,
                  ),
                ),

                if (task.status == SearchTaskStatus.inProgress) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: colorScheme.primaryContainer,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  ),
                ],

                // Error Message Box
                if (task.status == SearchTaskStatus.failed &&
                    task.errorMessage != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 14, color: Colors.red),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            task.errorMessage!,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.red),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Bottom Badges: Difficulty, Language, MCQs Count
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildDifficultyChip(task.difficulty),
                    _buildBadgeChip(Icons.language, task.language, Colors.blue),
                    if (task.status == SearchTaskStatus.completed)
                      _buildBadgeChip(Icons.check, '${task.resultCount} MCQs',
                          Colors.green.shade700),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStatusBadge(SearchTask task) {
    switch (task.status) {
      case SearchTaskStatus.inProgress:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 6),
            Text('Searching...',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold)),
          ],
        );
      case SearchTaskStatus.completed:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 14, color: Colors.green),
            SizedBox(width: 4),
            Text('Completed',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.bold)),
          ],
        );
      case SearchTaskStatus.failed:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, size: 14, color: Colors.red),
            SizedBox(width: 4),
            Text('Failed',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.bold)),
          ],
        );
    }
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color bg;
    Color fg;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        break;
      case 'hard':
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        break;
      case 'medium':
      default:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        difficulty,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _buildBadgeChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

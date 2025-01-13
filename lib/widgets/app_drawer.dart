import 'package:flutter/material.dart';
import 'package:mcqs_generator_ai_app/widgets/api_key_widget.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({
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
      child: ListView(
        children: [
          const DrawerHeader(child: Text('MCQs Generator AI APP')),
          ListTile(
            title: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Load questions from file'),
            ),
            subtitle: FilledButton(
              onPressed: widget.pickAndLoadQuestions,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Choose JSON File'),
              ),
            ),
          ),
          const ApiKeyWidget()
        ],
      ),
    );
  }
}

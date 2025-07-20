import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mcqs_generator_ai_app/widgets/api_key_widget.dart';

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

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/icon.png',
                  height: 100,
                  width: 100,
                ),
                const Center(
                    child: Text(
                  'MCQs Generator AI APP',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                )),
              ],
            ),
          ),
          ListTile(
            onTap: () {
              UtilFunctions.saveMCQs(
                  widget.controller.subject.value,
                  widget.controller.topicID.value,
                  widget.controller.questions,
                  Get.context,
                  true);

              Get.back();
            },
            leading: const Icon(Icons.save),
            title: const Text('Save as JSON'),
            trailing: const Text("{JSON}"),
          ),
          ListTile(
            onTap: () {
              UtilFunctions.saveMCQs(
                  widget.controller.subject.value,
                  widget.controller.topicID.value,
                  widget.controller.questions,
                  Get.context,
                  false);
              Get.back();
            },
            leading: const Icon(Icons.save_as),
            title: const Text('Save as TEXT'),
            trailing: const Icon(Icons.menu_book_outlined),
          ),
          const Divider(),
          ListTile(
            onTap: () => copyQuestionsAsJSON(context),
            leading: const Icon(Icons.copy),
            title: const Text('Copy JSON'),
            trailing: const Text("{JSON}"),
          ),
          ListTile(
            onTap: () => copyQuestionsAsText(context),
            leading: const Icon(Icons.copy),
            title: const Text('Copy TEXT'),
            trailing: const Icon(Icons.menu_book_outlined),
          ),
          const Divider(),
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
          const Divider(),
          const ApiKeyWidget(),
          const Divider(),
          const Expanded(child: Spacer()),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Powered by: Effordea'),
          ),
        ],
      ),
    );
  }

  void copyQuestionsAsJSON(BuildContext context) async {
    await Clipboard.setData(
        ClipboardData(text: jsonEncode(widget.controller.questions)));

    showQuestionsCopiedMessageOnScreen(context);
  }

  void copyQuestionsAsText(BuildContext context) async {
    await Clipboard.setData(ClipboardData(
        text: UtilFunctions.questionToText(widget.controller.subject.value,
            widget.controller.topicID.value, widget.controller.questions)));

    showQuestionsCopiedMessageOnScreen(context);
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
}

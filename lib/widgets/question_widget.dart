import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mcqs_generator_ai_app/models.dart';

class QuestionWidget extends StatefulWidget {
  const QuestionWidget({
    required this.question,
    required this.deleteQuestion,
    required this.index,
    required this.showAnswers,
    super.key,
  });

  final int index;
  final Question question;
  final Function(int) deleteQuestion;
  final bool showAnswers;

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  bool showAnswers = false;
  final questionStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  final answerStyle = const TextStyle(fontSize: 16);
  late final TextEditingController newAnswerController;

  @override
  void initState() {
    super.initState();
    newAnswerController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    bool plainText =
        widget.question.body?.contentType?.toLowerCase() == "plain";

    return Column(
      children: [
        _buildHeader(plainText),
        _buildAnswerList(),
      ],
    );
  }

  Widget _buildHeader(bool plainText) {
    return Row(
      children: [
        IconButton(
          onPressed: editQuestion,
          icon: const Icon(Icons.edit, color: Colors.grey),
        ),
        IconButton(
          onPressed: () => copyText(widget.question.body!.content.toString()),
          icon: const Icon(Icons.copy, color: Colors.grey),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () => setState(() {
                showAnswers = !showAnswers;
              }),
              child: plainText
                  ? Text(
                      '${widget.index + 1}: ${widget.question.body?.content ?? ''}',
                      style: questionStyle,
                    )
                  : Row(
                      children: [
                        Text(
                          '${widget.index + 1}: ',
                          style: questionStyle,
                        ),
                        Expanded(
                          // constraints: BoxConstraints(maxWidth: 500),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: getLatexWidget(
                                widget.question.body?.content, questionStyle),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => widget.deleteQuestion(widget.index),
          icon: const Icon(Icons.delete_forever_rounded, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildAnswerList() {
    return widget.showAnswers || showAnswers
        ? ReorderableListView.builder(
            itemCount: widget.question.answerOptions!.length + 1,
            shrinkWrap: true,
            buildDefaultDragHandles: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              bool isAnswer = index < widget.question.answerOptions!.length;

              return isAnswer
                  ? _buildAnswerOption(index)
                  : _buildAddNewAnswer(index);
            },
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = widget.question.answerOptions?.removeAt(oldIndex);
                widget.question.answerOptions?.insert(newIndex, item!);
              });
            },
          )
        : Container();
  }

  Widget _buildAnswerOption(int index) {
    return Row(
      key: ValueKey(index),
      children: [
        Expanded(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 44),
                child: Checkbox(
                  value:
                      widget.question.answerOptions?[index].isCorrect ?? false,
                  onChanged: (value) {
                    setState(() {
                      widget.question.answerOptions?[index].isCorrect = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: (widget
                              .question.answerOptions?[index].body?.contentType
                              ?.toLowerCase() ==
                          'plain')
                      ? GestureDetector(
                          onTap: () => copyText(widget.question
                                  .answerOptions?[index].body?.content ??
                              ''),
                          child: Text(
                            widget.question.answerOptions?[index].body
                                    ?.content ??
                                '',
                            style: const TextStyle(fontSize: 16),
                          ))
                      : GestureDetector(
                          onTap: () => copyText(widget.question
                                  .answerOptions?[index].body?.content ??
                              ''),
                          child: getLatexWidget(
                            widget.question.answerOptions?[index].body?.content,
                            const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        )),
              IconButton(
                onPressed: () {
                  setState(() {
                    widget.question.answerOptions?.removeAt(index);
                  });
                },
                icon:
                    const Icon(Icons.remove_circle_outline, color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40, height: 40),
      ],
    );
  }

  Widget _buildAddNewAnswer(int index) {
    return Padding(
      key: ValueKey(index),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Text('Add new answer and press Enter:'),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              textInputAction: TextInputAction.go,
              controller: newAnswerController,
              onSubmitted: (value) {
                if (newAnswerController.text.isNotEmpty) {
                  AnswerOptions newAns = AnswerOptions()
                    ..isCorrect = false
                    ..body = Body(
                        contentType: 'PLAIN',
                        content: newAnswerController.text);

                  setState(() {
                    widget.question.answerOptions?.add(newAns);
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget getLatexWidget(String? text, TextStyle textStyle) {
    final longEq = Math.tex(
      text!,
      textStyle: textStyle,
    );
    final breakResult = longEq.texBreak(
        enforceNoBreak: false, binOpPenalty: 100, relPenalty: 100);
    return Wrap(children: breakResult.parts);
  }

  void copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Center(child: Text('Copied on Clipboard')),
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  void editQuestion() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        controller.text = widget.question.body?.content ?? '';
        return AlertDialog.adaptive(
          title: const Text('Edit Question'),
          content: TextField(
            controller: controller,
            onSubmitted: (value) {
              setState(() {
                widget.question.body?.content = controller.text;
              });
              Navigator.of(context).pop();
            },
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.go,
          ),
        );
      },
    );
  }
}

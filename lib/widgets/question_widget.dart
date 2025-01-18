import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mcqs_generator_ai_app/models.dart';

class QuestionWidget extends StatefulWidget {
  const QuestionWidget(
      {required this.question,
      required this.deleteQuestion,
      required this.index,
      required this.showAnswers,
      super.key});

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

  @override
  Widget build(BuildContext context) {
    final newAnswerController = TextEditingController(
      text: '',
    );

    bool plainText =
        widget.question.body?.contentType?.toLowerCase() == "plain";

    return Column(
      children: [
        Row(
          children: [
            IconButton(
                onPressed: () => editQuestion(), icon: const Icon(Icons.edit)),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () => setState(() {
                    showAnswers = !showAnswers;
                  }),
                  child: plainText
                      ? SelectableText(
                          'Q ${widget.index + 1}: ${widget.question.body?.content ?? ''}',
                          style: questionStyle,
                        )
                      : Row(
                          children: [
                            Text('Q ${widget.index + 1}: '),
                            Expanded(
                                child: getLatexWidget(
                                    widget.question.body?.content,
                                    answerStyle)),
                          ],
                        ),
                ),
              ),
            ),
            IconButton(
                onPressed: () => widget.deleteQuestion(widget.index),
                icon: const Icon(Icons.delete_forever_rounded)),
          ],
        ),
        widget.showAnswers || showAnswers
            ? ReorderableListView.builder(
                itemCount: widget.question.answerOptions!.length + 1,
                shrinkWrap: true,
                buildDefaultDragHandles: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  bool isAnswer = index < widget.question.answerOptions!.length;

                  return (isAnswer)
                      ? Row(
                          key: ValueKey(index),
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Checkbox(
                                      value: widget
                                              .question
                                              .answerOptions?[index]
                                              .isCorrect ??
                                          false,
                                      onChanged: (value) {
                                        setState(() {
                                          widget.question.answerOptions?[index]
                                              .isCorrect = value;
                                        });
                                      }),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: (widget
                                                .question
                                                .answerOptions?[index]
                                                .body
                                                ?.contentType
                                                ?.toLowerCase() ==
                                            'plain')
                                        ? SelectableText(
                                            widget
                                                    .question
                                                    .answerOptions?[index]
                                                    .body
                                                    ?.content ??
                                                '',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          )
                                        : getLatexWidget(
                                            widget
                                                .question
                                                .answerOptions?[index]
                                                .body
                                                ?.content,
                                            const TextStyle(fontSize: 16)),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        widget.question.answerOptions?.remove(
                                            widget.question
                                                .answerOptions?[index]);
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 40,
                              height: 40,
                            )
                          ],
                        )
                      : Padding(
                          key: ValueKey(index),
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              const Text('Add new answer and press Enter:'),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextField(
                                  textInputAction: TextInputAction.go,
                                  controller: newAnswerController,
                                  onSubmitted: (value) {
                                    if (newAnswerController.text.isNotEmpty) {
                                      AnswerOptions newAns = AnswerOptions();
                                      newAns.isCorrect = false;
                                      newAns.body = Body(
                                          contentType: 'PLAIN',
                                          content: newAnswerController.text);
                                      setState(() {
                                        widget.question.answerOptions
                                            ?.add(newAns);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                },
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item =
                        widget.question.answerOptions?.removeAt(oldIndex);
                    widget.question.answerOptions?.insert(newIndex, item!);
                  });
                },
              )
            : Container(),
      ],
    );
  }

  getLatexWidget(String? text, TextStyle textStyle) {
    final longEq = Math.tex(
      text!,
      textStyle: textStyle,
    );
    final breakResult = longEq.texBreak(
        enforceNoBreak: false, binOpPenalty: 100, relPenalty: 100);
    final widget = Wrap(
      children: breakResult.parts,
    );
    return widget;
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

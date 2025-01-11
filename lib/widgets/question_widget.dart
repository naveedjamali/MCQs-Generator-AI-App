import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final newAnswerController = TextEditingController(
      text: '',
    );
    return ListTile(
      title: ListTile(
        leading: IconButton(
            onPressed: () => editQuestion(), icon: const Icon(Icons.edit)),
        title: GestureDetector(
          onTap: () => setState(() {
            showAnswers = !showAnswers;
          }),
          child: Text(
            'Q ${widget.index + 1}: ${widget.question.body?.content ?? ''}',
            softWrap: true,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        trailing: IconButton(
            onPressed: () => widget.deleteQuestion(widget.index),
            icon: const Icon(Icons.delete_forever_rounded)),
      ),
      subtitle: widget.showAnswers || showAnswers
          ? ReorderableListView.builder(
              itemCount: widget.question.answerOptions!.length + 1,
              shrinkWrap: true,
              buildDefaultDragHandles: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return (index < widget.question.answerOptions!.length)
                    ? ListTile(
                        key: ValueKey(index),
                        leading: Container(
                          width: 8,
                          height: double.infinity,
                          color:
                              widget.question.answerOptions![index].isCorrect ??
                                      false
                                  ? Colors.green
                                  : Colors.red[100],
                        ),
                        title: ListTile(
                          leading: Switch(
                              value: widget.question.answerOptions?[index]
                                      .isCorrect ??
                                  false,
                              onChanged: (value) {
                                setState(() {
                                  widget.question.answerOptions?[index]
                                      .isCorrect = value;
                                });
                              }),
                          title: Text(widget.question.answerOptions?[index].body
                                  ?.content ??
                              ''),
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                widget.question.answerOptions?.remove(
                                    widget.question.answerOptions?[index]);
                              });
                            },
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      )
                    : ListTile(
                        key: ValueKey(index),
                        title: ListTile(
                          leading:
                              const Text('Add new answer and press Enter:'),
                          title: TextField(
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
                                  widget.question.answerOptions?.add(newAns);
                                });
                              }
                            },
                          ),
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

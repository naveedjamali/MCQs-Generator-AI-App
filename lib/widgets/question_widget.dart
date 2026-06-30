import 'package:flutter/material.dart';
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
  bool showExplanation = false;
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
    String rawContent = widget.question.body?.content ?? '';
    String questionText;
    String explanationText = '';

    if (rawContent.contains('[[EXPL]]')) {
      List<String> parts = rawContent.split('[[EXPL]]');
      questionText = parts[0].trim();
      explanationText = parts[1].trim();
    } else if (rawContent.contains('Explanation:')) {
      List<String> parts = rawContent.split('Explanation:');
      questionText = parts[0].trim();
      explanationText = parts[1].trim();
    } else {
      questionText = rawContent;
    }

    bool plainText =
        widget.question.body?.contentType?.toLowerCase() == "plain";

    return Dismissible(
      key: Key(
          'question_${widget.index}_${widget.question.body?.content.hashCode}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe Right: Edit
          editQuestion();
          return false;
        } else {
          // Swipe Left: Delete
          widget.deleteQuestion(widget.index);
          return true;
        }
      },
      background: Container(
        color: Colors.blue.withValues(alpha: 0.8),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20.0),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red.withValues(alpha: 0.8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(plainText, questionText, explanationText),
            _buildAnswerList(),
            if (showExplanation && explanationText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueGrey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              size: 16, color: Colors.blueGrey.shade700),
                          const SizedBox(width: 8),
                          Text('AI EXPLANATION',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  letterSpacing: 1.1,
                                  color: Colors.blueGrey.shade700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        explanationText,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey.shade900,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      bool plainText, String questionText, String explanationText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: GestureDetector(
              onTap: () => setState(() {
                showAnswers = !showAnswers;
              }),
              child: plainText
                  ? Text(
                      '${widget.index + 1}: $questionText',
                      style: questionStyle,
                    )
                  : Row(
                      children: [
                        Text(
                          '${widget.index + 1}: ',
                          style: questionStyle,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: getLatexWidget(questionText, questionStyle),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (explanationText.isNotEmpty)
          IconButton(
            onPressed: () => setState(() {
              showExplanation = !showExplanation;
            }),
            icon: Icon(
                showExplanation ? Icons.lightbulb : Icons.lightbulb_outline,
                color: Colors.orange,
                size: 20),
            tooltip: 'Show Explanation',
          ),
        IconButton(
          onPressed: () => copyText(questionText),
          icon: const Icon(Icons.copy, color: Colors.grey, size: 20),
          tooltip: 'Copy Question',
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
      child: TextField(
        textInputAction: TextInputAction.go,
        controller: newAnswerController,
        decoration: const InputDecoration(
          labelText: 'Add new answer and press Enter',
          hintText: 'Type answer here...',
          prefixIcon: Icon(Icons.add),
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) {
          if (newAnswerController.text.isNotEmpty) {
            AnswerOptions newAns = AnswerOptions()
              ..isCorrect = false
              ..body =
                  Body(contentType: 'PLAIN', content: newAnswerController.text);

            setState(() {
              widget.question.answerOptions?.add(newAns);
              newAnswerController.clear();
            });
          }
        },
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

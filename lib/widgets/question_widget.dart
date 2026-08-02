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
    final isKatex = widget.question.body?.contentType == "KATEX";
    final isSmallScreen = MediaQuery.of(context).size.width <= 600;

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
      child: InkWell(
        onTap: () => setState(() {
          showAnswers = !showAnswers;
        }),
        onLongPress: isSmallScreen
            ? () => _showQuestionContextMenu(context, questionText)
            : null,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(plainText, questionText, isSmallScreen),
              _buildAnswerList(isSmallScreen),
              if ((widget.showAnswers || showAnswers) &&
                  explanationText.isNotEmpty)
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
                        !isKatex
                            ? Text(
                                explanationText,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey.shade900,
                                  height: 1.4,
                                ),
                              )
                            : getLatexWidget(
                                explanationText,
                                TextStyle(
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
      ),
    );
  }

  void _showQuestionContextMenu(BuildContext context, String questionText) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Question Actions',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy Question'),
            onTap: () {
              Navigator.pop(context);
              copyText(questionText);
            },
          ),
          if (widget.question.rawCsv != null)
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Copy RAW CSV'),
              onTap: () {
                Navigator.pop(context);
                copyText(widget.question.rawCsv!);
              },
            ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Question'),
            onTap: () {
              Navigator.pop(context);
              editQuestion();
            },
          ),
          StatefulBuilder(builder: (context, setMenuState) {
            final isKatex = widget.question.body?.contentType == "KATEX";
            return SwitchListTile(
              secondary: const Icon(Icons.functions),
              title: const Text('KATEX Mode'),
              value: isKatex,
              onChanged: (value) {
                setState(() {
                  final newType = value ? "KATEX" : "PLAIN";
                  widget.question.body?.contentType = newType;
                  for (var opt in widget.question.answerOptions ?? []) {
                    opt.body?.contentType = newType;
                  }
                });
                setMenuState(() {});
              },
            );
          }),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Question',
                style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              widget.deleteQuestion(widget.index);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHeader(bool plainText, String questionText, bool isSmallScreen) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    final isKatex = widget.question.body?.contentType == "KATEX";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: !isKatex
                ? Text(
                    '${widget.index + 1}: $questionText',
                    style: questionStyle,
                    softWrap: true,
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.index + 1}: ',
                        style: questionStyle,
                      ),
                      Expanded(
                        child: getLatexWidget(questionText, questionStyle),
                      ),
                    ],
                  ),
          ),
          if (!isSmallScreen) ...[
            // PLAIN/KATEX Toggle
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isKatex ? 'KATEX' : 'PLAIN',
                  style:
                      const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                ),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: isKatex,
                    onChanged: (value) {
                      setState(() {
                        final newType = value ? "KATEX" : "PLAIN";
                        widget.question.body?.contentType = newType;
                        // Also update all answers for consistency
                        for (var opt in widget.question.answerOptions ?? []) {
                          opt.body?.contentType = newType;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () => copyText(questionText),
              icon: const Icon(Icons.copy, color: Colors.grey, size: 20),
              tooltip: 'Copy Question',
            ),
            if (widget.question.rawCsv != null)
              IconButton(
                onPressed: () => copyText(widget.question.rawCsv!),
                icon: const Icon(Icons.receipt_long_outlined,
                    color: Colors.blueGrey, size: 20),
                tooltip: 'Copy RAW CSV',
              ),
            if (isWideScreen)
              IconButton(
                onPressed: () => widget.deleteQuestion(widget.index),
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
                tooltip: 'Delete Question',
              ),
          ] else
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showQuestionContextMenu(context, questionText),
              child: const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 8.0),
                child: Icon(Icons.more_vert, size: 24, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerList(bool isSmallScreen) {
    return widget.showAnswers || showAnswers
        ? ReorderableListView.builder(
            itemCount: widget.question.answerOptions!.length + 1,
            shrinkWrap: true,
            buildDefaultDragHandles: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              bool isAnswer = index < widget.question.answerOptions!.length;

              return isAnswer
                  ? _buildAnswerOption(index, isSmallScreen)
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

  Widget _buildAnswerOption(int index, bool isSmallScreen) {
    final isKatex =
        widget.question.answerOptions?[index].body?.contentType == "KATEX";
    final answerText =
        widget.question.answerOptions?[index].body?.content ?? '';

    return InkWell(
      key: ValueKey(index),
      onLongPress: isSmallScreen
          ? () => _showAnswerContextMenu(context, index, answerText)
          : null,
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: isSmallScreen ? 8 : 44),
                  child: Checkbox(
                    value: widget.question.answerOptions?[index].isCorrect ??
                        false,
                    onChanged: (value) {
                      setState(() {
                        widget.question.answerOptions?[index].isCorrect = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: !isKatex
                      ? GestureDetector(
                          onTap: () => copyText(answerText),
                          child: Text(
                            answerText,
                            style: const TextStyle(fontSize: 16),
                            softWrap: true,
                          ))
                      : GestureDetector(
                          onTap: () => copyText(answerText),
                          child: getLatexWidget(
                            answerText,
                            const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                ),
                if (!isSmallScreen) ...[
                  // Individual Answer KaTeX Switch
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isKatex ? 'KATEX' : 'PLAIN',
                        style: const TextStyle(
                            fontSize: 6, fontWeight: FontWeight.bold),
                      ),
                      Transform.scale(
                        scale: 0.5,
                        child: Switch(
                          value: isKatex,
                          onChanged: (value) {
                            setState(() {
                              widget.question.answerOptions?[index].body
                                  ?.contentType = value ? "KATEX" : "PLAIN";
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        widget.question.answerOptions?.removeAt(index);
                      });
                    },
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }

  void _showAnswerContextMenu(
      BuildContext context, int index, String answerText) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Answer Actions',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy Answer'),
            onTap: () {
              Navigator.pop(context);
              copyText(answerText);
            },
          ),
          StatefulBuilder(builder: (context, setMenuState) {
            final isKatex =
                widget.question.answerOptions?[index].body?.contentType ==
                    "KATEX";
            return SwitchListTile(
              secondary: const Icon(Icons.functions),
              title: const Text('KATEX Mode'),
              value: isKatex,
              onChanged: (value) {
                setState(() {
                  widget.question.answerOptions?[index].body?.contentType =
                      value ? "KATEX" : "PLAIN";
                });
                setMenuState(() {});
              },
            );
          }),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Remove Answer',
                style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                widget.question.answerOptions?.removeAt(index);
              });
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
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

  String _makeKatexBreakable(String input) {
    // Find all \text{...} blocks and split them into individual words wrapped in \text{}
    // This allows the texBreak engine to find logical break points at spaces.
    return input.replaceAllMapped(RegExp(r'\\text\{([^}]*)\}'), (match) {
      String content = match.group(1) ?? "";
      if (content.isEmpty) return "";
      return content
          .split(' ')
          .where((word) => word.isNotEmpty)
          .map((word) => '\\text{$word }')
          .join(' ');
    });
  }

  Widget getLatexWidget(String? text, TextStyle textStyle) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    // Transform large blocks into breakable chunks
    final breakableText = _makeKatexBreakable(text);

    try {
      final longEq = Math.tex(
        breakableText,
        textStyle: textStyle,
      );
      final breakResult = longEq.texBreak(
          enforceNoBreak: false, binOpPenalty: 10, relPenalty: 10);
      return Wrap(
        spacing: 0,
        runSpacing: 4,
        children: breakResult.parts,
      );
    } catch (e) {
      // If transformation fails, fallback to original rendering
      return Math.tex(text, textStyle: textStyle);
    }
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
    final isKatex = widget.question.body?.contentType == "KATEX";

    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        controller.text = widget.question.body?.content ?? '';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog.adaptive(
              title: const Text('Edit Question'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      maxLines: null,
                      onChanged: (value) {
                        if (isKatex) setDialogState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.multiline,
                    ),
                    if (isKatex) ...[
                      const SizedBox(height: 16),
                      const Text('Preview:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: getLatexWidget(controller.text,
                            const TextStyle(fontSize: 16, color: Colors.black)),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      widget.question.body?.content = controller.text;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

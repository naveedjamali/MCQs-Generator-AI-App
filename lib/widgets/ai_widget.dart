import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mcqs_generator_ai_app/get_controllers/home_controller.dart';

class AiWidget extends StatelessWidget {
  AiWidget({super.key});

  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                controller.clearEntries();
              },
              label: const Text('Clear topics'),
              icon: const Icon(
                Icons.clear,
                color: Colors.red,
              ),
            )
          ],
        ),
        SizedBox(
          child: Row(
            children: [
              Flexible(
                flex: 1,
                child: TextField(
                  focusNode: controller.inputFocusNode,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (value) async {
                    if (controller.inputController.text.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          title: Text('input text first'),
                        ),
                      );
                    } else {
                      String text = controller.inputController.text;
                      controller.addEntry(text);
                      controller.setGeneratingResponse(true);

                      try {
                        getAIDescription(text, context);

                        controller.setInputControllerText('');
                        controller.inputFocusNode.requestFocus();
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final errorTextController = TextEditingController();

                            return AlertDialog(
                              title: const Text('Error'),
                              content: Column(
                                children: [
                                  Text(e.toString()),
                                  const Text(
                                      'Re-write your query and try again'),
                                  TextFormField(
                                    controller: errorTextController,
                                  ),
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {}, child: const Text('Go'))
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter your topic and press Enter',
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  controller: controller.inputController,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void getAIDescription(String searchKeywords, BuildContext context) async {
    final instructions = Content.multi([
      TextPart('Subject: ${controller.subject.value}'),
      TextPart('Topic: ${controller.topicID.value}'),
      TextPart('Generate a detailed essay on the given topic'),
      TextPart('essay length: 2000 words minimum'),
      TextPart('essay type: in-depth'),
      TextPart(
          'The Essay includes: history, actions, reactions, parts, sub-parts, examples, formulas, measurements, structure, importance, inventions, discoveries, scientists, artists, uses, involvements, dates, types, subtypes, etc'),
    ]);

    controller.askAI(instructions, searchKeywords).then((generatedDescription) {
      if (generatedDescription != null) {
        if (generatedDescription ==
            "GenerativeAIException: Candidate was blocked due to recitation") {
          showDialog(
              context: context,
              builder: (context) {
                controller.setGeneratingResponse(false);

                return const AlertDialog(
                  title: Text('Error'),
                  content: Text(
                      'GenerativeAIException: Candidate was blocked due to recitation'),
                );
              });
        } else {
          controller.getCsvResponse(generatedDescription).then(
            (csv) {
              controller.setCSV(csv!);
              controller.addQuestions(context);

              controller.setGeneratingResponse(false);
            },
          );
        }
      }
    });
  }
}

import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mcqs_generator_ai_app/functions/util_functions.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

class AppController extends GetxController {
  RxString queryText = "".obs;
  RxString API_KEY = "".obs;
  RxString csv = ''.obs;
  RxString topicID = 'Computer System'.obs;
  RxString subject = 'Computer Studies'.obs;

  final isSearchMode = false.obs;
  final isAscendingOrder = true.obs;
  final searchBoxEnabled = false.obs;

  final showAnswers = false.obs;
  final generatingResponse = false.obs;

  final isFilteringFourAnswers = false.obs;

  late FocusNode topicFocus;
  late FocusNode subjectFocus;
  late FocusNode inputFocus;

  RxList<Question> questions = <Question>[].obs;
  RxList<Question> filteredQuestions = <Question>[].obs;
  RxList<String> entries = <String>[].obs;
  late TextEditingController inputController;
  late FocusNode inputFocusNode;

  late TextEditingController topicController;
  late TextEditingController subjectController;
  late TextEditingController searchController;

  // Following lines control the scroll of output questions list.
  late ItemScrollController itemScrollController;
  late ScrollOffsetController scrollOffsetController;

  late ItemPositionsListener itemPositionsListener;

  late ScrollOffsetListener scrollOffsetListener;

  @override
  void onInit() {
    topicController = TextEditingController(
      text: 'Computer System',
    );
    subjectController = TextEditingController(
      text: 'Computer Studies',
    );
    searchController = TextEditingController(text: '');
    itemScrollController = ItemScrollController();
    inputController = TextEditingController(text: 'RAM vs ROM: A brief guide');
    inputFocusNode = FocusNode();
    topicFocus = FocusNode();
    subjectFocus = FocusNode();
    inputFocus = FocusNode();

    scrollOffsetController = ScrollOffsetController();
    itemPositionsListener = ItemPositionsListener.create();
    scrollOffsetListener = ScrollOffsetListener.create();
    readApiKeyFromStorage();

    super.onInit();
  }

  Future<String> readApiKeyFromStorage() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String key = sp.getString("API") ?? "";
    API_KEY.value = key;

    return key;
  }

  Future<bool> saveApiKeyInStorage(String apiKey) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool saved = await sp.setString("API", apiKey);
    API_KEY.value = apiKey;
    update();
    return saved;
  }

  void addQuestions(BuildContext context) {
    topicID.value = topicController.text.trim();
    subject.value = subjectController.text.trim();
    int addedQuestionCount = 0;

    String input = csv.trim();
    List<Question> temp = [];

    String delimiter = ',,,';
    List<String> lists = input.split('\n');
    String joint = '';
    for (var s in lists) {
      s = s.replaceAll(RegExp(r',,,,'), delimiter);
      s = s.replaceAll(RegExp(r', , ,'), delimiter);
      s = s.replaceAll(RegExp(r', ,'), delimiter);
      if (!s.contains(',,,')) {
        if (s.contains(',,')) {
          s = s.replaceAll(RegExp(r',,'), delimiter);
        }
      }
      joint = '$joint\n$s';
    }

    input = joint;

    List<List<dynamic>> rows = const CsvToListConverter().convert(
      input,
      fieldDelimiter: delimiter,
      eol: '\n',
      shouldParseNumbers: true,
      convertEmptyTo: '\n',
      allowInvalid: false,
    );
    // const csvConverter = CsvToListConverter();
    //csvConverter;
    for (List<dynamic> row in rows) {
      if (row.length < 3) {
        // Invalid question
        continue;
      }
      //Create question
      Question q = Question();

      Body qBody = Body(
          contentType: 'PLAIN', content: UtilFunctions.removeCommas(row[0]));
      q.body = qBody;
      checkBodyForKatex(qBody);

      q.answerOptions = [];

      for (int i = 1; i < row.length; i++) {
        // create answer option.

        AnswerOptions answer = AnswerOptions(
            body: Body(
                content: UtilFunctions.removeCommas(row[i].toString().trim()),
                contentType: 'PLAIN'),
            // isCorrect: row[i] == row[row.length - 1]);
            isCorrect: false);

        // check if the answer is already added.

        checkBodyForKatex(answer.body);

        if (containsAnswer(q.answerOptions ?? [], answer.body!.content)) {
          for (int i = 0; i < q.answerOptions!.length; i++) {
            if (q.answerOptions?[i].body?.content == answer.body?.content) {
              q.answerOptions?[i].isCorrect = true;
              break;
            }
          }
        } else {
          q.answerOptions?.add(answer);
        }
      }

      //check that at least one answer is correct in the question.
      bool containCorrectAnswer = false;
      q.answerOptions?.forEach(
        (element) {
          if (element.isCorrect ?? false) {
            containCorrectAnswer = true;
          }
        },
      );
      if (!containCorrectAnswer) {
        continue;
      }

      q.subjectId = subject.value;
      q.topicId = topicID.value;
      q.assignedPoints = 1;
      q.status = 'ACTIVE';

      shuffleAnswers(q.answerOptions);

      temp.add(q);
    }

    int questionsCount = questions.length;
    copyQuestions(temp, questions);
    //itemScrollController.jumpTo(index: lastIndex + 1);

    addedQuestionCount = questions.length - questionsCount;

    if (kDebugMode) {
      print(questions.length);
      print(json.encode(temp));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      snackBarAnimationStyle: AnimationStyle(
          duration: const Duration(seconds: 1),
          curve: Curves.easeIn,
          reverseCurve: Curves.bounceIn,
          reverseDuration: const Duration(seconds: 1)),
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text('$addedQuestionCount new questions added successfully'),
        width: 600,
        backgroundColor: Colors.green,
        padding: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        dismissDirection: DismissDirection.horizontal,
        showCloseIcon: true,
      ),
    );

    update();
  }

  bool containsAnswer(
      List<AnswerOptions> answerOptionsList, String? answerText) {
    if (answerOptionsList.isEmpty) {
      return false;
    }

    for (int i = 0; i < answerOptionsList.length; i++) {
      if (answerOptionsList[i].body?.content == answerText) {
        return true;
      }
    }
    return false;
  }

  void shuffleAnswers(List<AnswerOptions>? answerOptions) {
    String all = 'all';
    String none = 'none';
    String both = "both";
    String neither = 'neither';
    for (int i = 0; i < answerOptions!.length; i++) {
      String ans =
          answerOptions[i].body?.content.toString().toLowerCase() ?? "";
      if (ans.contains(all) ||
          ans.contains(none) ||
          ans.contains(both) ||
          ans.contains(neither)) {
        return;
      }
    }
    answerOptions.shuffle();
    update();
  }

  void copyQuestions(List<Question> temp, List<Question> mainList) {
    for (var quest in temp) {
      if (mainList.isEmpty) {
        mainList.add(quest);
      } else {
        bool exist = false;
        for (Question q in mainList) {
          if (q.body?.content == quest.body?.content) {
            exist = true;
            break;
          }
        }
        if (!exist) {
          mainList.add(quest);
        }
      }
    }
    update();
  }

  void clearEntries() {
    entries.clear();
    update();
  }

  addEntry(String entry) {
    entries.insert(0, entry);
    update();
  }

  void setGeneratingResponse(bool value) {
    generatingResponse.value = value;
    update();
  }

  void setInputControllerText(String text) {
    inputController.text = text;
    update();
  }

  Future<String?> askAI(Content instructions, String query) async {
    // Access your API key as an environment variable (see "Set up your API key" above)

    final model = GenerativeModel(
      model: 'gemini-1.5-flash-002',
      apiKey: API_KEY.value,
      safetySettings: [
        SafetySetting(
          HarmCategory.sexuallyExplicit,
          HarmBlockThreshold.none,
        ),
      ],
      generationConfig: GenerationConfig(
        temperature: 1,
      ),
      // systemInstruction: Content.multi([TextPart('')]),
      systemInstruction: instructions,
    );

    var prompt = query;

    if (kDebugMode) {
      print('Prompt: $prompt');
    } // Print the value of prompt
    try {
      final response = await model.generateContent([Content.text(prompt)]);

      if (kDebugMode) {
        print(response.text);
      }
      return response.text;
    } catch (error) {
      return error.toString();
    }
  }

  Future<String?> getCsvResponse(String description) async {
    final ins = Content.multi(
      [
        TextPart(
            'Generate clear and concise minimum 60 MCQs in the csv format'),
        TextPart('use three commas \',,,\' as delimiter'),
        TextPart(
            'reconfirm that CSV values are separated with three commas ,,, '),
        TextPart(
            'Question text should NOT refer to the \'text\' or \'essay\' or \'passage\'. For example: What is the primary \'focus\' or \'main idea\' or \'conclusion\' of this essay or text or passage?'),
        TextPart(
            'Each question should be self-contained and understandable without requiring prior access to the text.'),
        TextPart(
            'DO NOT INCLUDE markup tags in the questions and answers e.g. <sub>, <sup> etc'),
        TextPart(
            'CSV output format: Question ,,, Option1 ,,, Option2 ,,, Option3 ,,, Option4 ,,, CorrectAnswer'),
        TextPart('Minimum four answer options for every question'),
        TextPart(
            'Example correct output: What is the capital of Pakistan ,,, Hyderabad ,,, Karachi ,,, Islamabad ,,, Peshawar ,,, Islamabad'),
        TextPart(
            'Example incorrect output: What is the capital of Pakistan ,,, Hyderabad ,,, Karachi ,,, Islamabad ,,, Peshawar ,,, C'),
        TextPart(
            'Example incorrect output with two commas as delimiter: What is the capital of Pakistan ,, Hyderabad ,, Karachi ,, Islamabad ,, Peshawar ,, Islamabad'),
        TextPart(
            'Recheck output with ,,, only, output should not contain ,, or , , or ,,,, or , , , delimiters.'),
      ],
    );
    String? csv = await askAI(ins, description);
    return csv;
  }

  void getAIDescription(String searchKeywords, BuildContext context) async {
    final instructions = Content.multi([
      TextPart('Subject: ${subject.value}'),
      TextPart('Topic: ${topicID.value}'),
      TextPart('Generate a detailed essay on the given topic'),
      TextPart('essay length: 2000 words minimum'),
      TextPart('essay type: in-depth'),
      TextPart(
          'The Essay includes: history, actions, reactions, parts, sub-parts, examples, formulas, measurements, structure, importance, inventions, discoveries, scientists, artists, uses, involvements, dates, types, subtypes, etc'),
    ]);

    askAI(instructions, searchKeywords).then((generatedDescription) {
      if (generatedDescription != null) {
        if (generatedDescription ==
            "GenerativeAIException: Candidate was blocked due to recitation") {
          showDialog(
              context: context,
              builder: (context) {
                setGeneratingResponse(false);

                return const AlertDialog(
                  title: Text('Error'),
                  content: Text(
                      'GenerativeAIException: Candidate was blocked due to recitation'),
                );
              });
        } else {
          getCsvResponse(generatedDescription).then(
            (csv) {
              setCSV(csv!);
              addQuestions(context);

              setGeneratingResponse(false);
            },
          );
        }
      }
    });
  }

  void setCSV(String value) {
    csv.value = value;
    update();
  }

  deleteQuestion(int questionIndex) {
    questions.removeAt(questionIndex);
    update();
  }

  updateChapter(String text) {
    topicID.value = text;
    update();
  }

  updateSubject(String text) {
    subject.value = text;
    update();
  }

  void setShowAnswers(value) {
    showAnswers.value = value;
    update();
  }

  void sortByName() {
    if (isAscendingOrder.value) {
      questions.sort((a, b) {
        if (a.body?.content == null && b.body?.content == null) {
          return 0;
        } else if (a.body?.content == null) {
          return 1;
        } else if (b.body?.content == null) {
          return -1;
        } else {
          return a.body!.content!.compareTo(b.body!.content!);
        }
      });
    } else {
      questions.sort((a, b) {
        if (a.body?.content == null && b.body?.content == null) {
          return 0;
        } else if (a.body?.content == null) {
          return -1;
        } else if (b.body?.content == null) {
          return 1;
        } else {
          return b.body!.content!.compareTo(a.body!.content!);
        }
      });
    }
    isAscendingOrder.value = isAscendingOrder.value;

    update();
  }

  void setFilteringFourOptions(value) {
    isFilteringFourAnswers.value = value;
    if (isFilteringFourAnswers.value) {
      filteredQuestions.clear();
      for (var q in questions) {
        if (q.answerOptions?.length == 4) {
          filteredQuestions.add(q);
        }
      }
    } else {
      filteredQuestions.clear();
    }
    update();
  }

  void setSearchMode(bool value) {
    isSearchMode.value = value;
    update();
  }

  bool getSearchMode() {
    return isSearchMode.value;
  }

  String convertHtmlToFlutterKatex(String html) {
    // Replace <sub> tags with KaTeX subscript syntax
    String katex = html.replaceAllMapped(
      RegExp(r'<sub>(.*?)<\/sub>'),
      (match) => '_{${match.group(1)}}',
    );

    // Replace <sup> tags with KaTeX superscript syntax
    katex = katex.replaceAllMapped(
      RegExp(r'<sup>(.*?)<\/sup>'),
      (match) => '^{${match.group(1)}}',
    );

    // Wrap normal text outside of math mode with \text{}
    katex = katex.replaceAllMapped(
      RegExp(r'([^_^{}<>]+)'),
      (match) => '\\text{${match.group(1)?.trim()}}',
    );

    return katex;
  }

  void checkBodyForKatex(Body? body) {
    String questionText = body?.content ?? "";
    if (questionText.isNotEmpty) {
      bool isHtml = questionText.toLowerCase().contains("<sub>") ||
          questionText.toLowerCase().contains("</sub>") ||
          questionText.toLowerCase().contains("<sup>") ||
          questionText.toLowerCase().contains("</sup>");
      if (isHtml) {
        String html = questionText;
        body?.content = convertHtmlToFlutterKatex(html);
        body?.contentType = "KATEX";
      }
    }
  }

  void setSearchText(String text) {
    setSearchMode(false);
    setSearchMode(true);
    queryText.value = text;
    update();
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mcqs_generator_ai_app/functions/util_functions.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models.dart';

class AppController extends GetxController {
  RxString queryText = "".obs;
  RxString apiKey = "".obs;
  RxString selectedModel = "gemini-2.5-flash".obs;
  RxString csvOutput = ''.obs;
  RxString topicID = 'Computer System'.obs;
  RxString subject = 'Computer Studies'.obs;

  RxString selectedLanguage = "English".obs;
  RxString selectedDifficulty = "Medium".obs;

  static const String defaultCsvInstructions = '''
MOST IMPORTANT: Generate MCQs from the given text only. 
DO NOT include any header row, introductory text, or conclusion.
Output ONLY the CSV data.
Language: {language}
Difficulty Level: {difficulty}
Generate clear and concise {count} MCQs in the csv format.
use three commas ',,,' as delimiter.
reconfirm that CSV values are separated with three consecutive commas ,,, .
Question text should NOT refer to the 'text' or 'essay' or 'passage'.
Each question should be self-contained and understandable without requiring prior access to the text.
DO NOT INCLUDE markup tags like <sub>, <sup> etc.
CSV output format (7 COLUMNS MANDATORY): Question ,,, Option1 ,,, Option2 ,,, Option3 ,,, Option4 ,,, CorrectAnswer ,,, Explanation
IMPORTANT: The 7th column MUST start with the tag '[[EXPL]]' followed by a brief explanation of why the correct answer is right.
Example output line: What is the capital of Pakistan ,,, Hyderabad ,,, Karachi ,,, Islamabad ,,, Peshawar ,,, Islamabad ,,, [[EXPL]] Islamabad is the capital of Pakistan.
Ensure EVERY line has exactly 6 delimiters (seven columns).
''';

  static const String defaultEssayInstructions = '''
Subject: {subject}
Topic: {topic}
Generate a detailed essay on the given topic.
essay length: 2000 words minimum.
essay type: in-depth.
The Essay includes: history, actions, reactions, parts, sub-parts, examples, formulas, measurements, structure, importance, inventions, discoveries, scientists, artists, uses, involvements, dates, types, subtypes, etc.
''';

  RxString csvInstructions = defaultCsvInstructions.obs;
  RxString essayInstructions = defaultEssayInstructions.obs;

  final isSearchMode = false.obs;
  final isCovertCSVMode = false.obs;
  final useAiToGenerateEssay = true.obs;
  final isManualEssayMode = false.obs;
  final isPdfMode = false.obs;
  final isAscendingOrder = true.obs;
  final searchBoxEnabled = false.obs;

  final showAnswers = false.obs;
  final generatingResponse = false.obs;
  final loadingMessage = "Processing...".obs;

  final isFilteringFourAnswers = false.obs;
  final showSearchField = false.obs;
  final showAiInput = true.obs;

  late FocusNode topicFocus;
  late FocusNode subjectFocus;
  late FocusNode inputFocus;

  RxList<Question> questions = <Question>[].obs;
  RxList<Question> filteredQuestions = <Question>[].obs;
  RxList<String> entries = <String>[].obs;
  RxList<String> essays = <String>[].obs;

  late TextEditingController inputController;
  late TextEditingController pdfPagesController;
  late TextEditingController pdfInstructionsController;
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
    pdfPagesController = TextEditingController(text: '');
    pdfInstructionsController = TextEditingController(text: '');
    itemScrollController = ItemScrollController();
    inputController = TextEditingController(
        text: isCovertCSVMode.value
            ? 'Enter CSV here'
            : 'RAM vs ROM: A brief guide');
    inputFocusNode = FocusNode();
    topicFocus = FocusNode();
    subjectFocus = FocusNode();
    inputFocus = FocusNode();

    scrollOffsetController = ScrollOffsetController();
    itemPositionsListener = ItemPositionsListener.create();
    scrollOffsetListener = ScrollOffsetListener.create();
    readApiKeyFromStorage();
    readModelFromStorage();
    readInstructionsFromStorage();

    super.onInit();
  }

  Future<void> readInstructionsFromStorage() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    csvInstructions.value =
        sp.getString("CSV_INSTRUCTIONS") ?? csvInstructions.value;
    essayInstructions.value =
        sp.getString("ESSAY_INSTRUCTIONS") ?? essayInstructions.value;
  }

  Future<bool> saveCsvInstructionsToStorage(String instructions) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool saved = await sp.setString("CSV_INSTRUCTIONS", instructions);
    csvInstructions.value = instructions;
    update();
    return saved;
  }

  Future<bool> saveEssayInstructionsToStorage(String instructions) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool saved = await sp.setString("ESSAY_INSTRUCTIONS", instructions);
    essayInstructions.value = instructions;
    update();
    return saved;
  }

  void resetInstructions() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.remove("CSV_INSTRUCTIONS");
    await sp.remove("ESSAY_INSTRUCTIONS");
    csvInstructions.value = defaultCsvInstructions;
    essayInstructions.value = defaultEssayInstructions;
    update();
  }

  Future<void> readModelFromStorage() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String model = sp.getString("MODEL") ?? "gemini-2.5-flash";
    // Sanitize: remove 'models/' prefix if it exists in storage
    selectedModel.value = model.replaceFirst('models/', '');
  }

  Future<bool> saveModelToStorage(String model) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String sanitizedModel = model.replaceFirst('models/', '');
    bool saved = await sp.setString("MODEL", sanitizedModel);
    selectedModel.value = sanitizedModel;
    update();
    return saved;
  }

  Future<String> readApiKeyFromStorage() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String key = sp.getString("API") ?? "";
    apiKey.value = key;

    return key;
  }

  Future<bool> saveApiKeyInStorage(String apiKeyText) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool saved = await sp.setString("API", apiKeyText);
    apiKey.value = apiKeyText;
    update();
    return saved;
  }

  void addQuestions(BuildContext context) {
    topicID.value = topicController.text.trim();
    subject.value = subjectController.text.trim();
    int addedQuestionCount = 0;

    String input = csvOutput.value.trim();
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

    List<List<dynamic>> rows = input
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.split(delimiter))
        .toList();

    for (List<dynamic> row in rows) {
      if (row.length < 6) continue; // Minimum 6 columns required

      // Skip header rows or example rows that the AI sometimes includes
      String firstCol = row[0].toString().trim().toLowerCase();
      if (firstCol == "question" ||
          firstCol.startsWith("example") ||
          firstCol.contains("option1")) {
        continue;
      }

      Question q = Question();
      String questionText = UtilFunctions.removeCommas(row[0].toString());

      // Try to find explanation in the 7th column or beyond
      String? explanation;
      if (row.length >= 7) {
        explanation = UtilFunctions.removeCommas(row[6].toString().trim());
      }

      if (explanation != null && explanation.isNotEmpty) {
        if (!explanation.contains('[[EXPL]]')) {
          explanation = '[[EXPL]] $explanation';
        }
        questionText += "\n\n$explanation";
      }

      Body qBody = Body(contentType: 'PLAIN', content: questionText);
      q.body = qBody;
      checkBodyForKatex(qBody);
      q.answerOptions = [];

      // Correct answer check (column 5)
      String correctVal = UtilFunctions.removeCommas(row[5].toString().trim());

      // Answer options are columns 1 to 4
      for (int i = 1; i <= 4; i++) {
        if (i >= row.length) break;

        String optionText =
            UtilFunctions.removeCommas(row[i].toString().trim());
        AnswerOptions answer = AnswerOptions(
          body: Body(content: optionText, contentType: 'PLAIN'),
          isCorrect: optionText == correctVal,
        );
        checkBodyForKatex(answer.body);
        q.answerOptions?.add(answer);
      }

      // Ensure at least one correct answer if AI provided a valid one
      bool hasCorrect =
          q.answerOptions?.any((a) => a.isCorrect ?? false) ?? false;
      if (!hasCorrect && q.answerOptions!.isNotEmpty) {
        // Fallback: if none matched exactly, it might be a formatting issue.
        // We'll leave it as is for manual correction, or continue.
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
      snackBarAnimationStyle: const AnimationStyle(
          duration: Duration(seconds: 1),
          curve: Curves.easeIn,
          reverseCurve: Curves.bounceIn,
          reverseDuration: Duration(seconds: 1)),
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text('$addedQuestionCount new questions added successfully'),
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
    essays.clear();
    update();
  }

  void addEntry(String entry) {
    if (!useAiToGenerateEssay.value) {
      essays.insert(0, entry);
    } else {
      entries.insert(0, entry);
    }

    update();
  }

  void setGeneratingResponse(bool value, {String? message}) {
    generatingResponse.value = value;
    if (value && message != null) {
      loadingMessage.value = message;
    } else if (!value) {
      loadingMessage.value = "Processing...";
    }
    update();
  }

  void setInputControllerText(String text) {
    inputController.text = text;
    update();
  }

  Future<String?> askAI(Content instructions, String query) async {
    // Access your API key as an environment variable
    String modelName = selectedModel.value;

    final model = GenerativeModel(
      model:
          modelName, // The SDK handles 'models/' prefix internally if missing
      apiKey: apiKey.value,
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

      if (response.text == null) {
        throw 'The AI returned an empty response. Please try again.';
      }

      if (kDebugMode) {
        print(response.text);
      }
      return response.text;
    } catch (error) {
      if (kDebugMode) print('AI Error: $error');
      rethrow;
    }
  }

  Future<String?> getCsvResponse(String description) async {
    String count = useAiToGenerateEssay.value ? '30' : 'minimum 60';
    String finalInstructions = csvInstructions.value
        .replaceAll('{count}', count)
        .replaceAll('{language}', selectedLanguage.value)
        .replaceAll('{difficulty}', selectedDifficulty.value);

    final ins = Content.multi(
      finalInstructions
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => TextPart(s.trim()))
          .toList(),
    );
    String? csvResultRaw = await askAI(ins, description);
    return csvResultRaw;
  }

  Future<void> pickAndExtractFromPdf(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setGeneratingResponse(true, message: 'Extracting text from PDF...');
        File file = File(result.files.single.path!);
        final sf.PdfDocument document =
            sf.PdfDocument(inputBytes: file.readAsBytesSync());

        String extractedText = "";

        if (pdfPagesController.text.trim().isNotEmpty) {
          // Try to parse page range like "1-5, 8, 10-12"
          List<int> pages =
              _parsePageRange(pdfPagesController.text, document.pages.count);
          if (pages.isNotEmpty) {
            extractedText = sf.PdfTextExtractor(document).extractText(
                startPageIndex: pages.first - 1, endPageIndex: pages.last - 1);
          } else {
            extractedText = sf.PdfTextExtractor(document).extractText();
          }
        } else {
          extractedText = sf.PdfTextExtractor(document).extractText();
        }

        document.dispose();

        if (extractedText.trim().isNotEmpty) {
          inputController.text = extractedText;
          Get.snackbar('Success',
              'Extracted ${extractedText.length} characters from PDF',
              backgroundColor: Colors.green.withAlpha(100));
        } else {
          throw 'No text could be extracted from this PDF. It might be a scanned document (try Image OCR mode instead).';
        }
      }
    } catch (e) {
      Get.snackbar('Extraction Error', '$e',
          backgroundColor: Colors.red.withAlpha(100),
          duration: const Duration(seconds: 5));
    } finally {
      setGeneratingResponse(false);
    }
  }

  List<int> _parsePageRange(String input, int maxPages) {
    List<int> pages = [];
    try {
      final parts = input.split(RegExp(r'[,\s]+'));
      for (var part in parts) {
        if (part.contains('-')) {
          final range = part.split('-');
          int start = int.parse(range[0]);
          int end = int.parse(range[1]);
          for (int i = start; i <= end; i++) {
            if (i > 0 && i <= maxPages) pages.add(i);
          }
        } else {
          int page = int.parse(part);
          if (page > 0 && page <= maxPages) pages.add(page);
        }
      }
    } catch (e) {
      if (kDebugMode) print("Page parse error: $e");
    }
    pages.sort();
    return pages.toSet().toList(); // unique sorted pages
  }

  Future<void> pickAndExtractFromImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setGeneratingResponse(true, message: 'Recognizing text from image...');
        final inputImage = InputImage.fromFilePath(image.path);
        final textRecognizer =
            TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognizedText =
            await textRecognizer.processImage(inputImage);
        await textRecognizer.close();

        if (recognizedText.text.isNotEmpty) {
          inputController.text = recognizedText.text;
        } else {
          throw 'No text recognized in image';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to perform OCR: $e',
          backgroundColor: Colors.red.withAlpha(100));
    } finally {
      setGeneratingResponse(false);
    }
  }

  Future<void> getAIDescription(String text, BuildContext context) async {
    setGeneratingResponse(true, message: 'Generating MCQs with Gemini AI...');
    try {
      if (isPdfMode.value ||
          isManualEssayMode.value ||
          !useAiToGenerateEssay.value) {
        String fullPrompt = text;

        if (isPdfMode.value) {
          // Wrap text with PDF specific context if provided
          String pdfContext =
              "SOURCE MATERIAL (Extracted from PDF):\n$text\n\n";
          if (pdfInstructionsController.text.trim().isNotEmpty) {
            pdfContext +=
                "SPECIFIC INSTRUCTIONS: Focus on the following topic/chapter details: ${pdfInstructionsController.text}\n";
          }
          if (pdfPagesController.text.trim().isNotEmpty) {
            pdfContext +=
                "TARGET SCOPE: This content is from pages ${pdfPagesController.text} of the document.\n";
          }
          fullPrompt = pdfContext;
        }

        String? csvResponse = await getCsvResponse(fullPrompt);
        if (csvResponse != null) {
          if (context.mounted) {
            setCSV(csvResponse);
            addQuestions(context);
          }
        }
      } else {
        String finalEssayInstructions = essayInstructions.value
            .replaceAll('{subject}', subject.value)
            .replaceAll('{topic}', topicID.value);

        final instructions = Content.multi(
          finalEssayInstructions
              .split('\n')
              .where((s) => s.trim().isNotEmpty)
              .map((s) => TextPart(s.trim()))
              .toList(),
        );

        String? generatedDescription = await askAI(instructions, text);

        if (generatedDescription != null) {
          String? csvFromEssay = await getCsvResponse(generatedDescription);
          if (csvFromEssay != null) {
            if (context.mounted) {
              setCSV(csvFromEssay);
              addQuestions(context);
            }
          }
        }
      }
    } catch (e) {
      String errorMessage = 'An unexpected error occurred';

      if (e.toString().contains('key not found') ||
          e.toString().contains('API_KEY_INVALID')) {
        errorMessage = 'Invalid API Key. Please check your settings.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('recitation') ||
          e.toString().contains('blocked')) {
        errorMessage = 'Content was blocked by safety filters.';
      } else if (e.toString().contains('quota')) {
        errorMessage = 'API quota exceeded. Please try again later.';
      } else {
        errorMessage = e.toString();
      }

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Generation Failed'),
              ],
            ),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        );
      }
    } finally {
      setGeneratingResponse(false);
    }
  }

  void setCSV(String value) {
    csvOutput.value = value;
    update();
  }

  void deleteQuestion(int questionIndex) {
    questions.removeAt(questionIndex);
    update();
  }

  void updateChapter(String text) {
    topicID.value = text;
    update();
  }

  void updateSubject(String text) {
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
      RegExp(r'<sub>(.*?)</sub>'),
      (match) => '_{${match.group(1)}}',
    );

    // Replace <sup> tags with KaTeX superscript syntax
    katex = katex.replaceAllMapped(
      RegExp(r'<sup>(.*?)</sup>'),
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

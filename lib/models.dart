class Question {
  Body? body;
  String? status;
  int? assignedPoints;
  List<AnswerOptions>? answerOptions;
  String? topicId;
  String? subjectId;

  Question(
      {this.body,
      this.status,
      this.assignedPoints,
      this.answerOptions,
      this.topicId,
      this.subjectId});

  Question.fromJson(Map<String, dynamic> json) {
    body = json['body'] != null ? Body.fromJson(json['body']) : null;
    status = json['status'];
    assignedPoints = json['assignedPoints'];
    if (json['answerOptions'] != null) {
      answerOptions = <AnswerOptions>[];
      json['answerOptions'].forEach((v) {
        answerOptions!.add(AnswerOptions.fromJson(v));
      });
    }
    topicId = json['topicId'];
    subjectId = json['subjectId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (body != null) {
      data['body'] = body!.toJson();
    }
    data['status'] = status;
    data['assignedPoints'] = assignedPoints;
    if (answerOptions != null) {
      data['answerOptions'] = answerOptions!.map((v) => v.toJson()).toList();
    }
    data['topicId'] = topicId;
    data['subjectId'] = subjectId;
    return data;
  }
}

class Body {
  String? content;
  String? contentType;

  Body({this.content, this.contentType});

  Body.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    contentType = json['contentType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content'] = content;
    data['contentType'] = contentType;
    return data;
  }
}

class AnswerOptions {
  Body? body;
  bool? isCorrect;

  AnswerOptions({this.body, this.isCorrect});

  AnswerOptions.fromJson(Map<String, dynamic> json) {
    body = json['body'] != null ? Body.fromJson(json['body']) : null;
    isCorrect = json['isCorrect'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (body != null) {
      data['body'] = body!.toJson();
    }
    data['isCorrect'] = isCorrect;
    return data;
  }
}

class InputQuestions {
  List<Values> values = [];

  InputQuestions({required this.values});

  InputQuestions.fromJson(Map<String, dynamic> json) {
    if (json['values'] != null) {
      values = <Values>[];
      json['values'].forEach((v) {
        List<String> a = [];
        Map<String, dynamic> b = v;
        for (var st in b.entries) {
          a.add(st.value.toString());
        }
        values.add(
          Values(
            answers: a,
            correctAnswerIndices: v.correctAnswerIndices,
            correctAnswers: v.correctAnswer,
            explanation: v.explanation,
            question: v.question,
          ),
        );
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['values'] = values.map((v) => v.toJson()).toList();
    return data;
  }
}

class Values {
  String question;
  String explanation;
  List<String> answers;
  List<dynamic> correctAnswerIndices;
  List<dynamic> correctAnswers;

  Values(
      {required this.question,
      required this.explanation,
      required this.answers,
      required this.correctAnswerIndices,
      required this.correctAnswers});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['question'] = question;
    data['explanation'] = explanation;
    data['answers'] = answers;
    data['correct_answer_indices'] = correctAnswerIndices;
    data['correct_answers'] = correctAnswers;
    return data;
  }
}

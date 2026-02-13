import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
    );
  }
}

class AssessmentModel {
  final String id;
  final String title; // This is the Subtitle in the new requirements
  final String setName; // The CSV file name / Set name
  final String description; // Description for the sub-test
  final String type; // 'technical' or 'non_technical'
  final bool isFree;
  final double price;
  final List<Question> questions;
  final int timeLimitMinutes;
  final int passingMarks;
  final DateTime createdAt;

  AssessmentModel({
    required this.id,
    required this.title,
    required this.setName,
    required this.description,
    required this.type,
    this.isFree = true,
    this.price = 0.0,
    required this.questions,
    this.timeLimitMinutes = 15,
    this.passingMarks = 9,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'setName': setName,
      'description': description,
      'type': type,
      'isFree': isFree,
      'price': price,
      'questions': questions.map((q) => q.toMap()).toList(),
      'timeLimitMinutes': timeLimitMinutes,
      'passingMarks': passingMarks,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AssessmentModel.fromMap(Map<String, dynamic> map, String docId) {
    return AssessmentModel(
      id: docId,
      title: map['title'] ?? '',
      setName: map['setName'] ?? 'General',
      description: map['description'] ?? '',
      type: map['type'] ?? 'technical',
      isFree: map['isFree'] ?? true,
      price: (map['price'] ?? 0.0).toDouble(),
      questions:
          (map['questions'] as List<dynamic>? ?? [])
              .map((q) => Question.fromMap(q as Map<String, dynamic>))
              .toList(),
      timeLimitMinutes: map['timeLimitMinutes'] ?? 15,
      passingMarks: map['passingMarks'] ?? 9,
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : (map['createdAt'] is DateTime
                  ? map['createdAt'] as DateTime
                  : DateTime.now()),
    );
  }

  AssessmentModel copyWith({
    String? id,
    String? title,
    String? setName,
    String? description,
    String? type,
    bool? isFree,
    double? price,
    List<Question>? questions,
    int? timeLimitMinutes,
    int? passingMarks,
    DateTime? createdAt,
  }) {
    return AssessmentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      setName: setName ?? this.setName,
      description: description ?? this.description,
      type: type ?? this.type,
      isFree: isFree ?? this.isFree,
      price: price ?? this.price,
      questions: questions ?? this.questions,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      passingMarks: passingMarks ?? this.passingMarks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

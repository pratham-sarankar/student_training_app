import 'package:cloud_firestore/cloud_firestore.dart';

class AssessmentResult {
  final String id;
  final String assessmentId;
  final String userId;
  final int score;
  final int totalQuestions;
  final Map<int, int> selectedAnswers; // QuestionIndex: OptionIndex
  final DateTime timestamp;

  AssessmentResult({
    required this.id,
    required this.assessmentId,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.selectedAnswers,
    required this.timestamp,
  });

  double get percentage =>
      totalQuestions == 0 ? 0 : (score / totalQuestions) * 100;

  Map<String, dynamic> toMap() {
    return {
      'assessmentId': assessmentId,
      'userId': userId,
      'score': score,
      'totalQuestions': totalQuestions,
      'selectedAnswers': selectedAnswers.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory AssessmentResult.fromMap(Map<String, dynamic> map, String docId) {
    // Handle selectedAnswers potentially being saved as String keys in Firestore
    Map<int, int> answers = {};
    if (map['selectedAnswers'] != null) {
      (map['selectedAnswers'] as Map<dynamic, dynamic>).forEach((k, v) {
        answers[int.parse(k.toString())] = v as int;
      });
    }

    return AssessmentResult(
      id: docId,
      assessmentId: map['assessmentId'] ?? '',
      userId: map['userId'] ?? '',
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      selectedAnswers: answers,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

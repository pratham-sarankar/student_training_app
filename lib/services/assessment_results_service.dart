import 'package:flutter/foundation.dart';

class AssessmentResult {
  final int score;
  final int total;
  final DateTime timestamp;

  AssessmentResult({
    required this.score,
    required this.total,
    required this.timestamp,
  });

  double get percentage => total == 0 ? 0 : (score / total) * 100;
}

class AssessmentResultsService {
  static final AssessmentResultsService _instance =
      AssessmentResultsService._internal();

  factory AssessmentResultsService() {
    return _instance;
  }

  AssessmentResultsService._internal();

  // Map of assessmentId -> Result
  final Map<String, AssessmentResult> _results = {};

  void saveResult(String id, int score, int total) {
    _results[id] = AssessmentResult(
      score: score,
      total: total,
      timestamp: DateTime.now(),
    );
    debugPrint("Saved result for $id: $score/$total");
  }

  AssessmentResult? getResult(String id) {
    return _results[id];
  }

  /// Analyze performance for a given set of assessments
  /// Returns a map with 'strong', 'weak', 'average' lists of titles
  Map<String, List<String>> analyzePerformance(List<dynamic> assessments) {
    List<String> strong = [];
    List<String> weak = [];
    List<String> average = [];

    for (var assessment in assessments) {
      if (assessment is! Map<String, dynamic>) continue;

      String id = assessment['id'];
      String title = assessment['title'];

      if (_results.containsKey(id)) {
        double percentage = _results[id]!.percentage;
        if (percentage >= 70) {
          strong.add(title);
        } else if (percentage < 40) {
          weak.add(title);
        } else {
          average.add(title);
        }
      }
    }

    return {'strong': strong, 'weak': weak, 'average': average};
  }

  bool hasTakenAny(List<dynamic> assessments) {
    for (var assessment in assessments) {
      if (assessment is Map<String, dynamic> &&
          _results.containsKey(assessment['id'])) {
        return true;
      }
    }
    return false;
  }

  double getAverageScore(List<dynamic> assessments) {
    int totalScore = 0;
    int totalQuestions = 0;

    for (var assessment in assessments) {
      if (assessment is Map<String, dynamic> &&
          _results.containsKey(assessment['id'])) {
        var result = _results[assessment['id']]!;
        totalScore += result.score;
        totalQuestions += result.total;
      }
    }

    if (totalQuestions == 0) return 0.0;
    return (totalScore / totalQuestions) * 100;
  }
}

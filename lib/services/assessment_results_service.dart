import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/assessment_result.dart';
import '../models/assessment_model.dart';

class AssessmentResultsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final AssessmentResultsService _instance =
      AssessmentResultsService._internal();

  factory AssessmentResultsService() {
    return _instance;
  }

  AssessmentResultsService._internal();

  // Reference to results collection
  CollectionReference get _resultsRef =>
      _firestore.collection('assessment_results');

  /// Save a test result to Firestore
  Future<void> saveResult(AssessmentResult result) async {
    try {
      await _resultsRef.add(result.toMap());
      debugPrint("Saved result for ${result.assessmentId} to Firestore");
    } catch (e) {
      debugPrint("Error saving result: $e");
      rethrow;
    }
  }

  /// Check if a user has already taken a specific test
  Future<AssessmentResult?> getResult(
    String userId,
    String assessmentId,
  ) async {
    try {
      final snapshot =
          await _resultsRef
              .where('userId', isEqualTo: userId)
              .where('assessmentId', isEqualTo: assessmentId)
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return AssessmentResult.fromMap(
          snapshot.docs.first.data() as Map<String, dynamic>,
          snapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      debugPrint("Error getting result: $e");
      return null;
    }
  }

  /// Stream of results for a specific user to keep UI updated
  Stream<List<AssessmentResult>> getUserResults(String userId) {
    return _resultsRef.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return AssessmentResult.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Analyze performance for a given set of assessments
  /// Returns a map with 'strong', 'weak', 'average' lists of titles
  Map<String, List<String>> analyzePerformance(
    List<dynamic> assessments,
    List<AssessmentResult> results,
  ) {
    List<String> strong = [];
    List<String> weak = [];
    List<String> average = [];

    final resultsMap = {for (var r in results) r.assessmentId: r};

    for (var assessment in assessments) {
      String id;
      String title;

      if (assessment is Map<String, dynamic>) {
        id = assessment['id'];
        title = assessment['title'];
      } else if (assessment is AssessmentModel) {
        id = assessment.id;
        title = assessment.title;
      } else {
        continue;
      }

      if (resultsMap.containsKey(id)) {
        double percentage = resultsMap[id]!.percentage;
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
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assessment_model.dart';

class AssessmentService {
  final CollectionReference _assessmentsCollection = FirebaseFirestore.instance
      .collection('assessments');

  // Add a new assessment
  Future<void> addAssessment(AssessmentModel assessment) async {
    await _assessmentsCollection.add(assessment.toMap());
  }

  // Get all assessments stream
  Stream<List<AssessmentModel>> getAssessments() {
    return _assessmentsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AssessmentModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // Delete an assessment
  Future<void> deleteAssessment(String id) async {
    await _assessmentsCollection.doc(id).delete();
  }
}

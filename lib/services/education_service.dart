import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learn_work/models/education.dart';

class EducationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Create or update education details
  Future<void> createOrUpdateEducation(EducationModel educationModel) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      String educationId;
      
      // If education model has an ID, update existing document
      if (educationModel.id != null) {
        educationId = educationModel.id!;
        await _firestore
            .collection('education')
            .doc(educationId)
            .set(educationModel.toMap(), SetOptions(merge: true));
      } else {
        // Create new document
        final docRef = await _firestore.collection('education').add(educationModel.toMap());
        educationId = docRef.id;
      }

      // Update user's educationId reference
      await _firestore.collection('users').doc(user.uid).update({
        'educationId': educationId,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to create/update education: $e');
    }
  }

  // Get education details for current user
  Future<EducationModel?> getCurrentUserEducation() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final querySnapshot = await _firestore
          .collection('education')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return EducationModel.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get education: $e');
    }
  }

  // Update education details
  Future<void> updateEducation({
    bool? isCurrentlyPursuing,
    String? highestEducation,
    String? degree,
    String? specialization,
    String? collegeName,
    int? completionYear,
    String? medium,
    List<String>? careerGoals,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get current education data
      EducationModel? currentEducation = await getCurrentUserEducation();
      
      if (currentEducation != null) {
        // Update existing education
        final updatedEducation = currentEducation.copyWith(
          isCurrentlyPursuing: isCurrentlyPursuing,
          highestEducation: highestEducation,
          degree: degree,
          specialization: specialization,
          collegeName: collegeName,
          completionYear: completionYear,
          medium: medium,
          careerGoals: careerGoals,
        );

        await createOrUpdateEducation(updatedEducation);
      } else {
        // Create new education record
        final newEducation = EducationModel(
          userId: user.uid,
          isCurrentlyPursuing: isCurrentlyPursuing ?? false,
          highestEducation: highestEducation,
          degree: degree,
          specialization: specialization,
          collegeName: collegeName,
          completionYear: completionYear,
          medium: medium,
          careerGoals: careerGoals ?? [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await createOrUpdateEducation(newEducation);
      }
    } catch (e) {
      throw Exception('Failed to update education: $e');
    }
  }

  // Delete education details
  Future<void> deleteEducation() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      final currentEducation = await getCurrentUserEducation();
      if (currentEducation?.id != null) {
        await _firestore
            .collection('education')
            .doc(currentEducation!.id)
            .delete();
      }
    } catch (e) {
      throw Exception('Failed to delete education: $e');
    }
  }

  // Get education by user ID
  Future<EducationModel?> getEducationByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('education')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return EducationModel.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get education by user ID: $e');
    }
  }

  // Get all education records (for admin purposes)
  Future<List<EducationModel>> getAllEducation() async {
    try {
      final snapshot = await _firestore.collection('education').get();
      return snapshot.docs.map((doc) => 
        EducationModel.fromMap(doc.data(), doc.id)
      ).toList();
    } catch (e) {
      throw Exception('Failed to get all education records: $e');
    }
  }

  // Check if user has completed education profile
  Future<bool> hasCompletedEducation() async {
    try {
      final education = await getCurrentUserEducation();
      return education?.isComplete ?? false;
    } catch (e) {
      return false;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gradspark/models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Create or update user document with UserModel
  Future<void> createOrUpdateUser(UserModel userModel) async {
    try {
      await _firestore
          .collection('users')
          .doc(userModel.uid)
          .set(userModel.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create/update user: $e');
    }
  }

  // Create or update user with basic info
  Future<void> createOrUpdateUserBasic({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    String? photoUrl,
    String? phoneNumber,
    String? location,
  }) async {
    try {
      final userModel = UserModel(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        photoUrl: photoUrl,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        location: location,
      );

      await createOrUpdateUser(userModel);
    } catch (e) {
      throw Exception('Failed to create/update user: $e');
    }
  }

  // Get user by ID as UserModel
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Get current user data as UserModel
  Future<UserModel?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;

    return await getUserById(user.uid);
  }

  // Get current user data with fallback to Firebase Auth
  Future<UserModel?> getCurrentUserDataWithFallback() async {
    final user = currentUser;
    if (user == null) return null;

    // Try to get from Firestore first
    UserModel? userModel = await getUserById(user.uid);

    if (userModel != null) {
      return userModel;
    }

    // If not in Firestore, create from Firebase Auth
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      final nameParts = user.displayName!.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      userModel = UserModel(
        uid: user.uid,
        firstName: firstName,
        lastName: lastName,
        email: user.email ?? '',
        photoUrl: user.photoURL,
        isEmailVerified: user.emailVerified,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await createOrUpdateUser(userModel);
      return userModel;
    }

    return null;
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? photoUrl,
    String? bio,
    String? gender,
    DateTime? dateOfBirth,
    bool? emailNotifications,
    bool? pushNotifications,

    List<String>? jobCategories,
    List<String>? preferredLocations,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Get current user data
      UserModel? currentUserModel = await getUserById(user.uid);

      if (currentUserModel != null) {
        // Update with new values
        final updatedUser = currentUserModel.copyWith(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          photoUrl: photoUrl,
          bio: bio,
          gender: gender,
          dateOfBirth: dateOfBirth,
          emailNotifications: emailNotifications,
          pushNotifications: pushNotifications,

          jobCategories: jobCategories,
          preferredLocations: preferredLocations,
        );

        await createOrUpdateUser(updatedUser);
      } else {
        // Create new user if doesn't exist
        final newUser = UserModel(
          uid: user.uid,
          firstName: firstName ?? '',
          lastName: lastName ?? '',
          email: user.email ?? '',
          phoneNumber: phoneNumber,
          photoUrl: photoUrl,
          bio: bio,
          gender: gender,
          dateOfBirth: dateOfBirth,
          isEmailVerified: user.emailVerified,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
          updatedAt: DateTime.now(),
          emailNotifications: emailNotifications ?? true,
          pushNotifications: pushNotifications ?? true,

          jobCategories: jobCategories ?? [],
          preferredLocations: preferredLocations ?? [],
        );

        await createOrUpdateUser(newUser);
      }

      // Update Firebase Auth display name if name changed
      if (firstName != null || lastName != null) {
        final newDisplayName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
        if (newDisplayName.isNotEmpty) {
          await user.updateDisplayName(newDisplayName);
        }
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Update user verification status
  Future<void> updateVerificationStatus({
    bool? isEmailVerified,
    bool? isPhoneVerified,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final currentUserModel = await getUserById(user.uid);
      if (currentUserModel != null) {
        final updatedUser = currentUserModel.copyWith(
          isEmailVerified: isEmailVerified,
          isPhoneVerified: isPhoneVerified,
        );
        await createOrUpdateUser(updatedUser);
      }
    } catch (e) {
      throw Exception('Failed to update verification status: $e');
    }
  }

  // Save job to user's saved jobs
  Future<void> saveJob(String jobId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final currentUserModel = await getUserById(user.uid);
      if (currentUserModel != null) {
        if (!currentUserModel.hasSavedJob(jobId)) {
          final updatedUser = currentUserModel.copyWith(
            savedJobs: [...currentUserModel.savedJobs, jobId],
          );
          await createOrUpdateUser(updatedUser);
        }
      }
    } catch (e) {
      throw Exception('Failed to save job: $e');
    }
  }

  // Remove job from saved jobs
  Future<void> unsaveJob(String jobId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final currentUserModel = await getUserById(user.uid);
      if (currentUserModel != null) {
        if (currentUserModel.hasSavedJob(jobId)) {
          final updatedSavedJobs = List<String>.from(currentUserModel.savedJobs)
            ..remove(jobId);

          final updatedUser = currentUserModel.copyWith(
            savedJobs: updatedSavedJobs,
          );
          await createOrUpdateUser(updatedUser);
        }
      }
    } catch (e) {
      throw Exception('Failed to unsave job: $e');
    }
  }

  // Apply to job
  Future<void> applyToJob(String jobId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final currentUserModel = await getUserById(user.uid);
      if (currentUserModel != null) {
        if (!currentUserModel.hasAppliedToJob(jobId)) {
          final updatedUser = currentUserModel.copyWith(
            appliedJobs: [...currentUserModel.appliedJobs, jobId],
          );
          await createOrUpdateUser(updatedUser);
        }
      }
    } catch (e) {
      throw Exception('Failed to apply to job: $e');
    }
  }

  // Enroll in course
  Future<void> enrollInCourse(String courseId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final currentUserModel = await getUserById(user.uid);
      if (currentUserModel != null) {
        if (!currentUserModel.enrolledCourses.contains(courseId)) {
          final updatedUser = currentUserModel.copyWith(
            enrolledCourses: [...currentUserModel.enrolledCourses, courseId],
          );
          await createOrUpdateUser(updatedUser);
        }
      }
    } catch (e) {
      throw Exception('Failed to enroll in course: $e');
    }
  }

  // Purchase assessment
  Future<void> purchaseAssessment(String assessmentId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final currentUserModel = await getUserById(user.uid);
      if (currentUserModel != null) {
        if (!currentUserModel.purchasedAssessments.contains(assessmentId)) {
          final updatedUser = currentUserModel.copyWith(
            purchasedAssessments: [
              ...currentUserModel.purchasedAssessments,
              assessmentId,
            ],
          );
          await createOrUpdateUser(updatedUser);
        }
      }
    } catch (e) {
      throw Exception('Failed to purchase assessment: $e');
    }
  }

  // Search users by name or email
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final currentUser = this.currentUser;
      if (currentUser == null) return [];

      // Search by first name (case-insensitive)
      final firstNameQuery =
          await _firestore
              .collection('users')
              .where('firstName', isGreaterThanOrEqualTo: query)
              .where('firstName', isLessThan: query + '\uf8ff')
              .get();

      // Search by last name (case-insensitive)
      final lastNameQuery =
          await _firestore
              .collection('users')
              .where('lastName', isGreaterThanOrEqualTo: query)
              .where('lastName', isLessThan: query + '\uf8ff')
              .get();

      // Search by email (case-insensitive)
      final emailQuery =
          await _firestore
              .collection('users')
              .where('email', isGreaterThanOrEqualTo: query)
              .where('email', isLessThan: query + '\uf8ff')
              .get();

      // Combine and deduplicate results
      final allDocs = [
        ...firstNameQuery.docs,
        ...lastNameQuery.docs,
        ...emailQuery.docs,
      ];
      final uniqueDocs = <String, DocumentSnapshot>{};

      for (final doc in allDocs) {
        uniqueDocs[doc.id] = doc;
      }

      // Filter out current user and convert to UserModel list
      return uniqueDocs.values
          .where((doc) => doc.id != currentUser.uid)
          .map(
            (doc) =>
                UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Delete user account
  Future<void> deleteUserAccount() async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Delete user document
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete user authentication
      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Get all users (for admin purposes)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }

  // Get users by role
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: role)
              .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users by role: $e');
    }
  }
}

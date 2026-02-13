import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;
  final String? bio;
  final String? gender;
  final DateTime? dateOfBirth;
  final String role;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? location;

  // Preferences and settings
  final bool emailNotifications;
  final bool pushNotifications;

  final List<String> jobCategories;
  final List<String> preferredLocations;

  // Job-related
  final List<String> savedJobs;
  final List<String> appliedJobs;

  // Enrollment and Purchases
  final List<String> enrolledCourses;
  final List<String> purchasedAssessments;

  // Education-related
  final String? educationId;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
    this.bio,
    this.gender,
    this.dateOfBirth,
    this.role = 'Student',
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.emailNotifications = true,
    this.pushNotifications = true,

    this.jobCategories = const [],
    this.preferredLocations = const [],
    this.savedJobs = const [],
    this.appliedJobs = const [],
    this.enrolledCourses = const [],
    this.purchasedAssessments = const [],
    this.educationId,
    this.location,
  });

  // Getter for full name
  String get fullName => '$firstName $lastName'.trim();

  // Getter for display name (first name only if last name is empty)
  String get displayName => lastName.isNotEmpty ? fullName : firstName;

  // Getter for initials
  String get initials {
    if (lastName.isNotEmpty) {
      return '${firstName.isNotEmpty ? firstName[0].toUpperCase() : ''}${lastName[0].toUpperCase()}';
    }
    return firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
  }

  // Create from Firebase Auth User
  factory UserModel.fromFirebaseUser(
    User user, {
    String? phoneNumber,
    String? bio,
    String? gender,
    DateTime? dateOfBirth,
    List<String>? jobCategories,
    List<String>? preferredLocations,
    List<String>? savedJobs,
    List<String>? appliedJobs,
  }) {
    final nameParts = (user.displayName ?? '').split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return UserModel(
      uid: user.uid,
      firstName: firstName,
      lastName: lastName,
      email: user.email ?? '',
      phoneNumber: phoneNumber,
      photoUrl: user.photoURL,
      bio: bio,
      gender: gender,
      dateOfBirth: dateOfBirth,
      isEmailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
      jobCategories: jobCategories ?? [],
      preferredLocations: preferredLocations ?? [],
      savedJobs: savedJobs ?? [],
      appliedJobs: appliedJobs ?? [],
      enrolledCourses: const [],
      purchasedAssessments: const [],
    );
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      photoUrl: map['photoUrl'],
      bio: map['bio'],
      gender: map['gender'],
      dateOfBirth:
          map['dateOfBirth'] is Timestamp
              ? (map['dateOfBirth'] as Timestamp).toDate()
              : (map['dateOfBirth'] is DateTime
                  ? map['dateOfBirth'] as DateTime
                  : (map['dateOfBirth'] is String
                      ? DateTime.tryParse(map['dateOfBirth'])
                      : null)),
      role: map['role'] ?? 'Student',
      isEmailVerified: map['isEmailVerified'] ?? false,
      isPhoneVerified: map['isPhoneVerified'] ?? false,
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : (map['createdAt'] is DateTime
                  ? map['createdAt'] as DateTime
                  : DateTime.now()),
      updatedAt:
          map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : (map['updatedAt'] is DateTime
                  ? map['updatedAt'] as DateTime
                  : DateTime.now()),
      emailNotifications: map['emailNotifications'] ?? true,
      pushNotifications: map['pushNotifications'] ?? true,

      jobCategories: List<String>.from(map['jobCategories'] ?? []),
      preferredLocations: List<String>.from(map['preferredLocations'] ?? []),
      savedJobs: List<String>.from(map['savedJobs'] ?? []),
      appliedJobs: List<String>.from(map['appliedJobs'] ?? []),
      enrolledCourses: List<String>.from(map['enrolledCourses'] ?? []),
      purchasedAssessments: List<String>.from(
        map['purchasedAssessments'] ?? [],
      ),
      educationId: map['educationId'],
      location: map['location'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'bio': bio,
      'gender': gender,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'role': role,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,

      'jobCategories': jobCategories,
      'preferredLocations': preferredLocations,
      'savedJobs': savedJobs,
      'appliedJobs': appliedJobs,
      'enrolledCourses': enrolledCourses,
      'purchasedAssessments': purchasedAssessments,
      'educationId': educationId,
      'location': location,
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    String? bio,
    String? gender,
    DateTime? dateOfBirth,
    String? role,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? emailNotifications,
    bool? pushNotifications,

    List<String>? jobCategories,
    List<String>? preferredLocations,
    List<String>? savedJobs,
    List<String>? appliedJobs,
    List<String>? enrolledCourses,
    List<String>? purchasedAssessments,
    String? educationId,
    String? location,
  }) {
    return UserModel(
      uid: uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,

      jobCategories: jobCategories ?? this.jobCategories,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      savedJobs: savedJobs ?? this.savedJobs,
      appliedJobs: appliedJobs ?? this.appliedJobs,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      purchasedAssessments: purchasedAssessments ?? this.purchasedAssessments,
      educationId: educationId ?? this.educationId,
      location: location ?? this.location,
    );
  }

  // Check if user has completed profile
  bool get hasCompletedProfile {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        phoneNumber != null &&
        phoneNumber!.isNotEmpty &&
        dateOfBirth != null;
  }

  // Check if user is verified
  bool get isVerified => isEmailVerified || isPhoneVerified;

  // Get user age
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Get formatted date of birth
  String? get formattedDateOfBirth {
    if (dateOfBirth == null) return null;
    return '${dateOfBirth!.day.toString().padLeft(2, '0')}/${dateOfBirth!.month.toString().padLeft(2, '0')}/${dateOfBirth!.year}';
  }

  // Check if user has saved a specific job
  bool hasSavedJob(String jobId) {
    return savedJobs.contains(jobId);
  }

  // Check if user has applied to a specific job
  bool hasAppliedToJob(String jobId) {
    return appliedJobs.contains(jobId);
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $fullName, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}

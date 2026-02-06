import 'package:cloud_firestore/cloud_firestore.dart';

class EducationModel {
  final String? id;
  final String userId;
  final bool isCurrentlyPursuing;
  final String? highestEducation;
  final String? degree;
  final String? specialization;
  final String? collegeName;
  final int? completionYear;
  final String? medium;
  final List<String> careerGoals;
  final String? resumeFileName;
  final String? resumeUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  EducationModel({
    this.id,
    required this.userId,
    required this.isCurrentlyPursuing,
    this.highestEducation,
    this.degree,
    this.specialization,
    this.collegeName,
    this.completionYear,
    this.medium,
    this.careerGoals = const [],
    this.resumeFileName,
    this.resumeUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create from Firestore document
  factory EducationModel.fromMap(Map<String, dynamic> map, String id) {
    return EducationModel(
      id: id,
      userId: map['userId'] ?? '',
      isCurrentlyPursuing: map['isCurrentlyPursuing'] ?? false,
      highestEducation: map['highestEducation'],
      degree: map['degree'],
      specialization: map['specialization'],
      collegeName: map['collegeName'],
      completionYear: map['completionYear'],
      medium: map['medium'],
      careerGoals: List<String>.from(map['careerGoals'] ?? []),
      resumeFileName: map['resumeFileName'],
      resumeUrl: map['resumeUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'isCurrentlyPursuing': isCurrentlyPursuing,
      'highestEducation': highestEducation,
      'degree': degree,
      'specialization': specialization,
      'collegeName': collegeName,
      'completionYear': completionYear,
      'medium': medium,
      'careerGoals': careerGoals,
      'resumeFileName': resumeFileName,
      'resumeUrl': resumeUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create a copy with updated fields
  EducationModel copyWith({
    String? id,
    String? userId,
    bool? isCurrentlyPursuing,
    String? highestEducation,
    String? degree,
    String? specialization,
    String? collegeName,
    int? completionYear,
    String? medium,
    List<String>? careerGoals,
    String? resumeFileName,
    String? resumeUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EducationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      isCurrentlyPursuing: isCurrentlyPursuing ?? this.isCurrentlyPursuing,
      highestEducation: highestEducation ?? this.highestEducation,
      degree: degree ?? this.degree,
      specialization: specialization ?? this.specialization,
      collegeName: collegeName ?? this.collegeName,
      completionYear: completionYear ?? this.completionYear,
      medium: medium ?? this.medium,
      careerGoals: careerGoals ?? this.careerGoals,
      resumeFileName: resumeFileName ?? this.resumeFileName,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Check if education details are complete
  bool get isComplete {
    return highestEducation != null &&
        highestEducation!.isNotEmpty &&
        degree != null &&
        degree!.isNotEmpty &&
        specialization != null &&
        specialization!.isNotEmpty &&
        collegeName != null &&
        collegeName!.isNotEmpty &&
        completionYear != null &&
        medium != null &&
        medium!.isNotEmpty &&
        careerGoals.isNotEmpty;
  }

  @override
  String toString() {
    return 'EducationModel(id: $id, userId: $userId, degree: $degree, specialization: $specialization)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EducationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

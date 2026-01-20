import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String title;
  final String category;
  final String description;
  final double cost;
  final String duration;
  final String level;
  final String tentativeStartDate;
  final DateTime createdAt;
  final bool isActive;
  final double enrollmentFee;
  final String instructor;
  final List<String> topics;
  final String requirements;
  final String outcomes;

  Course({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.cost,
    required this.enrollmentFee,
    required this.duration,
    required this.level,
    required this.tentativeStartDate,
    required this.createdAt,
    required this.isActive,
    required this.instructor,
    required this.topics,
    required this.requirements,
    required this.outcomes,
  });

  factory Course.fromMap(Map<String, dynamic> map, String id) {
    return Course(
      id: id,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      cost: (map['cost'] ?? 0.0).toDouble(),
      enrollmentFee: (map['enrollmentFee'] ?? 0.0).toDouble(),
      duration: map['duration'] ?? '',
      level: map['level'] ?? '',
      tentativeStartDate: map['tentativeStartDate'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      instructor: map['instructor'] ?? '',
      topics: List<String>.from(map['topics'] ?? []),
      requirements: map['requirements'] ?? '',
      outcomes: map['outcomes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'description': description,
      'cost': cost,
      'enrollmentFee': enrollmentFee,
      'duration': duration,
      'level': level,
      'tentativeStartDate': tentativeStartDate,
      'createdAt': createdAt,
      'isActive': isActive,
      'instructor': instructor,
      'topics': topics,
      'requirements': requirements,
      'outcomes': outcomes,
    };
  }

  Course copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    double? cost,
    double? enrollmentFee,
    String? duration,
    String? level,
    String? tentativeStartDate,
    DateTime? createdAt,
    bool? isActive,
    String? instructor,
    List<String>? topics,
    String? requirements,
    String? outcomes,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      enrollmentFee: enrollmentFee ?? this.enrollmentFee,
      duration: duration ?? this.duration,
      level: level ?? this.level,
      tentativeStartDate: tentativeStartDate ?? this.tentativeStartDate,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      instructor: instructor ?? this.instructor,
      topics: topics ?? this.topics,
      requirements: requirements ?? this.requirements,
      outcomes: outcomes ?? this.outcomes,
    );
  }
}

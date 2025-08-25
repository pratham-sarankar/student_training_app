import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String title;
  final String category;
  final String description;
  final double cost;
  final String duration;
  final String level;
  final String image;
  final List<Map<String, dynamic>> schedules;
  final DateTime createdAt;
  final bool isActive;
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
    required this.duration,
    required this.level,
    required this.image,
    required this.schedules,
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
      duration: map['duration'] ?? '',
      level: map['level'] ?? '',
      image: map['image'] ?? '',
      schedules: List<Map<String, dynamic>>.from(map['schedules'] ?? []),
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
      'duration': duration,
      'level': level,
      'image': image,
      'schedules': schedules,
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
    String? duration,
    String? level,
    String? image,
    List<Map<String, dynamic>>? schedules,
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
      duration: duration ?? this.duration,
      level: level ?? this.level,
      image: image ?? this.image,
      schedules: schedules ?? this.schedules,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      instructor: instructor ?? this.instructor,
      topics: topics ?? this.topics,
      requirements: requirements ?? this.requirements,
      outcomes: outcomes ?? this.outcomes,
    );
  }
}

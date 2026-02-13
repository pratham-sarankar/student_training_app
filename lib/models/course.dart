import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String domain;
  final String recommendedCourses;
  final double cost;
  final String duration;
  final String mode;
  final String days;
  final String timing;
  final String type; // Summer Training or Job Oriented Training
  final double enrollmentFee;
  final bool hasFreeDemo;
  final DateTime createdAt;
  final bool isActive;

  // Compatibility getters for existing UI
  String get title => domain;
  String get category => type;
  String get description => recommendedCourses;

  Course({
    required this.id,
    required this.domain,
    required this.recommendedCourses,
    required this.cost,
    required this.duration,
    required this.mode,
    required this.days,
    required this.timing,
    required this.type,
    required this.enrollmentFee,
    required this.hasFreeDemo,
    required this.createdAt,
    required this.isActive,
  });

  factory Course.fromMap(Map<String, dynamic> map, String id) {
    return Course(
      id: id,
      domain: map['domain'] ?? '',
      recommendedCourses: map['recommendedCourses'] ?? '',
      cost: (map['cost'] ?? 0.0).toDouble(),
      duration: map['duration'] ?? '',
      mode: map['mode'] ?? '',
      days: map['days'] ?? '',
      timing: map['timing'] ?? '',
      type: map['type'] ?? '',
      enrollmentFee: (map['enrollmentFee'] ?? 500.0).toDouble(),
      hasFreeDemo: map['hasFreeDemo'] ?? false,
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : (map['createdAt'] is DateTime
                  ? map['createdAt'] as DateTime
                  : DateTime.now()),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'domain': domain,
      'recommendedCourses': recommendedCourses,
      'cost': cost,
      'duration': duration,
      'mode': mode,
      'days': days,
      'timing': timing,
      'type': type,
      'enrollmentFee': enrollmentFee,
      'hasFreeDemo': hasFreeDemo,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }

  Course copyWith({
    String? id,
    String? domain,
    String? recommendedCourses,
    double? cost,
    String? duration,
    String? mode,
    String? days,
    String? timing,
    String? type,
    double? enrollmentFee,
    bool? hasFreeDemo,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Course(
      id: id ?? this.id,
      domain: domain ?? this.domain,
      recommendedCourses: recommendedCourses ?? this.recommendedCourses,
      cost: cost ?? this.cost,
      duration: duration ?? this.duration,
      mode: mode ?? this.mode,
      days: days ?? this.days,
      timing: timing ?? this.timing,
      type: type ?? this.type,
      enrollmentFee: enrollmentFee ?? this.enrollmentFee,
      hasFreeDemo: hasFreeDemo ?? this.hasFreeDemo,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

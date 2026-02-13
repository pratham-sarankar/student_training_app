import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type;
  final String salary;
  final String category;
  final String posted;
  final String logo;
  final String description;
  final List<String> eligibility;
  final DateTime createdAt;
  final bool isActive;
  final DateTime? deadline;
  final String? applyLink;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.salary,
    required this.category,
    required this.posted,
    required this.logo,
    required this.description,
    required this.eligibility,
    required this.createdAt,
    required this.isActive,
    this.deadline,
    this.applyLink,
  });

  factory Job.fromMap(Map<String, dynamic> map, String id) {
    return Job(
      id: id,
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      location: map['location'] ?? '',
      type: map['type'] ?? '',
      salary: map['salary'] ?? '',
      category: map['category'] ?? '',
      posted: map['posted'] ?? '',
      logo: map['logo'] ?? '',
      description: map['description'] ?? '',
      eligibility: List<String>.from(
        map['eligibility'] ?? map['requirements'] ?? [],
      ),
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : (map['createdAt'] is DateTime
                  ? map['createdAt'] as DateTime
                  : DateTime.now()),
      isActive: map['isActive'] ?? true,
      deadline:
          map['deadline'] is Timestamp
              ? (map['deadline'] as Timestamp).toDate()
              : (map['deadline'] is DateTime
                  ? map['deadline'] as DateTime
                  : null),
      applyLink: map['applyLink'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'type': type,
      'salary': salary,
      'category': category,
      'posted': posted,
      'logo': logo,
      'description': description,
      'eligibility': eligibility,
      'createdAt': createdAt,
      'isActive': isActive,
      'deadline': deadline,
      'applyLink': applyLink,
    };
  }

  Job copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    String? type,
    String? salary,
    String? category,
    String? posted,
    String? logo,
    String? description,
    List<String>? eligibility,
    DateTime? createdAt,
    bool? isActive,
    DateTime? deadline,
    String? applyLink,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      type: type ?? this.type,
      salary: salary ?? this.salary,
      category: category ?? this.category,
      posted: posted ?? this.posted,
      logo: logo ?? this.logo,
      description: description ?? this.description,
      eligibility: eligibility ?? this.eligibility,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      deadline: deadline ?? this.deadline,
      applyLink: applyLink ?? this.applyLink,
    );
  }
}

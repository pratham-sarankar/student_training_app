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
  final List<String> requirements;
  final List<String> responsibilities;
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
    required this.requirements,
    required this.responsibilities,
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
      // Read from 'eligibility' first, fallback to 'requirements' for backward compatibility
      requirements: List<String>.from(
        map['eligibility'] ?? map['requirements'] ?? [],
      ),
      // Responsibilities are no longer stored in Firebase, return empty list
      responsibilities: [],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      deadline: (map['deadline'] as Timestamp?)?.toDate(),
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
      // Send requirements as 'eligibility'
      'eligibility': requirements,
      // Responsibilities are not sent to Firebase
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
    List<String>? requirements,
    List<String>? responsibilities,
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
      requirements: requirements ?? this.requirements,
      responsibilities: responsibilities ?? this.responsibilities,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      deadline: deadline ?? this.deadline,
      applyLink: applyLink ?? this.applyLink,
    );
  }
}

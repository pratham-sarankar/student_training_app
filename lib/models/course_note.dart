import 'package:cloud_firestore/cloud_firestore.dart';

class CourseNote {
  final String id;
  final String createdBy;
  final String createdByName;
  final String title;
  final String content;
  final DateTime timestamp;
  final DateTime updatedAt;
  final List<String> tags;
  final bool isPublic;

  CourseNote({
    required this.id,
    required this.createdBy,
    required this.createdByName,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.updatedAt,
    this.tags = const [],
    this.isPublic = false,
  });

  // Create from Firestore document
  factory CourseNote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourseNote(
      id: doc.id,
      createdBy: data['createdBy'] ?? '',
      createdByName: data['createdByName'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
      isPublic: data['isPublic'] ?? false,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'createdBy': createdBy,
      'createdByName': createdByName,
      'title': title,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tags': tags,
      'isPublic': isPublic,
    };
  }

  // Create a copy with updated fields
  CourseNote copyWith({
    String? id,
    String? createdBy,
    String? createdByName,
    String? title,
    String? content,
    DateTime? timestamp,
    DateTime? updatedAt,
    List<String>? tags,
    bool? isPublic,
  }) {
    return CourseNote(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}

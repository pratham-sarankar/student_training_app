import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { course, promotional, system }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final Timestamp createdAt;
  final bool isRead;
  final String? relatedId; // Job ID or Course ID

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.relatedId,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${map['type']}',
        orElse: () => NotificationType.system,
      ),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      isRead: map['isRead'] ?? false,
      relatedId: map['relatedId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'createdAt': createdAt,
      'isRead': isRead,
      'relatedId': relatedId,
    };
  }
}

import 'package:flutter/material.dart';

class Training {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<TrainingSchedule> schedules;
  final DateTime createdAt;

  Training({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.schedules,
    required this.createdAt,
  });

  Training copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    List<TrainingSchedule>? schedules,
    DateTime? createdAt,
  }) {
    return Training(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      schedules: schedules ?? this.schedules,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'schedules': schedules.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Training.fromJson(Map<String, dynamic> json) {
    DateTime parseCreatedAt(dynamic createdAt) {
      if (createdAt == null) return DateTime.now();
      
      if (createdAt is String) {
        return DateTime.parse(createdAt);
      } else if (createdAt is DateTime) {
        return createdAt;
      } else if (createdAt.runtimeType.toString().contains('Timestamp')) {
        // Handle Firestore Timestamp
        try {
          // Access the seconds and nanoseconds properties
          final seconds = createdAt.seconds as int? ?? 0;
          final nanoseconds = createdAt.nanoseconds as int? ?? 0;
          return DateTime.fromMillisecondsSinceEpoch(seconds * 1000 + (nanoseconds / 1000000).round());
        } catch (e) {
          print('Error parsing Firestore Timestamp: $e');
          return DateTime.now();
        }
      }
      
      return DateTime.now();
    }

    // Handle different field names from Firestore
    final price = json['price'] ?? json['cost'] ?? 0.0;
    
    return Training(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (price is num) ? price.toDouble() : 0.0,
      schedules: (json['schedules'] as List? ?? [])
          .map((s) => TrainingSchedule.fromJson(s))
          .toList(),
      createdAt: parseCreatedAt(json['createdAt']),
    );
  }
}

class TrainingSchedule {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final TimeOfDay time;
  final int capacity;
  final List<EnrolledStudent> enrolledStudents;
  final List<Note> notes;
  final List<Message> messages;

  TrainingSchedule({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.time,
    required this.capacity,
    required this.enrolledStudents,
    required this.notes,
    required this.messages,
  });

  TrainingSchedule copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    TimeOfDay? time,
    int? capacity,
    List<EnrolledStudent>? enrolledStudents,
    List<Note>? notes,
    List<Message>? messages,
  }) {
    return TrainingSchedule(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      time: time ?? this.time,
      capacity: capacity ?? this.capacity,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      notes: notes ?? this.notes,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'time': {
        'hour': time.hour,
        'minute': time.minute,
      },
      'capacity': capacity,
      'enrolledStudents': enrolledStudents.map((s) => s.toJson()).toList(),
      'notes': notes.map((n) => n.toJson()).toList(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory TrainingSchedule.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date == null) return DateTime.now();
      
      if (date is String) {
        try {
          return DateTime.parse(date);
        } catch (e) {
          print('Error parsing date string: $date, error: $e');
          return DateTime.now();
        }
      } else if (date is DateTime) {
        return date;
      } else if (date.runtimeType.toString().contains('Timestamp')) {
        try {
          final seconds = date.seconds as int? ?? 0;
          final nanoseconds = date.nanoseconds as int? ?? 0;
          return DateTime.fromMillisecondsSinceEpoch(seconds * 1000 + (nanoseconds / 1000000).round());
        } catch (e) {
          print('Error parsing Firestore Timestamp: $e');
          return DateTime.now();
        }
      }
      
      return DateTime.now();
    }

    TimeOfDay parseTime(dynamic time) {
      if (time == null) return const TimeOfDay(hour: 0, minute: 0);
      
      if (time is Map<String, dynamic>) {
        // Handle time object format from toJson
        final hour = time['hour'] as int? ?? 0;
        final minute = time['minute'] as int? ?? 0;
        return TimeOfDay(hour: hour, minute: minute);
      } else if (time is String) {
        try {
          // Handle different time formats like "Wed, Fri 6:00 PM" or "6:00 PM"
          final timeMatch = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)?').firstMatch(time);
          if (timeMatch != null) {
            int hour = int.parse(timeMatch.group(1)!);
            int minute = int.parse(timeMatch.group(2)!);
            final period = timeMatch.group(3)?.toUpperCase();
            
            if (period == 'PM' && hour != 12) hour += 12;
            if (period == 'AM' && hour == 12) hour = 0;
            
            return TimeOfDay(hour: hour, minute: minute);
          }
        } catch (e) {
          print('Error parsing time string: $time, error: $e');
        }
      }
      
      return const TimeOfDay(hour: 0, minute: 0);
    }

    return TrainingSchedule(
      id: json['id'] ?? '',
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      time: parseTime(json['time']),
      capacity: json['capacity'] ?? json['seats'] ?? 0,
      enrolledStudents: (json['enrolledStudents'] as List? ?? [])
          .map((s) => EnrolledStudent.fromJson(s))
          .toList(),
      notes: (json['notes'] as List? ?? [])
          .map((n) => Note.fromJson(n))
          .toList(),
      messages: (json['messages'] as List? ?? [])
          .map((m) => Message.fromJson(m))
          .toList(),
    );
  }
}

class EnrolledStudent {
  final String id;
  final String name;
  final String email;
  final DateTime enrolledDate;
  final bool isSubscribedToJobs;

  EnrolledStudent({
    required this.id,
    required this.name,
    required this.email,
    required this.enrolledDate,
    this.isSubscribedToJobs = false,
  });

  EnrolledStudent copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? enrolledDate,
    bool? isSubscribedToJobs,
  }) {
    return EnrolledStudent(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      enrolledDate: enrolledDate ?? this.enrolledDate,
      isSubscribedToJobs: isSubscribedToJobs ?? this.isSubscribedToJobs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'enrolledDate': enrolledDate.toIso8601String(),
      'isSubscribedToJobs': isSubscribedToJobs,
    };
  }

  factory EnrolledStudent.fromJson(Map<String, dynamic> json) {
    return EnrolledStudent(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      enrolledDate: json['enrolledDate'] != null 
          ? DateTime.parse(json['enrolledDate']) 
          : DateTime.now(),
      isSubscribedToJobs: json['isSubscribedToJobs'] ?? false,
    );
  }
}

class Note {
  final String id;
  final String title;
  final String filePath;
  final String fileType;
  final DateTime uploadedAt;

  Note({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileType,
    required this.uploadedAt,
  });

  Note copyWith({
    String? id,
    String? title,
    String? filePath,
    String? fileType,
    DateTime? uploadedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'fileType': fileType,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      filePath: json['filePath'] ?? '',
      fileType: json['fileType'] ?? '',
      uploadedAt: json['uploadedAt'] != null 
          ? DateTime.parse(json['uploadedAt']) 
          : DateTime.now(),
    );
  }
}

class Message {
  final String id;
  final String content;
  final DateTime sentAt;

  Message({
    required this.id,
    required this.content,
    required this.sentAt,
  });

  Message copyWith({
    String? id,
    String? content,
    DateTime? sentAt,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sentAt': sentAt.toIso8601String(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      sentAt: json['sentAt'] != null 
          ? DateTime.parse(json['sentAt']) 
          : DateTime.now(),
    );
  }
}

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
    return Training(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      schedules: (json['schedules'] as List)
          .map((s) => TrainingSchedule.fromJson(s))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
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
      'time': '${time.hour}:${time.minute}',
      'capacity': capacity,
      'enrolledStudents': enrolledStudents.map((s) => s.toJson()).toList(),
      'notes': notes.map((n) => n.toJson()).toList(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory TrainingSchedule.fromJson(Map<String, dynamic> json) {
    final timeParts = json['time'].split(':');
    return TrainingSchedule(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      capacity: json['capacity'],
      enrolledStudents: (json['enrolledStudents'] as List)
          .map((s) => EnrolledStudent.fromJson(s))
          .toList(),
      notes: (json['notes'] as List)
          .map((n) => Note.fromJson(n))
          .toList(),
      messages: (json['messages'] as List)
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
      id: json['id'],
      name: json['name'],
      email: json['email'],
      enrolledDate: DateTime.parse(json['enrolledDate']),
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
      id: json['id'],
      title: json['title'],
      filePath: json['filePath'],
      fileType: json['fileType'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
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
      id: json['id'],
      content: json['content'],
      sentAt: DateTime.parse(json['sentAt']),
    );
  }
}

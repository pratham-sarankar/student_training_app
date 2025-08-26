
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final String? imageUrl;
  final MessageType type;
  final String senderType; // Add senderType to distinguish user/instructor

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.imageUrl,
    this.type = MessageType.text,
    this.senderType = 'user', // Default to user
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['type'] ?? 'text'}',
        orElse: () => MessageType.text,
      ),
      senderType: data['senderType'] ?? 'user', // Get senderType from Firestore
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
      'senderType': senderType, // Include senderType in Firestore
    };
  }
}

enum MessageType {
  text,
  image,
  file,
  instructor, // Add instructor type
}

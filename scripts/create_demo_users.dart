// This is a helper script to create demo users in Firestore
// You can run this in your Flutter app or use it as a reference

import 'package:cloud_firestore/cloud_firestore.dart';

class DemoDataCreator {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create demo users for testing
  static Future<void> createDemoUsers() async {
    try {
      final demoUsers = [
        {
          'uid': 'demo_user_1',
          'name': 'John Doe',
          'email': 'john.doe@example.com',
          'photoUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'uid': 'demo_user_2',
          'name': 'Jane Smith',
          'email': 'jane.smith@example.com',
          'photoUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'uid': 'demo_user_3',
          'name': 'Mike Johnson',
          'email': 'mike.johnson@example.com',
          'photoUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'uid': 'demo_user_4',
          'name': 'Sarah Wilson',
          'email': 'sarah.wilson@example.com',
          'photoUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'uid': 'demo_user_5',
          'name': 'David Brown',
          'email': 'david.brown@example.com',
          'photoUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];

      for (final user in demoUsers) {
        await _firestore
            .collection('users')
            .doc(user['uid'] as String)
            .set(user);
        print('Created demo user: ${user['name']}');
      }

      print('Demo users created successfully!');
    } catch (e) {
      print('Error creating demo users: $e');
    }
  }

  // Create demo chats
  static Future<void> createDemoChats() async {
    try {
      // Create a demo chat between user 1 and user 2
      final chatRef = await _firestore.collection('chats').add({
        'participants': ['demo_user_1', 'demo_user_2'],
        'participantNames': ['John Doe', 'Jane Smith'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': 'Hello! How are you?',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': 'demo_user_1',
        'lastSenderName': 'John Doe',
      });

      // Add some demo messages
      final messages = [
        {
          'senderId': 'demo_user_1',
          'senderName': 'John Doe',
          'message': 'Hello! How are you?',
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'text',
        },
        {
          'senderId': 'demo_user_2',
          'senderName': 'Jane Smith',
          'message': 'Hi John! I\'m doing great, thanks for asking.',
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'text',
        },
        {
          'senderId': 'demo_user_1',
          'senderName': 'John Doe',
          'message': 'That\'s wonderful! Are you working on any new projects?',
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'text',
        },
        {
          'senderId': 'demo_user_2',
          'senderName': 'Jane Smith',
          'message': 'Yes! I\'m learning Flutter and it\'s amazing.',
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'text',
        },
      ];

      for (final message in messages) {
        await chatRef.collection('messages').add(message);
      }

      print('Demo chat created successfully!');
    } catch (e) {
      print('Error creating demo chat: $e');
    }
  }

  // Clear all demo data
  static Future<void> clearDemoData() async {
    try {
      // Delete demo users
      final demoUserIds = [
        'demo_user_1',
        'demo_user_2',
        'demo_user_3',
        'demo_user_4',
        'demo_user_5',
      ];

      for (final uid in demoUserIds) {
        await _firestore.collection('users').doc(uid).delete();
      }

      // Delete demo chats
      final chatsSnapshot = await _firestore.collection('chats').get();
      for (final doc in chatsSnapshot.docs) {
        await doc.reference.delete();
      }

      print('Demo data cleared successfully!');
    } catch (e) {
      print('Error clearing demo data: $e');
    }
  }
}

// Usage example:
// void main() async {
//   await DemoDataCreator.createDemoUsers();
//   await DemoDataCreator.createDemoChats();
// }

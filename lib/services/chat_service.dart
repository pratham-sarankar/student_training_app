import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get chat messages stream
  Stream<List<ChatMessage>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
    });
  }

  // Send a message
  Future<void> sendMessage(String chatId, String message, {String? imageUrl}) async {
    if (currentUser == null) return;

    final chatMessage = ChatMessage(
      id: '', // Will be set by Firestore
      senderId: currentUser!.uid,
      senderName: currentUser!.displayName ?? 'Unknown User',
      message: message,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
      type: imageUrl != null ? MessageType.image : MessageType.text,
    );

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(chatMessage.toFirestore());

    // Update chat metadata
    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': message,
      'lastMessageTime': Timestamp.now(),
      'lastSenderId': currentUser!.uid,
      'lastSenderName': currentUser!.displayName ?? 'Unknown User',
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  // Create or get existing chat
  Future<String> createOrGetChat(String otherUserId, String otherUserName) async {
    if (currentUser == null) throw Exception('User not authenticated');

    final currentUserId = currentUser!.uid;
    final currentUserName = currentUser!.displayName ?? 'Unknown User';

    // Check if chat already exists
    final existingChats = await _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in existingChats.docs) {
      final data = doc.data();
      final participants = List<String>.from(data['participants'] ?? []);
      if (participants.contains(otherUserId)) {
        return doc.id;
      }
    }

    // Create new chat
    final chatRef = await _firestore.collection('chats').add({
      'participants': [currentUserId, otherUserId],
      'participantNames': [currentUserName, otherUserName],
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });

    return chatRef.id;
  }

  // Get user chats
  Stream<List<Map<String, dynamic>>> getUserChats() {
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUser!.uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        final participantNames = List<String>.from(data['participantNames'] ?? []);
        
        // Find the other participant
        final otherParticipantIndex = participants.indexOf(currentUser!.uid) == 0 ? 1 : 0;
        
        return {
          'chatId': doc.id,
          'otherUserId': participants[otherParticipantIndex],
          'otherUserName': participantNames[otherParticipantIndex],
          'lastMessage': data['lastMessage'] ?? '',
          'lastMessageTime': data['lastMessageTime'],
          'lastSenderName': data['lastSenderName'] ?? '',
        };
      }).toList();
    });
  }

  // Delete message
  Future<void> deleteMessage(String chatId, String messageId) async {
    if (currentUser == null) return;

    final messageDoc = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .get();

    if (messageDoc.exists) {
      final messageData = messageDoc.data();
      if (messageData?['senderId'] == currentUser!.uid) {
        await messageDoc.reference.delete();
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../models/chat_message.dart';

class InstructorChatScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final String studentId;
  final String studentName;
  final String studentEmail;

  const InstructorChatScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
  });

  @override
  State<InstructorChatScreen> createState() => _InstructorChatScreenState();
}

class _InstructorChatScreenState extends State<InstructorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSendingMessage = false;
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadCourseMessages();
  }

  void _loadCourseMessages() {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load messages from the global course_chats collection
      final globalChatId = '${widget.courseId}_${widget.studentId}';

      _messagesSubscription = FirebaseFirestore.instance
          .collection('course_chats')
          .doc(globalChatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              if (mounted) {
                final newMessages =
                    snapshot.docs
                        .map((doc) => ChatMessage.fromFirestore(doc))
                        .toList();

                // Only update state if messages have actually changed
                if (!_areMessagesEqual(_messages, newMessages)) {
                  // Cancel any existing debounce timer
                  _debounceTimer?.cancel();

                  // Debounce the update to prevent rapid rebuilds
                  _debounceTimer = Timer(const Duration(milliseconds: 100), () {
                    if (mounted) {
                      setState(() {
                        _messages = newMessages;
                      });
                      _scrollToBottom();
                    }
                  });
                }
              }
            },
            onError: (error) {
              print('Error loading messages: $error');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error loading messages: $error'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
          );
    } catch (e) {
      print('Error setting up messages listener: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting up messages listener: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isSendingMessage = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final messageText = _messageController.text.trim();
      final timestamp = Timestamp.now();

      // Clear the input field immediately
      _messageController.clear();

      // Send message to both collections for consistency
      final globalChatId = '${widget.courseId}_${widget.studentId}';

      // Add message to global course_chats collection
      await FirebaseFirestore.instance
          .collection('course_chats')
          .doc(globalChatId)
          .collection('messages')
          .add({
            'senderId': currentUser.uid,
            'senderName': currentUser.displayName ?? 'Course Instructor',
            'senderType': 'instructor',
            'message': messageText,
            'timestamp': timestamp,
            'type': 'text',
            'isRead': false,
          });

      // Also add message to user's course chat subcollection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId)
          .collection('course_chats')
          .doc(widget.courseId)
          .collection('messages')
          .add({
            'senderId': currentUser.uid,
            'senderName': currentUser.displayName ?? 'Course Instructor',
            'senderType': 'instructor',
            'message': messageText,
            'timestamp': timestamp,
            'type': 'text',
            'isRead': false,
          });

      // Update chat metadata in both collections
      final updateData = {
        'lastMessage': messageText,
        'lastMessageTime': timestamp,
        'lastSenderId': currentUser.uid,
        'lastSenderName': currentUser.displayName ?? 'Course Instructor',
        'updatedAt': timestamp,
        'messageCount': FieldValue.increment(1),
      };

      // Update global collection
      await FirebaseFirestore.instance
          .collection('course_chats')
          .doc(globalChatId)
          .update(updateData);

      // Update user's collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId)
          .collection('course_chats')
          .doc(widget.courseId)
          .update(updateData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
      }
    }
  }

  bool _areMessagesEqual(List<ChatMessage> list1, List<ChatMessage> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id ||
          list1[i].message != list2[i].message ||
          list1[i].timestamp != list2[i].timestamp) {
        return false;
      }
    }
    return true;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.05,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.courseTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Chat with ${widget.studentName}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Instructor',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Chat Messages
              Expanded(
                child:
                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                        )
                        : _messages.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Start the conversation with your student!',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          key: const ValueKey('instructor_chat_messages'),
                          reverse: true,
                          padding: EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isInstructor =
                                message.senderType == 'instructor';

                            return Container(
                              key: ValueKey(message.id),
                              margin: EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    isInstructor
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  if (!isInstructor) ...[
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          theme.colorScheme.secondary,
                                      child: Text(
                                        widget.studentName[0].toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.surface,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                  ],
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isInstructor
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            isInstructor
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            message.message,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  isInstructor
                                                      ? theme
                                                          .colorScheme
                                                          .onPrimary
                                                      : theme
                                                          .colorScheme
                                                          .onSurface,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            _formatMessageTime(
                                              message.timestamp,
                                            ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  isInstructor
                                                      ? theme
                                                          .colorScheme
                                                          .primary
                                                          .withValues(
                                                            alpha: 0.8,
                                                          )
                                                      : theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isInstructor) ...[
                                    SizedBox(width: 8),
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      child: Icon(
                                        Icons.school,
                                        size: 16,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
              ),

              // Message Input
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.05,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon:
                            _isSendingMessage
                                ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                                : Icon(
                                  Icons.send,
                                  size: 20,
                                  color: theme.colorScheme.onPrimary,
                                ),
                        onPressed: _isSendingMessage ? null : _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messagesSubscription?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}

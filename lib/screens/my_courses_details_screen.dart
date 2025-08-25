import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../models/chat_message.dart';

class MyCoursesDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> course;

  const MyCoursesDetailsScreen({
    super.key,
    required this.course,
  });

  @override
  State<MyCoursesDetailsScreen> createState() => _MyCoursesDetailsScreenState();
}

class _MyCoursesDetailsScreenState extends State<MyCoursesDetailsScreen> {
  int _selectedTabIndex = 0;
  
  // Firebase chat data
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _courseChatId;

  @override
  void initState() {
    super.initState();
    _initializeCourseChat();
  }

  Future<void> _initializeCourseChat() async {
    try {
      // Create or get course chat room
      _courseChatId = await _createCourseChatRoom();
      if (_courseChatId != null) {
        _loadCourseMessages();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _createCourseChatRoom() async {
    try {
      final currentUser = _chatService.currentUser;
      if (currentUser == null) return null;

      // Create a unique chat ID for this course
      final courseChatId = 'course_${widget.course['id'] ?? widget.course['title']}_${currentUser.uid}';
      
      // Check if course chat exists
      final chatDoc = await FirebaseFirestore.instance
          .collection('course_chats')
          .doc(courseChatId)
          .get();

      if (!chatDoc.exists) {
        // Create new course chat
        await FirebaseFirestore.instance
            .collection('course_chats')
            .doc(courseChatId)
            .set({
          'courseId': widget.course['id'] ?? widget.course['title'],
          'courseTitle': widget.course['title'],
          'participants': [currentUser.uid],
          'participantNames': [currentUser.displayName ?? 'Unknown User'],
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'lastMessage': 'Welcome to ${widget.course['title']}! How can I help you today?',
          'lastMessageTime': Timestamp.now(),
          'lastSenderId': 'instructor',
          'lastSenderName': 'Course Instructor',
        });

        // Add welcome message
        await FirebaseFirestore.instance
            .collection('course_chats')
            .doc(courseChatId)
            .collection('messages')
            .add({
          'senderId': 'instructor',
          'senderName': 'Course Instructor',
          'message': 'Welcome to ${widget.course['title']}! How can I help you today?',
          'timestamp': Timestamp.now(),
          'type': 'text',
        });
      }

      return courseChatId;
    } catch (e) {
      print('Error creating course chat room: $e');
      return null;
    }
  }

  void _loadCourseMessages() {
    if (_courseChatId == null) return;

    FirebaseFirestore.instance
        .collection('course_chats')
        .doc(_courseChatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _messages = snapshot.docs
              .map((doc) => ChatMessage.fromFirestore(doc))
              .toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  FButton(
                    onPress: () => Navigator.of(context).pop(),
                    style: FButtonStyle.outline,
                    child: Icon(
                      Icons.arrow_back,
                      size: 16.sp,
                      color: const Color(0xFF666666),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.course['title'],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${widget.course['category']} • ${widget.course['level']}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF666666),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: FButton(
                      onPress: () {
                        setState(() {
                          _selectedTabIndex = 0;
                        });
                      },
                      style: _selectedTabIndex == 0 
                          ? FButtonStyle.primary 
                          : FButtonStyle.outline,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_outlined,
                            size: 16.sp,
                            color: _selectedTabIndex == 0 
                                ? Colors.white 
                                : Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Notes',
                            style: TextStyle(
                              color: _selectedTabIndex == 0 
                                  ? Colors.white 
                                  : Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: FButton(
                      onPress: () {
                        setState(() {
                          _selectedTabIndex = 1;
                        });
                      },
                      style: _selectedTabIndex == 1 
                          ? FButtonStyle.primary 
                          : FButtonStyle.outline,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_outlined,
                            size: 16.sp,
                            color: _selectedTabIndex == 1 
                                ? Colors.white 
                                : Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Chat',
                            style: TextStyle(
                              color: _selectedTabIndex == 1 
                                  ? Colors.white 
                                  : Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Tab Content
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  _buildNotesTab(),
                  _buildChatTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildNotesTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w,vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notes Header
          Row(
            children: [
              Icon(
                Icons.note_outlined,
                size: 20.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'Course Notes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),

          // Notes List
          Expanded(
            child: ListView.builder(
              itemCount: 3, // Sample notes
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.1),
                      width: 1.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.note_outlined,
                            size: 16.sp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Note ${index + 1}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '2 hours ago',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF666666),
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'This is a sample note for the course. You can add your own notes here to help you remember important concepts and ideas.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildChatTab() {
    final currentUser = _chatService.currentUser;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Chat Header
          Row(
            children: [
              Icon(
                Icons.chat_outlined,
                size: 20.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'Course Chat',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Online',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),

          // Firebase Chat Messages
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64.sp,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: EdgeInsets.all(16.w),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderId == currentUser?.uid;

                          return Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            child: Row(
                              mainAxisAlignment: isMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (!isMe) ...[
                                  CircleAvatar(
                                    radius: 16.r,
                                    backgroundColor: Colors.orange,
                                    child: Text(
                                      message.senderName[0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                ],
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe ? Theme.of(context).colorScheme.primary : Colors.white,
                                      borderRadius: BorderRadius.circular(20.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isMe
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.message,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: isMe ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          _formatMessageTime(message.timestamp),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: isMe
                                                ? Colors.white.withOpacity(0.8)
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isMe) ...[
                                  SizedBox(width: 8.w),
                                  CircleAvatar(
                                    radius: 16.r,
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      (currentUser?.displayName?[0] ?? 'U').toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
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
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: IconButton(
                    icon: _isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(Icons.send, size: 20.sp, color: Colors.white),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _courseChatId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = _chatService.currentUser;
      if (currentUser == null) return;

      // Send message to Firebase
      await FirebaseFirestore.instance
          .collection('course_chats')
          .doc(_courseChatId)
          .collection('messages')
          .add({
        'senderId': currentUser.uid,
        'senderName': currentUser.displayName ?? 'Unknown User',
        'message': _messageController.text.trim(),
        'timestamp': Timestamp.now(),
        'type': 'text',
      });

      // Update chat metadata
      await FirebaseFirestore.instance
          .collection('course_chats')
          .doc(_courseChatId)
          .update({
        'lastMessage': _messageController.text.trim(),
        'lastMessageTime': Timestamp.now(),
        'lastSenderId': currentUser.uid,
        'lastSenderName': currentUser.displayName ?? 'Unknown User',
        'updatedAt': Timestamp.now(),
      });

      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../services/chat_service.dart';
import '../../services/course_notes_service.dart';
import '../../models/chat_message.dart';
import '../../models/course_note.dart';


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
  List<ChatMessage> _localMessages = []; // Add local messages list for immediate updates
  bool _isLoading = false;
  String? _courseChatId;
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  Timer? _debounceTimer; // Add debounce timer
  bool _isSendingMessage = false; // Add flag to track if we're sending a message

  // Firebase course notes data
  final CourseNotesService _courseNotesService = CourseNotesService();
  List<CourseNote> _courseNotes = [];
  bool _isNotesLoading = false;
  String? _courseNotesId;

  @override
  void initState() {
    super.initState();
    _localMessages = []; // Initialize local messages list
    _initializeCourseChat();
    _initializeCourseNotes();
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
            backgroundColor: context.theme.colors.destructive,
          ),
        );
      }
    }
  }

  Future<String?> _createCourseChatRoom() async {
    try {
      final currentUser = _chatService.currentUser;
      if (currentUser == null) return null;

      // Create a unique chat ID for this course and user
      final courseChatId = '${currentUser.uid}_${widget.course['id']}';
      
      // Check if course chat exists in user's subcollection
      final chatDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('course_chats')
          .doc(widget.course['id'])
          .get();

      if (!chatDoc.exists) {
        // Create new course chat in user's subcollection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('course_chats')
            .doc(widget.course['id'])
            .set({
          'courseId': widget.course['id'],
          'courseTitle': widget.course['title'],
          'courseCategory': widget.course['category'],
          'courseLevel': widget.course['level'],
          'userId': currentUser.uid,
          'userName': currentUser.displayName ?? 'Unknown User',
          'userEmail': currentUser.email ?? '',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'lastMessage': 'Welcome to ${widget.course['title']}! How can I help you today?',
          'lastMessageTime': Timestamp.now(),
          'lastSenderId': 'instructor',
          'lastSenderName': 'Course Instructor',
          'messageCount': 1,
          'isActive': true,
        });

        // Add welcome message to the chat
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('course_chats')
            .doc(widget.course['id'])
            .collection('messages')
            .add({
          'senderId': 'instructor',
          'senderName': 'Course Instructor',
          'senderType': 'instructor',
          'message': 'Welcome to ${widget.course['title']}! How can I help you today?',
          'timestamp': Timestamp.now(),
          'type': 'text',
          'isRead': false,
        });

        // Also create a reference in the global course_chats collection for admin/instructor access
        // Use a more reliable document ID format and ensure it exists
        final globalChatId = '${widget.course['id']}_${currentUser.uid}';
        await FirebaseFirestore.instance
            .collection('course_chats')
            .doc(globalChatId)
            .set({
          'courseId': widget.course['id'],
          'courseTitle': widget.course['title'],
          'courseCategory': widget.course['category'],
          'courseLevel': widget.course['level'],
          'userId': currentUser.uid,
          'userName': currentUser.displayName ?? 'Unknown User',
          'userEmail': currentUser.email ?? '',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
          'lastMessage': 'Welcome to ${widget.course['title']}! How can I help you today?',
          'lastMessageTime': Timestamp.now(),
          'lastSenderId': 'instructor',
          'lastSenderName': 'Course Instructor',
          'messageCount': 1,
          'isActive': true,
          'userChatRef': 'users/${currentUser.uid}/course_chats/${widget.course['id']}',
        });
      } else {
        // If chat exists, ensure the global reference also exists
        final globalChatId = '${widget.course['id']}_${currentUser.uid}';
        final globalChatDoc = await FirebaseFirestore.instance
            .collection('course_chats')
            .doc(globalChatId)
            .get();
            
        if (!globalChatDoc.exists) {
          // Create the global reference if it doesn't exist
          await FirebaseFirestore.instance
              .collection('course_chats')
              .doc(globalChatId)
              .set({
            'courseId': widget.course['id'],
            'courseTitle': widget.course['title'],
            'courseCategory': widget.course['category'],
            'courseLevel': widget.course['level'],
            'userId': currentUser.uid,
            'userName': currentUser.displayName ?? 'Unknown User',
            'userEmail': currentUser.email ?? '',
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
            'lastMessage': chatDoc.data()?['lastMessage'] ?? 'Welcome to ${widget.course['title']}!',
            'lastMessageTime': chatDoc.data()?['lastMessageTime'] ?? Timestamp.now(),
            'lastSenderId': chatDoc.data()?['lastSenderId'] ?? 'instructor',
            'lastSenderName': chatDoc.data()?['lastSenderName'] ?? 'Course Instructor',
            'messageCount': chatDoc.data()?['messageCount'] ?? 1,
            'isActive': true,
            'userChatRef': 'users/${currentUser.uid}/course_chats/${widget.course['id']}',
          });
        }
      }

      return courseChatId;
    } catch (e) {
      print('Error creating course chat room: $e');
      // Return a fallback chat ID to prevent crashes
      return '${_chatService.currentUser?.uid ?? 'unknown'}_${widget.course['id']}';
    }
  }

  void _loadCourseMessages() {
    if (_courseChatId == null) return;

    // Cancel any existing subscription
    _messagesSubscription?.cancel();

    // Load messages from user's course chat subcollection
    _messagesSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(_chatService.currentUser?.uid)
        .collection('course_chats')
        .doc(widget.course['id'])
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        final newMessages = snapshot.docs
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
                // Merge with local messages
                _mergeLocalAndRemoteMessages();
              });
            }
          });
        }
      }
    });
  }

  void _loadCourseNotes() {
    try {
      // Load course notes from Firebase
      _courseNotesService.getCourseNotes(widget.course['id']).listen((notes) {
        if (mounted) {
          setState(() {
            _courseNotes = notes;
          });
        }
      }, onError: (error) {
        print('Error loading course notes: $error');
        if (mounted) {
          setState(() {
            _courseNotes = [];
          });
        }
      });
    } catch (e) {
      print('Error setting up notes listener: $e');
      if (mounted) {
        setState(() {
          _courseNotes = [];
        });
      }
    }
  }

  Future<void> _initializeCourseNotes() async {
    try {
      setState(() {
        _isNotesLoading = true;
      });

      // Load course notes from Firebase
      _loadCourseNotes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing notes: $e'),
            backgroundColor: context.theme.colors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isNotesLoading = false;
        });
      }
    }
  }

  String _formatNoteTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final noteDate = DateTime(time.year, time.month, time.day);

    if (noteDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (noteDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.colors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FButton(
                      onPress: () => Navigator.of(context).pop(),
                      style: FButtonStyle.outline,
                      child: Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: theme.colors.foreground,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.course['title'],
                            style: theme.typography.lg.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colors.foreground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${widget.course['category']} • ${widget.course['level']}',
                            style: theme.typography.sm.copyWith(
                              color: theme.colors.mutedForeground,
                              fontSize: 12,
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
                padding: EdgeInsets.symmetric(horizontal: 16),
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
                              size: 16,
                              color: _selectedTabIndex == 0 
                                  ? theme.colors.primaryForeground
                                  : theme.colors.primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Notes',
                              style: TextStyle(
                                color: _selectedTabIndex == 0 
                                    ? theme.colors.primaryForeground
                                    : theme.colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
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
                              size: 16,
                              color: _selectedTabIndex == 1 
                                  ? theme.colors.primaryForeground
                                  : theme.colors.primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Chat',
                              style: TextStyle(
                                color: _selectedTabIndex == 1 
                                    ? theme.colors.primaryForeground
                                    : theme.colors.primary,
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
      
              SizedBox(height: 16),
      
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
      ),
    );
  }


  Widget _buildNotesTab() {
    final theme = context.theme;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notes Header
          Row(
            children: [
              Icon(
                Icons.note_outlined,
                      size: 20,
                color: theme.colors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Course Notes',
                style: theme.typography.lg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colors.foreground,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),

          // Notes List
          Expanded(
            child: _isNotesLoading
                ? Center(child: CircularProgressIndicator(color: theme.colors.primary))
                : _courseNotes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_outlined,
                              size: 64,
                              color: theme.colors.muted,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No notes yet',
                              style: theme.typography.lg.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Create your first note to get started!',
                              style: theme.typography.sm.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Notes will appear here when they are added by instructors.',
                              style: theme.typography.sm.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _courseNotes.length,
                        itemBuilder: (context, index) {
                          final note = _courseNotes[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colors.border.withOpacity(0.1),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colors.foreground.withOpacity(0.05),
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
                                      size: 16,
                                      color: theme.colors.primary,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        note.title,
                                        style: theme.typography.sm.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colors.foreground,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  note.content,
                                  style: theme.typography.sm.copyWith(
                                    color: theme.colors.foreground,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (note.tags.isNotEmpty) ...[
                                        SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: note.tags.map((tag) => Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: theme.colors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )).toList(),
                                  ),
                                ],
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      _formatNoteTime(note.updatedAt),
                                      style: theme.typography.sm.copyWith(
                                        color: theme.colors.mutedForeground,
                                        fontSize: 10,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'by ${note.createdByName}',
                                      style: theme.typography.sm.copyWith(
                                        color: theme.colors.mutedForeground,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
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
    final theme = context.theme;
    final currentUser = _chatService.currentUser;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Chat Header
          Row(
            children: [
              Icon(
                Icons.chat_outlined,
                size: 20,
                color: theme.colors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Course Chat',
                style: theme.typography.lg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colors.foreground,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Online',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),

          // Firebase Chat Messages
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: theme.colors.primary))
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: theme.colors.muted,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: theme.typography.lg.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start the conversation!',
                              style: theme.typography.sm.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        key: const ValueKey('chat_messages'), // Add key for better performance
                        reverse: true,
                        padding: EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderId == currentUser?.uid;

                          return Container(
                            key: ValueKey(message.id), // Add key for each message
                            margin: EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: isMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (!isMe) ...[
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: theme.colors.secondary,
                                    child: Text(
                                      message.senderName[0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colors.background,
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
                                      color: isMe ? theme.colors.primary : theme.colors.background,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colors.foreground.withOpacity(0.1),
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
                                            fontSize: 16,
                                            color: isMe ? theme.colors.primaryForeground : theme.colors.foreground,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          _formatMessageTime(message.timestamp),
                                          style: TextStyle(
                                                    fontSize: 12,
                                            color: isMe
                                                ? theme.colors.primaryForeground.withOpacity(0.8)
                                                : theme.colors.mutedForeground,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isMe) ...[
                                  SizedBox(width: 8),
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: theme.colors.primary,
                                    child: Text(
                                      (currentUser?.displayName?[0] ?? 'U').toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colors.primaryForeground,
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
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colors.background,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colors.muted,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
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
                    color: theme.colors.primary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    icon: _isSendingMessage
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primaryForeground),
                            ),
                          )
                        : Icon(Icons.send, size: 20, color: theme.colors.primaryForeground),
                    onPressed: _isSendingMessage ? null : _sendMessage,
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
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isSendingMessage = true;
    });

    try {
      final currentUser = _chatService.currentUser;
      if (currentUser == null) return;

      final messageText = _messageController.text.trim();
      final timestamp = Timestamp.now();

      // Create the message object locally first
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        senderId: currentUser.uid,
        senderName: currentUser.displayName ?? 'Unknown User',
        message: messageText,
        timestamp: timestamp.toDate(),
        type: MessageType.text,
      );

              // Add message to local state immediately for instant feedback
        setState(() {
          _localMessages.insert(0, newMessage); // Insert at the beginning
          _mergeLocalAndRemoteMessages(); // Update display immediately
        });

      // Clear the input field immediately
      _messageController.clear();

      // Send message to user's course chat subcollection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('course_chats')
          .doc(widget.course['id'])
          .collection('messages')
          .add({
        'senderId': currentUser.uid,
        'senderName': currentUser.displayName ?? 'Unknown User',
        'senderType': 'user',
        'message': messageText,
        'timestamp': timestamp,
        'type': 'text',
        'isRead': false,
      });

      // Update chat metadata in user's subcollection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('course_chats')
          .doc(widget.course['id'])
          .update({
        'lastMessage': messageText,
        'lastMessageTime': timestamp,
        'lastSenderId': currentUser.uid,
        'lastSenderName': currentUser.displayName ?? 'Unknown User',
        'updatedAt': timestamp,
        'messageCount': FieldValue.increment(1),
      });

      // Also update the global course_chats collection for admin/instructor access
      await FirebaseFirestore.instance
          .collection('course_chats')
          .doc('${widget.course['id']}_${currentUser.uid}')
          .update({
        'lastMessage': messageText,
        'lastMessageTime': timestamp,
        'lastSenderId': currentUser.uid,
        'lastSenderName': currentUser.displayName ?? 'Unknown User',
        'updatedAt': timestamp,
        'messageCount': FieldValue.increment(1),
      });

      // Remove the message from local messages since it's now in Firestore
      setState(() {
        _localMessages.removeAt(0);
        _mergeLocalAndRemoteMessages(); // Update display
      });

    } catch (e) {
      // Remove the message from local state if sending failed
      setState(() {
        _localMessages.removeAt(0);
        _mergeLocalAndRemoteMessages(); // Update display
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: context.theme.colors.destructive,
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

  void _mergeLocalAndRemoteMessages() {
    // Create a combined list with local messages first, then remote messages
    final combinedMessages = <ChatMessage>[];
    
    // Add local messages (they should be at the top since they're newer)
    combinedMessages.addAll(_localMessages);
    
    // Add remote messages, avoiding duplicates
    for (final remoteMessage in _messages) {
      // Check if this message is already in local messages
      final isDuplicate = _localMessages.any((local) => 
        local.message == remoteMessage.message && 
        local.timestamp == remoteMessage.timestamp &&
        local.senderId == remoteMessage.senderId
      );
      
      if (!isDuplicate) {
        combinedMessages.add(remoteMessage);
      }
    }
    
    // Sort by timestamp (newest first)
    combinedMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // Update the display messages
    _messages = combinedMessages;
    
    // Debug logging
    print('Merged messages - Local: ${_localMessages.length}, Remote: ${_messages.length}, Combined: ${combinedMessages.length}');
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
    _messagesSubscription?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}

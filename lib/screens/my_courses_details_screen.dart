import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:intl/intl.dart';

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
  
  // Chat data
  final List<ChatMessage> _messages = [];
  final ChatUser _currentUser = ChatUser(
    id: '1',
    firstName: 'Me',
    lastName: '',
  );
  final ChatUser _instructor = ChatUser(
    id: '2',
    firstName: 'Instructor',
    lastName: '',
  );

  @override
  void initState() {
    super.initState();
    // Add some sample messages
    _messages.addAll([
      ChatMessage(
        text: 'Welcome to ${widget.course['title']}! How can I help you today?',
        user: _instructor,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        text: 'Hi! I have a question about the course material.',
        user: _currentUser,
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      ChatMessage(
        text: 'Of course! What would you like to know?',
        user: _instructor,
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ]);
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chat Header
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

          // Chat Messages
          Expanded(
            child: DashChat(
              currentUser: _currentUser,
              messages: _messages,
              onSend: (ChatMessage message) {
                setState(() {
                  _messages.insert(0, message);
                });
                
                // Simulate instructor response
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() {
                      _messages.insert(0, ChatMessage(
                        text: 'Thanks for your message! I\'ll get back to you soon.',
                        user: _instructor,
                        createdAt: DateTime.now(),
                      ));
                    });
                  }
                });
              },
              messageOptions: MessageOptions(
                showTime: true,
                timeFormat: DateFormat('HH:mm'),
                avatarBuilder: (user, onTap, onLongPress) {
                  return CircleAvatar(
                    backgroundColor: user.id == '1' 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.orange,
                    child: Text(
                      (user.firstName?.isNotEmpty == true) ? user.firstName![0] : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
              inputOptions: InputOptions(
                inputTextStyle: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF1A1A1A),
                ),
                sendButtonBuilder: (onSend) {
                  return FButton(
                    onPress: onSend,
                    style: FButtonStyle.primary,
                    child: Icon(
                      Icons.send,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

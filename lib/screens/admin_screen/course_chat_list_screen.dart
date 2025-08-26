import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'instructor_chat_screen.dart';

class CourseChatListScreen extends StatefulWidget {
  const CourseChatListScreen({super.key});

  @override
  State<CourseChatListScreen> createState() => _CourseChatListScreenState();
}

class _CourseChatListScreenState extends State<CourseChatListScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _courseChats = [];

  @override
  void initState() {
    super.initState();
    _loadCourseChats();
  }

  Future<void> _loadCourseChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Listen to all course chats
      FirebaseFirestore.instance
          .collection('course_chats')
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          final chats = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'chatId': doc.id,
              'courseId': data['courseId'] ?? '',
              'courseTitle': data['courseTitle'] ?? '',
              'courseCategory': data['courseCategory'] ?? '',
              'courseLevel': data['courseLevel'] ?? '',
              'userId': data['userId'] ?? '',
              'userName': data['userName'] ?? '',
              'userEmail': data['userEmail'] ?? '',
              'lastMessage': data['lastMessage'] ?? '',
              'lastMessageTime': data['lastMessageTime'],
              'lastSenderId': data['lastSenderId'] ?? '',
              'lastSenderName': data['lastSenderName'] ?? '',
              'messageCount': data['messageCount'] ?? 0,
              'isActive': data['isActive'] ?? true,
              'createdAt': data['createdAt'],
              'updatedAt': data['updatedAt'],
            };
          }).toList();

          setState(() {
            _courseChats = chats;
            _isLoading = false;
          });
        }
      }, onError: (error) {
        print('Error loading course chats: $error');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading course chats: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } catch (e) {
      print('Error setting up course chats listener: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting up course chats listener: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'Unknown';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd').format(time);
    }
  }

  void _openChat(Map<String, dynamic> chat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InstructorChatScreen(
          courseId: chat['courseId'],
          courseTitle: chat['courseTitle'],
          studentId: chat['userId'],
          studentName: chat['userName'],
          studentEmail: chat['userEmail'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
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
                            'Course Chats',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            'Manage student conversations',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF666666),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${_courseChats.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Course Chats List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _courseChats.isEmpty
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
                                  'No course chats yet',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Course chats will appear here when students\nstart conversations',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16.w),
                            itemCount: _courseChats.length,
                            itemBuilder: (context, index) {
                              final chat = _courseChats[index];
                              final isInstructorMessage = chat['lastSenderId'] != chat['userId'];

                              return Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12.r),
                                    onTap: () => _openChat(chat),
                                    child: Container(
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
                                          // Course and Student Info
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8.w),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8.r),
                                                ),
                                                child: Icon(
                                                  Icons.school,
                                                  size: 16.sp,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      chat['courseTitle'],
                                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                        color: const Color(0xFF1A1A1A),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      '${chat['courseCategory']} • ${chat['courseLevel']}',
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        color: const Color(0xFF666666),
                                                        fontSize: 11.sp,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                                decoration: BoxDecoration(
                                                  color: isInstructorMessage 
                                                      ? Colors.green.withOpacity(0.1)
                                                      : Colors.blue.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8.r),
                                                ),
                                                child: Text(
                                                  isInstructorMessage ? 'Instructor' : 'Student',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: isInstructorMessage ? Colors.green : Colors.blue,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 10.sp,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          SizedBox(height: 12.h),
                                          
                                          // Student Info
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 16.r,
                                                backgroundColor: Colors.blue,
                                                child: Text(
                                                  chat['userName'][0].toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      chat['userName'],
                                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                        fontWeight: FontWeight.w500,
                                                        color: const Color(0xFF1A1A1A),
                                                      ),
                                                    ),
                                                    Text(
                                                      chat['userEmail'],
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        color: const Color(0xFF666666),
                                                        fontSize: 11.sp,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          SizedBox(height: 12.h),
                                          
                                          // Last Message and Time
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      chat['lastMessage'],
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        color: const Color(0xFF666666),
                                                        fontSize: 12.sp,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Text(
                                                      '${chat['messageCount']} messages',
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        color: const Color(0xFF999999),
                                                        fontSize: 10.sp,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    _formatTime(chat['lastMessageTime']?.toDate()),
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: const Color(0xFF666666),
                                                      fontSize: 10.sp,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  if (chat['isActive'])
                                                    Container(
                                                      width: 8.w,
                                                      height: 8.h,
                                                      decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

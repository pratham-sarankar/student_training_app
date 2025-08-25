import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'my_courses_details_screen.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  List<Map<String, dynamic>> _purchasedCourses = [];
  bool _isLoading = true;
  String? _errorMessage;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserCourses();
  }

  Future<void> _loadUserCourses() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      // Fetch user's purchased courses from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        setState(() {
          _purchasedCourses = [];
          _isLoading = false;
        });
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final purchasedCourseIds = List<String>.from(userData['purchasedCourses'] ?? []);

      if (purchasedCourseIds.isEmpty) {
        setState(() {
          _purchasedCourses = [];
          _isLoading = false;
        });
        return;
      }

      // Fetch course details for each purchased course
      final courses = <Map<String, dynamic>>[];
      for (final courseId in purchasedCourseIds) {
        try {
          final courseDoc = await _firestore
              .collection('courses')
              .doc(courseId)
              .get();

          if (courseDoc.exists) {
            final courseData = courseDoc.data() as Map<String, dynamic>;
            courses.add({
              'id': courseId,
              'title': courseData['title'] ?? 'Untitled Course',
              'category': courseData['category'] ?? 'General',
              'level': courseData['level'] ?? 'Beginner',
              'image': courseData['image'] ?? 'https://picsum.photos/300/200?random=1',
              'duration': courseData['duration'] ?? '8 weeks',
              'cost': courseData['cost']?.toString() ?? '0',
              'instructor': courseData['instructor'] ?? 'Unknown Instructor',
              'description': courseData['description'] ?? '',
              'lessons': courseData['lessons'] ?? [],
              'progress': userData['courseProgress']?[courseId] ?? 0,
              'lastAccessed': userData['courseLastAccessed']?[courseId],
              'purchaseDate': userData['coursePurchaseDate']?[courseId],
            });
          }
        } catch (e) {
          print('Error fetching course $courseId: $e');
          // Continue with other courses even if one fails
        }
      }

      // Sort courses by last accessed date (most recent first)
      courses.sort((a, b) {
        final aDate = a['lastAccessed'] as Timestamp?;
        final bDate = b['lastAccessed'] as Timestamp?;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      setState(() {
        _purchasedCourses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading courses: $e';
        _isLoading = false;
      });
      print('Error loading user courses: $e');
    }
  }

  Future<void> _updateCourseAccess(String courseId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'courseLastAccessed.$courseId': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating course access: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _loadUserCourses,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.refresh,
          color: Colors.white,
          size: 20.sp,
        ),
      ),
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
                  Text(
                    'My Courses',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${_purchasedCourses.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Course Statistics
            if (!_isLoading && _errorMessage == null && _purchasedCourses.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildCourseStatistics(),
              ),

            SizedBox(height: 16.h),

            // Content
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _purchasedCourses.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadUserCourses,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                itemCount: _purchasedCourses.length,
                                itemBuilder: (context, index) {
                                  final course = _purchasedCourses[index];
                                  return _buildSimpleCourseCard(course);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading your courses...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseStatistics() {
    final totalCourses = _purchasedCourses.length;
    final completedCourses = _purchasedCourses.where((course) => course['progress'] == 1.0).length;
    final inProgressCourses = totalCourses - completedCourses;
    final totalProgress = _purchasedCourses.fold<double>(
      0.0, 
      (sum, course) => sum + (course['progress']?.toDouble() ?? 0.0)
    );
    final averageProgress = totalCourses > 0 ? totalProgress / totalCourses : 0.0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Progress',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Courses',
                  '$totalCourses',
                  Icons.school_outlined,
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Completed',
                  '$completedCourses',
                  Icons.check_circle_outline,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'In Progress',
                  '$inProgressCourses',
                  Icons.play_circle_outline,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Avg Progress',
                  '${(averageProgress * 100).toInt()}%',
                  Icons.trending_up,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24.sp,
          color: color,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF666666),
            fontSize: 10.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Icon(
              Icons.error_outline,
              size: 40.sp,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Error Loading Courses',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _errorMessage ?? 'Something went wrong',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          FButton(
            style: FButtonStyle.primary,
            onPress: _loadUserCourses,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Icon(
              Icons.school_outlined,
              size: 40.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Courses Yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start your learning journey by purchasing your first course',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          FButton(
            style: FButtonStyle.primary,
            onPress: () => Navigator.of(context).pop(),
            child: Text('Browse Courses'),
          ),
        ],
      ),
    );
  }

    Widget _buildSimpleCourseCard(Map<String, dynamic> course) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
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
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    course['title'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  
                  // Tags
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          course['category'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          course['level'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Course Info
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12.sp,
                        color: const Color(0xFF666666),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        course['duration'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF666666),
                          fontSize: 10.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Icon(
                        Icons.person_outline,
                        size: 12.sp,
                        color: const Color(0xFF666666),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          course['instructor'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF666666),
                            fontSize: 10.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Progress Bar
                  if (course['progress'] != null && course['progress'] > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF666666),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${(course['progress'] * 100).toInt()}%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        LinearProgressIndicator(
                          value: course['progress']?.toDouble() ?? 0.0,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            course['progress'] == 1.0 
                                ? Colors.green 
                                : Theme.of(context).colorScheme.primary,
                          ),
                          minHeight: 4.h,
                        ),
                        if (course['progress'] == 1.0)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 12.sp,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Completed!',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.green,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  SizedBox(height: 8.h),

                  // Action Button
                  SizedBox(
                    height: 40.h,
                    child: FButton(
                      style: FButtonStyle.primary,
                      onPress: () async {
                        await _updateCourseAccess(course['id']);
                        if (mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MyCoursesDetailsScreen(course: course),
                            ),
                          );
                        }
                      },
                      child: Text(
                        course['progress'] == 1.0 ? 'Review Course' : 'Continue Learning',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gradspark/models/course.dart';
import 'package:gradspark/screens/student_screens/my_courses_details_screen.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  List<Map<String, dynamic>> _purchasedCourses = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
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
        _isRefreshing = true;
        _errorMessage = null;
      });

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
          _isRefreshing = false;
        });
        return;
      }

      // Fetch user's purchased courses from Firestore
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        setState(() {
          _purchasedCourses = [];
          _isLoading = false;
          _isRefreshing = false;
        });
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final purchasedCourseIds = List<String>.from(
        userData['purchasedCourses'] ?? [],
      );

      if (purchasedCourseIds.isEmpty) {
        setState(() {
          _purchasedCourses = [];
          _isLoading = false;
          _isRefreshing = false;
        });
        return;
      }

      // Fetch course details for each purchased course
      final courses = <Map<String, dynamic>>[];
      for (final courseId in purchasedCourseIds) {
        try {
          final courseDoc =
              await _firestore.collection('courses').doc(courseId).get();

          if (courseDoc.exists) {
            final courseData = courseDoc.data() as Map<String, dynamic>;
            final courseObj = Course.fromMap(courseData, courseId);

            courses.add({
              'id': courseId,
              'title': courseObj.title,
              'category': courseObj.category,

              'image':
                  courseData['image'] ??
                  'https://picsum.photos/300/200?random=1',
              'duration': courseObj.duration,
              'cost': courseObj.cost.toString(),
              'instructor': courseData['instructor'] ?? 'Unknown Instructor',
              'description': courseObj.description,
              'lessons': courseData['lessons'] ?? [],
              'progress': userData['courseProgress']?[courseId] ?? 0,
              'lastAccessed': userData['courseLastAccessed']?[courseId],
              'purchaseDate': userData['coursePurchaseDate']?[courseId],
            });
          }
        } catch (e) {
          print('Error fetching course $courseId: $e');
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
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading courses: $e';
        _isLoading = false;
        _isRefreshing = false;
      });
      print('Error loading user courses: $e');
    }
  }

  Future<void> _updateCourseAccess(String courseId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore.collection('users').doc(currentUser.uid).update({
        'courseLastAccessed.$courseId': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating course access: $e');
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
                    Text(
                      'My Courses',
                      style: theme.typography.lg.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.foreground,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_purchasedCourses.length}',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child:
                    _isLoading
                        ? _buildLoadingState()
                        : _errorMessage != null
                        ? _buildErrorState()
                        : _purchasedCourses.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                          onRefresh: _loadUserCourses,
                          child: Stack(
                            children: [
                              ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _purchasedCourses.length,
                                itemBuilder: (context, index) {
                                  final course = _purchasedCourses[index];
                                  return _buildSimpleCourseCard(course);
                                },
                              ),
                              if (_isRefreshing)
                                Positioned(
                                  top: 20,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colors.foreground
                                            .withValues(alpha: 0.87),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    theme.colors.background,
                                                  ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Refreshing...',
                                            style: theme.typography.sm.copyWith(
                                              color: theme.colors.background,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
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
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final theme = context.theme;

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3, // Show 3 skeleton cards while loading
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: theme.colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colors.border.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colors.foreground.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colors.muted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 6),

                // Tags skeleton
                Row(
                  children: [
                    Container(
                      height: 20,
                      width: 60,
                      decoration: BoxDecoration(
                        color: theme.colors.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(width: 6),
                    Container(
                      height: 20,
                      width: 50,
                      decoration: BoxDecoration(
                        color: theme.colors.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),

                // Course info skeleton
                Row(
                  children: [
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: theme.colors.muted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: 16),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: theme.colors.muted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),

                // Progress bar skeleton
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colors.muted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 8),

                // Button skeleton
                Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colors.muted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    final theme = context.theme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colors.destructive.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.error_outline,
              size: 40,
              color: theme.colors.destructive,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Error Loading Courses',
            style: theme.typography.lg.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colors.foreground,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Something went wrong',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
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
    final theme = context.theme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.school_outlined,
                size: 50,
                color: theme.colors.primary,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No Courses Yet',
              style: theme.typography.xl.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colors.foreground,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Start your learning journey by purchasing your first course from our extensive catalog',
              style: theme.typography.base.copyWith(
                color: theme.colors.mutedForeground,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            FButton(
              style: FButtonStyle.primary,
              onPress: () => Navigator.of(context).pop(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text('Browse Courses'),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Explore courses in various categories and find the perfect one for your career goals',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleCourseCard(Map<String, dynamic> course) {
    final theme = context.theme;

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colors.border.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colors.foreground.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    course['title'],
                    style: theme.typography.sm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colors.foreground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),

                  // Tags
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          course['category'],
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),

                  // Course Info
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: theme.colors.mutedForeground,
                      ),
                      SizedBox(width: 4),
                      Text(
                        course['duration'],
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(
                        Icons.person_outline,
                        size: 12,
                        color: theme.colors.mutedForeground,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          course['instructor'],
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),

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
                              style: theme.typography.sm.copyWith(
                                color: theme.colors.mutedForeground,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${(course['progress'] * 100).toInt()}%',
                              style: theme.typography.sm.copyWith(
                                color: theme.colors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: course['progress']?.toDouble() ?? 0.0,
                          backgroundColor: theme.colors.muted,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colors.primary,
                          ),
                          minHeight: 4,
                        ),
                        if (course['progress'] == 1.0)
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 12,
                                  color: theme.colors.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Completed!',
                                  style: theme.typography.sm.copyWith(
                                    color: theme.colors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  SizedBox(height: 8),

                  // Action Button
                  SizedBox(
                    height: 40,
                    child: FButton(
                      style: FButtonStyle.primary,
                      onPress: () async {
                        await _updateCourseAccess(course['id']);
                        if (mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      MyCoursesDetailsScreen(course: course),
                            ),
                          );
                        }
                      },
                      child: Text(
                        course['progress'] == 1.0
                            ? 'Review Course'
                            : 'Continue Learning',
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colors.primaryForeground,
                          fontSize: 12,
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

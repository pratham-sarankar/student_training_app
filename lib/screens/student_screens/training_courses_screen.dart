import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/course.dart';
import '../../services/course_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/course_avatar.dart';
import 'traning_course_details_screen.dart';

class TrainingCoursesScreen extends StatefulWidget {
  const TrainingCoursesScreen({super.key});

  @override
  State<TrainingCoursesScreen> createState() => _TrainingCoursesScreenState();
}

class _TrainingCoursesScreenState extends State<TrainingCoursesScreen> {
  final CourseService _courseService = CourseService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCourses();
  }

  Future<void> _initializeCourses() async {
    try {
      await _courseService.initializeSampleCourses();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing courses: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: theme.colors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Header Title
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Training Courses',
                    style: theme.typography.lg.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colors.foreground,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Courses List
              Expanded(
                child:
                    _isInitialized
                        ? StreamBuilder<List<Course>>(
                          stream: _courseService.getCourses(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error loading courses: ${snapshot.error}',
                                  style: TextStyle(
                                    color: theme.colors.destructive,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }

                            final courses = snapshot.data ?? [];

                            if (courses.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 48,
                                      color: theme.colors.mutedForeground,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No courses found',
                                      style: theme.typography.lg.copyWith(
                                        color: theme.colors.foreground,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Please check back later',
                                      style: theme.typography.sm.copyWith(
                                        color: theme.colors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              itemCount: courses.length,
                              itemBuilder: (context, index) {
                                final course = courses[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: _buildCourseCard(context, course),
                                );
                              },
                            );
                          },
                        )
                        : _buildCoursesShimmerLoading(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    final theme = context.theme;

    return GestureDetector(
      onTap: () => _navigateToCourseDetails(course),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: theme.colors.foreground.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: CourseAvatar(title: course.title, size: 50),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: theme.typography.lg.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colors.foreground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                course.category,
                                style: theme.typography.sm.copyWith(
                                  color: theme.colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                course.level,
                                style: theme.typography.sm.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Course Description (shortened)
              Text(
                course.description,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),
              // View Details hint
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap to view details',
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.primary.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: theme.colors.primary.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCourseDetails(Course course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => TraningCourseDetailsScreen(course: course.toMap()),
      ),
    );
  }

  Widget _buildCoursesShimmerLoading(FThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 5,
      itemBuilder: (context, index) {
        return ShimmerLoading.courseCardShimmer(theme);
      },
    );
  }
}

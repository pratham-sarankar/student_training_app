import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/course.dart';
import '../../services/course_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/course_avatar.dart';
import 'domain_courses_screen.dart';

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

                            final allCourses = snapshot.data ?? [];

                            if (allCourses.isEmpty) {
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

                            // Group courses by domain
                            final Map<String, List<Course>> domainGroups = {};
                            for (var course in allCourses) {
                              if (!domainGroups.containsKey(course.domain)) {
                                domainGroups[course.domain] = [];
                              }
                              domainGroups[course.domain]!.add(course);
                            }

                            final domains = domainGroups.keys.toList()..sort();

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              itemCount: domains.length,
                              itemBuilder: (context, index) {
                                final domain = domains[index];
                                final coursesInDomain = domainGroups[domain]!;

                                // Calculate total courses including sub-courses (split by comma/slash)
                                int totalSubCourses = 0;
                                for (var c in coursesInDomain) {
                                  totalSubCourses +=
                                      c.recommendedCourses
                                          .split(
                                            RegExp(r',|\s/\s|(?<=\s)/(?=\s)'),
                                          )
                                          .where((s) => s.trim().isNotEmpty)
                                          .length;
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: _buildDomainCard(
                                    context,
                                    domain,
                                    coursesInDomain,
                                    totalSubCourses,
                                  ),
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

  Widget _buildDomainCard(
    BuildContext context,
    String domain,
    List<Course> courses,
    int totalCount,
  ) {
    final theme = context.theme;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) =>
                    DomainCoursesScreen(domain: domain, courses: courses),
          ),
        );
      },
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
          child: Row(
            children: [
              CourseAvatar(title: domain, size: 50),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      domain,
                      style: theme.typography.lg.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalCount ${totalCount == 1 ? 'Course' : 'Courses'} available',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colors.primary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
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

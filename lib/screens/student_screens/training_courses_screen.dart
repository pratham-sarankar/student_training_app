import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/course.dart';
import '../../services/course_service.dart';
import 'traning_course_details_screen.dart';

class TrainingCoursesScreen extends StatefulWidget {
  const TrainingCoursesScreen({super.key});

  @override
  State<TrainingCoursesScreen> createState() => _TrainingCoursesScreenState();
}

class _TrainingCoursesScreenState extends State<TrainingCoursesScreen> {
  String _selectedCategory = 'All';
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
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing courses: $e');
      setState(() {
        _isInitialized = true;
      });
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
      
              // Category Filter using Forui FButtons
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: _isInitialized
                    ? StreamBuilder<List<String>>(
                        stream: _courseService.getCourseCategories(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primary),
                              ),
                            );
                          }
                          
                          if (snapshot.hasError) {
                            return Text(
                              'Error loading categories: ${snapshot.error}',
                              style: TextStyle(
                                color: theme.colors.destructive,
                                fontSize: 16,
                              ),
                            );
                          }
                          
                          final categories = snapshot.data ?? ['All'];
                          
                          return SingleChildScrollView(
                            clipBehavior: Clip.none,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: categories.map((category) {
                                bool isSelected = _selectedCategory == category;
                                return Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: isSelected ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colors.primary.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ) : null,
                                  child: FButton(
                                    onPress: () {
                                      setState(() {
                                        _selectedCategory = category;
                                      });
                                    },
                                    style: isSelected ? FButtonStyle.primary : FButtonStyle.outline,
                                    child: StreamBuilder<List<Course>>(
                                      stream: category == 'All' 
                                          ? _courseService.getCourses()
                                          : _courseService.getCoursesByCategory(category),
                                      builder: (context, coursesSnapshot) {
                                        int courseCount = coursesSnapshot.data?.length ?? 0;
                                        return Text(
                                          '$category ($courseCount)',
                                          style: theme.typography.sm.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isSelected 
                                                ? theme.colors.primaryForeground
                                                : theme.colors.mutedForeground,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primary),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
      
              // Results Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder<List<Course>>(
                      stream: _selectedCategory == 'All' 
                          ? _courseService.getCourses()
                          : _courseService.getCoursesByCategory(_selectedCategory),
                      builder: (context, snapshot) {
                        final courseCount = snapshot.data?.length ?? 0;
                        return Text(
                          'Showing $courseCount courses',
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        );
                      },
                    ),
                    if (_selectedCategory != 'All')
                      Text(
                        'Filtered by: $_selectedCategory',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
      
              // Courses List
              Expanded(
                child: _isInitialized
                    ? StreamBuilder<List<Course>>(
                        stream: _selectedCategory == 'All' 
                            ? _courseService.getCourses()
                            : _courseService.getCoursesByCategory(_selectedCategory),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primary),
                              ),
                            );
                          }
                          
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
                                    'No courses found for "$_selectedCategory"',
                                    style: theme.typography.lg.copyWith(
                                      color: theme.colors.foreground,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try selecting a different category',
                                    style: theme.typography.sm.copyWith(
                                      color: theme.colors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    : Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primary),
                        ),
                      ),
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
            border: Border.all(
              color: theme.colors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colors.foreground.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Image
                  Container(
                    width: 80,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(course.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Course Info
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colors.primary.withOpacity(0.1),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
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
                      color: theme.colors.primary.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: theme.colors.primary.withOpacity(0.7),
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
        builder: (context) => TraningCourseDetailsScreen(course: course.toMap()),
      ),
    );
  }
}

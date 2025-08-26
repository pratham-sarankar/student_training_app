import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header Title
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: Text(
                    'Training Courses',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
      
              // Category Filter using Forui FButtons
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                child: _isInitialized
                    ? StreamBuilder<List<String>>(
                        stream: _courseService.getCourseCategories(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (snapshot.hasError) {
                            return Text('Error loading categories: ${snapshot.error}');
                          }
                          
                          final categories = snapshot.data ?? ['All'];
                          
                          return SingleChildScrollView(
                            clipBehavior: Clip.none,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: categories.map((category) {
                                bool isSelected = _selectedCategory == category;
                                return Container(
                                  margin: EdgeInsets.only(right: 12.w),
                                  decoration: isSelected ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isSelected 
                                                ? Colors.white
                                                : const Color(0xFF666666),
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
                    : const Center(child: CircularProgressIndicator()),
              ),
              SizedBox(height: 16.h),
      
              // Results Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
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
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF666666),
                          ),
                        );
                      },
                    ),
                    if (_selectedCategory != 'All')
                      Text(
                        'Filtered by: $_selectedCategory',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
      
              // Courses List
              Expanded(
                child: _isInitialized
                    ? StreamBuilder<List<Course>>(
                        stream: _selectedCategory == 'All' 
                            ? _courseService.getCourses()
                            : _courseService.getCoursesByCategory(_selectedCategory),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error loading courses: ${snapshot.error}',
                                style: TextStyle(color: Colors.red),
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
                                    size: 48.sp,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'No courses found for "$_selectedCategory"',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Try selecting a different category',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            itemCount: courses.length,
                            itemBuilder: (context, index) {
                              final course = courses[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                child: _buildCourseCard(context, course),
                              );
                            },
                          );
                        },
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    return GestureDetector(
      onTap: () => _navigateToCourseDetails(course),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFE5E5E5),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
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
                    width: 80.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      image: DecorationImage(
                        image: NetworkImage(course.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  
                  // Course Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                course.category,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                course.level,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
              
              SizedBox(height: 12.h),
              
              // Course Description (shortened)
              Text(
                course.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF666666),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: 8.h),
              // View Details hint
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap to view details',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12.sp,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
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

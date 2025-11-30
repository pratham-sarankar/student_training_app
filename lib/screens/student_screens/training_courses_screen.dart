import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/course.dart';
import '../../services/course_service.dart';
import '../../widgets/shimmer_loading.dart';
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
  bool _categoriesLoaded = false;
  List<String> _categories = ['All'];
  Map<String, int> _categoryCounts = {'All': 0};

  @override
  void initState() {
    super.initState();
    _initializeCourses();
    _loadCategoriesAndCounts();
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

  Future<void> _loadCategoriesAndCounts() async {
    try {
      // Load categories
      final categories = await _courseService.getCourseCategories().first;
      final allCategories = [
        'All',
        ...categories.where((category) => category != 'All'),
      ];

      // Load counts for each category
      final counts = <String, int>{};
      for (String category in allCategories) {
        if (category == 'All') {
          final allCourses = await _courseService.getCourses().first;
          counts[category] = allCourses.length;
        } else {
          final categoryCourses =
              await _courseService.getCoursesByCategory(category).first;
          counts[category] = categoryCourses.length;
        }
      }

      setState(() {
        _categories = allCategories;
        _categoryCounts = counts;
        _categoriesLoaded = true;
      });
    } catch (e) {
      print('Error loading categories and counts: $e');
      setState(() {
        _categoriesLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: theme.colorScheme.surface,
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              // Category Filter using Forui FButtons
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child:
                    _categoriesLoaded
                        ? SingleChildScrollView(
                          clipBehavior: Clip.none,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                _categories.map((category) {
                                  bool isSelected =
                                      _selectedCategory == category;
                                  final courseCount =
                                      _categoryCounts[category] ?? 0;
                                  return Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration:
                                        isSelected
                                            ? BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: theme
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: 0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            )
                                            : null,
                                    child:
                                        isSelected
                                            ? FilledButton(
                                              onPressed: () {
                                                setState(() {
                                                  _selectedCategory = category;
                                                });
                                              },
                                              child: Text(
                                                '$category ($courseCount)',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          theme
                                                              .colorScheme
                                                              .onPrimary,
                                                    ),
                                              ),
                                            )
                                            : OutlinedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _selectedCategory = category;
                                                });
                                              },
                                              child: Text(
                                                '$category ($courseCount)',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          theme
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                    ),
                                              ),
                                            ),
                                  );
                                }).toList(),
                          ),
                        )
                        : ShimmerLoading.categoryButtonShimmer(theme),
              ),
              const SizedBox(height: 16),

              // Results Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${_categoryCounts[_selectedCategory] ?? 0} courses',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_selectedCategory != 'All')
                      Text(
                        'Filtered by: $_selectedCategory',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Courses List
              Expanded(
                child:
                    _isInitialized
                        ? StreamBuilder<List<Course>>(
                          stream:
                              _selectedCategory == 'All'
                                  ? _courseService.getCourses()
                                  : _courseService.getCoursesByCategory(
                                    _selectedCategory,
                                  ),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error loading courses: ${snapshot.error}',
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
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
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No courses found for "$_selectedCategory"',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try selecting a different category',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color:
                                                theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _navigateToCourseDetails(course),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline, width: 1),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
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
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                course.category,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
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
                                style: theme.textTheme.bodySmall?.copyWith(
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
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
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

  Widget _buildCoursesShimmerLoading(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 5,
      itemBuilder: (context, index) {
        return ShimmerLoading.courseCardShimmer(theme);
      },
    );
  }
}

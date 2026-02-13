import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../../models/course.dart';
import '../../widgets/course_avatar.dart';
import 'traning_course_details_screen.dart';

class DomainCoursesScreen extends StatelessWidget {
  final String domain;
  final List<Course> courses;

  const DomainCoursesScreen({
    super.key,
    required this.domain,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    // Expand courses that might contain multiple names (e.g., "HTML, CSS, JS")
    // This ensures that even existing data shows up separately as requested.
    final List<Course> displayedCourses = [];
    for (var course in courses) {
      final subCourseNames =
          course.recommendedCourses
              .split(RegExp(r',|\s/\s|(?<=\s)/(?=\s)'))
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      if (subCourseNames.length > 1) {
        for (var name in subCourseNames) {
          displayedCourses.add(course.copyWith(recommendedCourses: name));
        }
      } else {
        displayedCourses.add(course);
      }
    }

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        title: Text(
          '$domain Courses',
          style: theme.typography.lg.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colors.foreground,
          ),
        ),
        backgroundColor: theme.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colors.foreground),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select a training program to enroll',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: displayedCourses.length,
                itemBuilder: (context, index) {
                  final course = displayedCourses[index];
                  return _buildCourseCard(context, course);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    final theme = context.theme;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => TraningCourseDetailsScreen(course: course.toMap()),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            Row(
              children: [
                CourseAvatar(title: course.recommendedCourses, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.recommendedCourses,
                        style: theme.typography.base.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colors.foreground,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${course.cost.toInt()} • ${course.duration}',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: theme.colors.mutedForeground.withValues(alpha: 0.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

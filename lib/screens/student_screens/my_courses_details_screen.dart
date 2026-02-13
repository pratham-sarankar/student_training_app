import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import '../../widgets/course_avatar.dart';

class MyCoursesDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> course;

  const MyCoursesDetailsScreen({super.key, required this.course});

  @override
  State<MyCoursesDetailsScreen> createState() => _MyCoursesDetailsScreenState();
}

class _MyCoursesDetailsScreenState extends State<MyCoursesDetailsScreen> {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                    const SizedBox(width: 12),
                    CourseAvatar(title: widget.course['title'] ?? '', size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.course['title'] ?? 'Course Details',
                            style: theme.typography.lg.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colors.foreground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.course['category'] ?? 'General',
                            style: theme.typography.sm.copyWith(
                              color: theme.colors.mutedForeground,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Course Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: theme.colors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Enrolled',
                              style: theme.typography.sm.copyWith(
                                color: theme.colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Course Title
                      Text(
                        widget.course['title'] ?? 'Untitled Course',
                        style: theme.typography.xl2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colors.foreground,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Instructor
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: theme.colors.primary.withValues(
                              alpha: 0.1,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 14,
                              color: theme.colors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Instructor: ',
                            style: theme.typography.sm.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                          Text(
                            widget.course['instructor'] ?? 'Unknown',
                            style: theme.typography.sm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colors.foreground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Course Details Grid
                      Row(
                        children: [
                          _buildDetailChip(
                            context,
                            Icons.timer_outlined,
                            'Duration',
                            widget.course['duration'] ?? 'N/A',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description Section
                      if (widget.course['description'] != null &&
                          widget.course['description']
                              .toString()
                              .isNotEmpty) ...[
                        Text(
                          'About this Course',
                          style: theme.typography.lg.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colors.foreground,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.course['description'],
                          style: theme.typography.base.copyWith(
                            color: theme.colors.mutedForeground,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Lesson Progress
                      if (widget.course['progress'] != null) ...[
                        Text(
                          'Your Progress',
                          style: theme.typography.lg.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colors.foreground,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colors.muted.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Overall Completion',
                                    style: theme.typography.sm.copyWith(
                                      color: theme.colors.mutedForeground,
                                    ),
                                  ),
                                  Text(
                                    '${(widget.course['progress'] * 100).toInt()}%',
                                    style: theme.typography.sm.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value:
                                    widget.course['progress']?.toDouble() ??
                                    0.0,
                                backgroundColor: theme.colors.border,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colors.primary,
                                ),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildDetailChip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = context.theme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: theme.colors.mutedForeground),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.typography.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colors.foreground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

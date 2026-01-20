import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forui/forui.dart';
import '../../providers/admin_provider.dart';
import '../../models/course.dart';
import '../../widgets/course_avatar.dart';
import 'add_training_csv_screen.dart';

class TrainingsScreen extends StatefulWidget {
  const TrainingsScreen({super.key});

  @override
  State<TrainingsScreen> createState() => _TrainingsScreenState();
}

class _TrainingsScreenState extends State<TrainingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadTrainings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        final allCourses = adminProvider.courses;

        final filteredCourses = allCourses;

        return Scaffold(
          backgroundColor: theme.colors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Trainings',
                                  style: theme.typography.xl2.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colors.foreground,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Swipe left on a course to delete it',
                                  style: TextStyle(
                                    color: theme.colors.mutedForeground,
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FButton(
                            style: FButtonStyle.outline,
                            onPress: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const AddTrainingCsvScreen(),
                                ),
                              );
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.upload_file, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Import CSV',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Courses list
                Expanded(
                  child:
                      adminProvider.isLoading
                          ? Center(
                            child: CircularProgressIndicator(
                              color: theme.colors.primary,
                            ),
                          )
                          : filteredCourses.isEmpty
                          ? _buildEmptyState(theme)
                          : RefreshIndicator(
                            onRefresh: () => adminProvider.loadTrainings(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: filteredCourses.length,
                              itemBuilder: (context, index) {
                                return _buildCourseCard(
                                  context,
                                  filteredCourses[index],
                                );
                              },
                            ),
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    final theme = context.theme;

    return Dismissible(
      key: Key(course.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context, course);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.colors.destructive,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: CourseAvatar(title: course.title, size: 40),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course.title,
                                      style: theme.typography.base.copyWith(
                                        color: theme.colors.foreground,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        course.category.toUpperCase(),
                                        style: TextStyle(
                                          color: theme.colors.primary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '₹${course.cost.toInt()}',
                                style: theme.typography.base.copyWith(
                                  color: theme.colors.foreground,
                                  fontWeight: FontWeight.bold,
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
                Text(
                  course.description,
                  style: TextStyle(
                    color: theme.colors.mutedForeground,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: theme.colors.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      course.duration,
                      style: TextStyle(
                        color: theme.colors.mutedForeground,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.bar_chart,
                      size: 14,
                      color: theme.colors.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      course.level,
                      style: TextStyle(
                        color: theme.colors.mutedForeground,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            course.isActive
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        course.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: course.isActive ? Colors.green : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, Course course) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => FDialog(
            title: const Text('Delete Course'),
            body: Text(
              'Are you sure you want to delete "${course.title}"? This action cannot be undone.',
            ),
            actions: [
              FButton(
                style: FButtonStyle.outline,
                onPress: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FButton(
                style: FButtonStyle.destructive,
                onPress: () async {
                  await context.read<AdminProvider>().deleteTraining(course.id);
                  if (context.mounted) Navigator.pop(context, true);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Widget _buildEmptyState(FThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: theme.colors.mutedForeground,
          ),
          const SizedBox(height: 16),
          Text(
            'No Training Courses Found',
            style: TextStyle(
              color: theme.colors.foreground,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Import courses via CSV or swipe left to delete existing ones.',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colors.mutedForeground),
          ),
        ],
      ),
    );
  }
}

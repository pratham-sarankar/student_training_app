import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forui/forui.dart';
import '../../providers/admin_provider.dart';
import '../../models/course.dart';
import '../../widgets/course_avatar.dart';
import 'add_training_csv_screen.dart';
import 'admin_domain_courses_screen.dart';

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

        // Group courses by domain
        final Map<String, List<Course>> domainGroups = {};
        for (var course in allCourses) {
          if (!domainGroups.containsKey(course.domain)) {
            domainGroups[course.domain] = [];
          }
          domainGroups[course.domain]!.add(course);
        }

        final domains = domainGroups.keys.toList()..sort();

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
                                  'Manage course domains and programs',
                                  style: TextStyle(
                                    color: theme.colors.mutedForeground,
                                    fontSize: 11,
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

                // Domains list
                Expanded(
                  child:
                      adminProvider.isLoading
                          ? Center(
                            child: CircularProgressIndicator(
                              color: theme.colors.primary,
                            ),
                          )
                          : domains.isEmpty
                          ? _buildEmptyState(theme)
                          : RefreshIndicator(
                            onRefresh: () => adminProvider.loadTrainings(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: domains.length,
                              itemBuilder: (context, index) {
                                final domain = domains[index];
                                final coursesInDomain = domainGroups[domain]!;

                                // Calculate total courses including sub-courses
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

                                return _buildDomainCard(
                                  context,
                                  domain,
                                  coursesInDomain,
                                  totalSubCourses,
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

  Widget _buildDomainCard(
    BuildContext context,
    String domain,
    List<Course> courses,
    int totalCount,
  ) {
    final theme = context.theme;

    return Dismissible(
      key: Key('domain_$domain'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDomainDeleteConfirmation(context, domain);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colors.destructive,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => AdminDomainCoursesScreen(
                    domain: domain,
                    courses: courses,
                  ),
            ),
          );
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
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
                        '$totalCount ${totalCount == 1 ? 'Program' : 'Programs'} available',
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
      ),
    );
  }

  Future<bool?> _showDomainDeleteConfirmation(
    BuildContext context,
    String domain,
  ) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => FDialog(
            title: const Text('Delete Domain'),
            body: Text(
              'Are you sure you want to delete the "$domain" domain and ALL courses inside it? This action cannot be undone.',
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
                  await context.read<AdminProvider>().deleteCoursesByDomain(
                    domain,
                  );
                  if (context.mounted) Navigator.pop(context, true);
                },
                child: const Text('Delete Domain'),
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

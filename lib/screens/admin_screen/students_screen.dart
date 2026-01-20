import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forui/forui.dart';
import 'package:learn_work/providers/admin_provider.dart';
import 'package:learn_work/models/traning.dart';
import 'package:learn_work/models/user.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh students list when app is resumed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final adminProvider = Provider.of<AdminProvider>(
            context,
            listen: false,
          );
          adminProvider.loadAllStudents();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Scaffold(
          backgroundColor: theme.colors.background,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Compact Header
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: theme.colors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Student Management',
                                      style: theme.typography.lg.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colors.foreground,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Manage student accounts and training progress',
                                      style: theme.typography.sm.copyWith(
                                        color: theme.colors.mutedForeground,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Students Table - Expanded to fill remaining space
                    Expanded(
                      child:
                          adminProvider.isLoading
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Loading students...',
                                      style: TextStyle(
                                        color: theme.colors.mutedForeground,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : _buildStudentsTable(context, adminProvider),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentsTable(
    BuildContext context,
    AdminProvider adminProvider,
  ) {
    final theme = context.theme;

    // Use original students list directly
    final studentsList = adminProvider.allStudents;

    if (studentsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: theme.colors.mutedForeground,
            ),
            const SizedBox(height: 12),
            Text(
              'No students found',
              style: TextStyle(
                fontSize: 16,
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Students will appear here once they register with the Student role',
              style: TextStyle(
                color: theme.colors.mutedForeground,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    // Sort students by name
    final sortedStudents = List<UserModel>.from(studentsList)
      ..sort((a, b) => a.fullName.compareTo(b.fullName));

    return RefreshIndicator(
      onRefresh: () async {
        final adminProvider = Provider.of<AdminProvider>(
          context,
          listen: false,
        );
        await adminProvider.loadAllStudents();
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: DataTable(
          columnSpacing: 12,
          horizontalMargin: 12,
          headingRowHeight: 32,
          columns: [
            DataColumn(
              label: Text(
                'Name',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: theme.colors.foreground,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: theme.colors.foreground,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Registration Date',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: theme.colors.foreground,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Profile Status',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: theme.colors.foreground,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Job Notifications',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: theme.colors.foreground,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Training Status',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: theme.colors.foreground,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: theme.colors.foreground,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
          rows:
              sortedStudents.map((student) {
                // Find which trainings this student is enrolled in
                final enrolledTrainings = <String>[];
                for (final enrolledCourseId in student.enrolledCourses) {
                  final training = adminProvider.trainings.firstWhere(
                    (t) =>
                        t.id == enrolledCourseId || t.title == enrolledCourseId,
                    orElse:
                        () => Training(
                          id: '',
                          title: enrolledCourseId,
                          description: '',
                          price: 0,
                          createdAt: DateTime.now(),
                        ),
                  );
                  enrolledTrainings.add(training.title);
                }

                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        student.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(
                      Text(
                        student.email,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatDate(student.createdAt),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                student.hasCompletedProfile
                                    ? theme.colors.primary.withValues(
                                      alpha: 0.1,
                                    )
                                    : theme.colors.mutedForeground.withValues(
                                      alpha: 0.1,
                                    ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            student.hasCompletedProfile
                                ? 'Complete'
                                : 'Incomplete',
                            style: TextStyle(
                              color:
                                  student.hasCompletedProfile
                                      ? theme.colors.primary
                                      : theme.colors.mutedForeground,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                student.jobAlerts
                                    ? theme.colors.primary.withValues(
                                      alpha: 0.1,
                                    )
                                    : theme.colors.destructive.withValues(
                                      alpha: 0.1,
                                    ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            student.jobAlerts ? 'Subscribed' : 'Not Subscribed',
                            style: TextStyle(
                              color:
                                  student.jobAlerts
                                      ? theme.colors.primary
                                      : theme.colors.destructive,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        enrolledTrainings.isNotEmpty
                            ? enrolledTrainings.join(', ')
                            : 'Not enrolled',
                        style: TextStyle(
                          color:
                              enrolledTrainings.isNotEmpty
                                  ? theme.colors.mutedForeground
                                  : theme.colors.mutedForeground,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(
                      Center(
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 18),
                          tooltip: 'Actions',
                          color: theme.colors.background,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: theme.colors.border),
                          ),
                          onSelected: (value) {
                            if (value == 'details') {
                              _showStudentDetails(
                                context,
                                student,
                                adminProvider,
                              );
                            } else if (value == 'toggle') {
                              _toggleSubscription(
                                context,
                                student,
                                adminProvider,
                              );
                            }
                          },
                          itemBuilder:
                              (context) => [
                                PopupMenuItem<String>(
                                  value: 'details',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info,
                                        color: theme.colors.primary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'View Details',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'toggle',
                                  child: Row(
                                    children: [
                                      Icon(
                                        student.jobAlerts
                                            ? Icons.notifications_off
                                            : Icons.notifications_active,
                                        color:
                                            student.jobAlerts
                                                ? theme.colors.mutedForeground
                                                : theme.colors.primary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        student.jobAlerts
                                            ? 'Unsubscribe'
                                            : 'Subscribe',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showStudentDetails(
    BuildContext context,
    UserModel student,
    AdminProvider adminProvider,
  ) {
    final theme = context.theme;

    // Find all trainings this student is enrolled in
    final enrollments = <Training>[];

    for (final enrolledCourseId in student.enrolledCourses) {
      final training = adminProvider.trainings.firstWhere(
        (t) => t.id == enrolledCourseId || t.title == enrolledCourseId,
        orElse:
            () => Training(
              id: enrolledCourseId,
              title: enrolledCourseId,
              description: 'Details not found',
              price: 0,
              createdAt: DateTime.now(),
            ),
      );
      enrollments.add(training);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: theme.colors.background,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 32,
                        height: 3,
                        decoration: BoxDecoration(
                          color: theme.colors.mutedForeground,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: theme.colors.primaryForeground,
                              child: Icon(
                                Icons.person,
                                color: theme.colors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.fullName,
                                    style: theme.typography.lg.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Student Details',
                                    style: theme.typography.sm.copyWith(
                                      color: theme.colors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.close, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: theme.colors.mutedForeground
                                    .withValues(alpha: 0.1),
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(8),
                                minimumSize: const Size(32, 32),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Basic Info Section
                              _buildInfoSection('Basic Information', [
                                _buildInfoTile(
                                  Icons.email,
                                  'Email',
                                  student.email,
                                  theme.colors.primary,
                                ),
                                if (student.phoneNumber != null &&
                                    student.phoneNumber!.isNotEmpty)
                                  _buildInfoTile(
                                    Icons.phone,
                                    'Phone',
                                    student.phoneNumber!,
                                    theme.colors.primary,
                                  ),
                                _buildInfoTile(
                                  Icons.calendar_today,
                                  'Registration Date',
                                  _formatDate(student.createdAt),
                                  theme.colors.primary,
                                ),
                                if (student.dateOfBirth != null)
                                  _buildInfoTile(
                                    Icons.cake,
                                    'Date of Birth',
                                    student.formattedDateOfBirth ?? 'N/A',
                                    theme.colors.primary,
                                  ),
                                _buildInfoTile(
                                  student.jobAlerts
                                      ? Icons.notifications_active
                                      : Icons.notifications_off,
                                  'Job Notifications',
                                  student.jobAlerts
                                      ? 'Subscribed'
                                      : 'Not Subscribed',
                                  student.jobAlerts
                                      ? theme.colors.primary
                                      : theme.colors.destructive,
                                ),
                                _buildInfoTile(
                                  student.hasCompletedProfile
                                      ? Icons.check_circle
                                      : Icons.info_outline,
                                  'Profile Status',
                                  student.hasCompletedProfile
                                      ? 'Complete'
                                      : 'Incomplete',
                                  student.hasCompletedProfile
                                      ? theme.colors.primary
                                      : theme.colors.mutedForeground,
                                ),
                              ]),
                              if (student.bio != null &&
                                  student.bio!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildInfoSection('Bio', [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colors.mutedForeground
                                          .withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.colors.border,
                                      ),
                                    ),
                                    child: Text(
                                      student.bio!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: theme.colors.foreground,
                                      ),
                                    ),
                                  ),
                                ]),
                              ],
                              if (student.jobCategories.isNotEmpty ||
                                  student.preferredLocations.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildInfoSection('Preferences', [
                                  if (student.jobCategories.isNotEmpty)
                                    _buildInfoTile(
                                      Icons.work,
                                      'Job Categories',
                                      student.jobCategories.join(', '),
                                      theme.colors.primary,
                                    ),
                                  if (student.preferredLocations.isNotEmpty)
                                    _buildInfoTile(
                                      Icons.location_on,
                                      'Preferred Locations',
                                      student.preferredLocations.join(', '),
                                      theme.colors.primary,
                                    ),
                                ]),
                              ],
                              const SizedBox(height: 16),
                              // Enrollments Section
                              _buildInfoSection(
                                enrollments.isNotEmpty
                                    ? 'Enrolled in ${enrollments.length} course(s)'
                                    : 'Not enrolled in any courses',
                                enrollments.isNotEmpty
                                    ? enrollments
                                        .map(
                                          (enrollment) => _buildEnrollmentTile(
                                            context,
                                            enrollment,
                                          ),
                                        )
                                        .toList()
                                    : [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: theme.colors.mutedForeground
                                              .withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: theme.colors.border,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color:
                                                  theme.colors.mutedForeground,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'This student has not enrolled in any training schedules yet.',
                                                style: TextStyle(
                                                  color:
                                                      theme
                                                          .colors
                                                          .mutedForeground,
                                                  fontSize: 12,
                                                ),
                                              ),
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
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: theme.colors.foreground,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
  ) {
    final theme = context.theme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colors.mutedForeground.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentTile(BuildContext context, Training training) {
    final theme = context.theme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colors.border),
        boxShadow: [
          BoxShadow(
            color: theme.colors.border,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, color: theme.colors.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  training.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: theme.colors.foreground,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleSubscription(
    BuildContext context,
    UserModel student,
    AdminProvider adminProvider,
  ) async {
    final theme = context.theme;

    try {
      await adminProvider.updateUserJobAlerts(student.uid, !student.jobAlerts);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !student.jobAlerts
                ? '${student.fullName} subscribed to job notifications'
                : '${student.fullName} unsubscribed from job notifications',
          ),
          backgroundColor:
              !student.jobAlerts
                  ? theme.colors.primary
                  : theme.colors.mutedForeground,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update job notifications: $e'),
          backgroundColor: theme.colors.destructive,
        ),
      );
    }
  }
}

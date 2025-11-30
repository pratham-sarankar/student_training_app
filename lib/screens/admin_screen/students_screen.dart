import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final theme = Theme.of(context);

    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
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
                                color: theme.colorScheme.primary,
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
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Manage student accounts and training progress',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color:
                                                theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
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
                                        theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Loading students...',
                                      style: TextStyle(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);

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
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No students found',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Students will appear here once they register with the Student role',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
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
                  color: theme.colorScheme.onSurface,
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
                  color: theme.colorScheme.onSurface,
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
                  color: theme.colorScheme.onSurface,
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
                  color: theme.colorScheme.onSurface,
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
                  color: theme.colorScheme.onSurface,
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
                  color: theme.colorScheme.onSurface,
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
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
          rows:
              sortedStudents.map((student) {
                // Find which trainings this student is enrolled in
                final enrolledTrainings = <String>[];
                for (final training in adminProvider.trainings) {
                  for (final schedule in training.schedules) {
                    if (schedule.enrolledStudents.any(
                      (s) => s.id == student.uid,
                    )) {
                      enrolledTrainings.add(training.title);
                      break; // Only add training once even if student has multiple schedules
                    }
                  }
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
                                    ? theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    )
                                    : theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            student.hasCompletedProfile
                                ? 'Complete'
                                : 'Incomplete',
                            style: TextStyle(
                              color:
                                  student.hasCompletedProfile
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
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
                                    ? theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    )
                                    : theme.colorScheme.error.withValues(
                                      alpha: 0.1,
                                    ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            student.jobAlerts ? 'Subscribed' : 'Not Subscribed',
                            style: TextStyle(
                              color:
                                  student.jobAlerts
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.error,
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
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onSurfaceVariant,
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
                          color: theme.colorScheme.surface,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: theme.colorScheme.outline),
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
                                        color: theme.colorScheme.primary,
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
                                                ? theme
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                : theme.colorScheme.primary,
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
    final theme = Theme.of(context);

    // Find all schedules this student is enrolled in
    final enrollments = <MapEntry<String, TrainingSchedule>>[];

    for (final training in adminProvider.trainings) {
      for (final schedule in training.schedules) {
        if (schedule.enrolledStudents.any((s) => s.id == student.uid)) {
          enrollments.add(MapEntry(training.title, schedule));
        }
      }
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
                    color: theme.colorScheme.surface,
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
                          color: theme.colorScheme.onSurfaceVariant,
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
                              backgroundColor: theme.colorScheme.onPrimary,
                              child: Icon(
                                Icons.person,
                                color: theme.colorScheme.primary,
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
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Student Details',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.close, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: theme
                                    .colorScheme
                                    .onSurfaceVariant
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
                                  theme.colorScheme.primary,
                                ),
                                if (student.phoneNumber != null &&
                                    student.phoneNumber!.isNotEmpty)
                                  _buildInfoTile(
                                    Icons.phone,
                                    'Phone',
                                    student.phoneNumber!,
                                    theme.colorScheme.primary,
                                  ),
                                _buildInfoTile(
                                  Icons.calendar_today,
                                  'Registration Date',
                                  _formatDate(student.createdAt),
                                  theme.colorScheme.primary,
                                ),
                                if (student.dateOfBirth != null)
                                  _buildInfoTile(
                                    Icons.cake,
                                    'Date of Birth',
                                    student.formattedDateOfBirth ?? 'N/A',
                                    theme.colorScheme.primary,
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
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.error,
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
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ]),
                              if (student.bio != null &&
                                  student.bio!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildInfoSection('Bio', [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.colorScheme.outline,
                                      ),
                                    ),
                                    child: Text(
                                      student.bio!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: theme.colorScheme.onSurface,
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
                                      theme.colorScheme.primary,
                                    ),
                                  if (student.preferredLocations.isNotEmpty)
                                    _buildInfoTile(
                                      Icons.location_on,
                                      'Preferred Locations',
                                      student.preferredLocations.join(', '),
                                      theme.colorScheme.primary,
                                    ),
                                ]),
                              ],
                              const SizedBox(height: 16),
                              // Enrollments Section
                              _buildInfoSection(
                                enrollments.isNotEmpty
                                    ? 'Enrolled in ${enrollments.length} schedule(s)'
                                    : 'Not enrolled in any training schedules',
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
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: theme.colorScheme.outline,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color:
                                                  theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'This student has not enrolled in any training schedules yet.',
                                                style: TextStyle(
                                                  color:
                                                      theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: theme.colorScheme.onSurface,
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
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline),
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
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentTile(
    BuildContext context,
    MapEntry<String, TrainingSchedule> enrollment,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.outline,
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
              Icon(Icons.school, color: theme.colorScheme.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  enrollment.key,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: theme.colorScheme.onSurfaceVariant,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                '${_formatDate(enrollment.value.startDate)} - ${_formatDate(enrollment.value.endDate)}',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
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
    final theme = Theme.of(context);

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
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update job notifications: $e'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }
}

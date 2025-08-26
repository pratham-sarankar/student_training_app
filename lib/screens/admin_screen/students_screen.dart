import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forui/forui.dart';
import 'package:learn_work/providers/admin_provider.dart';
import 'package:learn_work/models/traning.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header - Made more compact
                    LayoutBuilder(
                      builder: (context, constraints) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      color: Theme.of(context).colorScheme.primary,
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
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            'View all students and their subscription status',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                      },
                    ),
                    const SizedBox(height: 6),
                    // Students Table
                    Expanded(
                      child: _buildStudentsTable(context, adminProvider),
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

  Widget _buildStudentsTable(BuildContext context, AdminProvider adminProvider) {
    // Collect all students from all trainings
    final allStudents = <String, EnrolledStudent>{};
    
    for (final training in adminProvider.trainings) {
      for (final schedule in training.schedules) {
        for (final student in schedule.enrolledStudents) {
          allStudents[student.id] = student;
        }
      }
    }

    if (allStudents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text(
              'No students enrolled',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Students will appear here once they enroll in training schedules',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    final studentsList = allStudents.values.toList();
    
    // Sort students by name
    studentsList.sort((a, b) => a.name.compareTo(b.name));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: DataTable(
        columnSpacing: 12,
        horizontalMargin: 12,
        dataRowHeight: 36,
        headingRowHeight: 32,
        columns: [
          DataColumn(
            label: Text(
              'Name',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
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
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 0.2,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Enrolled Date',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
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
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 0.2,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Enrolled In',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
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
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
        rows: studentsList.map((student) {
          // Find which trainings this student is enrolled in
          final enrolledTrainings = <String>[];
          for (final training in adminProvider.trainings) {
            for (final schedule in training.schedules) {
              if (schedule.enrolledStudents.any((s) => s.id == student.id)) {
                enrolledTrainings.add(training.title);
                break; // Only add training once even if student has multiple schedules
              }
            }
          }

          return DataRow(
            cells: [
              DataCell(
                Text(
                  student.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
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
                  _formatDate(student.enrolledDate),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              DataCell(
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: student.isSubscribedToJobs ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      student.isSubscribedToJobs ? 'Subscribed' : 'Not Subscribed',
                      style: TextStyle(
                        color: student.isSubscribedToJobs ? Colors.green[800] : Colors.red[800],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  enrolledTrainings.join(', '),
                  style: TextStyle(
                    color: Colors.grey[600],
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
                    color: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    onSelected: (value) {
                      if (value == 'details') {
                        _showStudentDetails(context, student, adminProvider);
                      } else if (value == 'toggle') {
                        _toggleSubscription(context, student, adminProvider);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'details',
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue, size: 16),
                            SizedBox(width: 8),
                            Text('View Details', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              student.isSubscribedToJobs ? Icons.notifications_off : Icons.notifications_active,
                              color: student.isSubscribedToJobs ? Colors.orange : Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              student.isSubscribedToJobs ? 'Unsubscribe' : 'Subscribe',
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
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showStudentDetails(BuildContext context, EnrolledStudent student, AdminProvider adminProvider) {
    // Find all schedules this student is enrolled in
    final enrollments = <MapEntry<String, TrainingSchedule>>[];
    
    for (final training in adminProvider.trainings) {
      for (final schedule in training.schedules) {
        if (schedule.enrolledStudents.any((s) => s.id == student.id)) {
          enrollments.add(MapEntry(training.title, schedule));
        }
      }
    }

        showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 32,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
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
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Student Details',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
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
                      _buildInfoSection(
                        'Basic Information',
                        [
                          _buildInfoTile(
                            Icons.email,
                            'Email',
                            student.email,
                            Colors.blue,
                          ),
                          _buildInfoTile(
                            Icons.calendar_today,
                            'Enrolled Date',
                            _formatDate(student.enrolledDate),
                            Colors.green,
                          ),
                          _buildInfoTile(
                            student.isSubscribedToJobs ? Icons.notifications_active : Icons.notifications_off,
                            'Job Notifications',
                            student.isSubscribedToJobs ? 'Subscribed' : 'Not Subscribed',
                            student.isSubscribedToJobs ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Enrollments Section
                      _buildInfoSection(
                        'Enrolled in ${enrollments.length} schedule(s)',
                        enrollments.map((enrollment) => _buildEnrollmentTile(context, enrollment)).toList(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
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
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentTile(BuildContext context, MapEntry<String, TrainingSchedule> enrollment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
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
              Icon(
                Icons.school,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  enrollment.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
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
                color: Colors.grey[600],
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                '${_formatDate(enrollment.value.startDate)} - ${_formatDate(enrollment.value.endDate)}',
                style: TextStyle(
                  color: Colors.grey[600],
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

  void _toggleSubscription(BuildContext context, EnrolledStudent student, AdminProvider adminProvider) {
    // Create a new student with toggled subscription status
    final updatedStudent = student.copyWith(
      isSubscribedToJobs: !student.isSubscribedToJobs,
    );

    // Update the student in all trainings and schedules
    for (final training in adminProvider.trainings) {
      for (final schedule in training.schedules) {
        final studentIndex = schedule.enrolledStudents.indexWhere((s) => s.id == student.id);
        if (studentIndex != -1) {
          // Update the student in this schedule
          final updatedSchedule = schedule.copyWith(
            enrolledStudents: List.from(schedule.enrolledStudents)
              ..[studentIndex] = updatedStudent,
          );
          
          // Update the schedule in the training
          final updatedTraining = training.copyWith(
            schedules: training.schedules.map((s) => 
              s.id == schedule.id ? updatedSchedule : s
            ).toList(),
          );
          
          // Update the training in the provider
          adminProvider.updateTraining(updatedTraining);
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedStudent.isSubscribedToJobs 
            ? '${student.name} subscribed to job notifications'
            : '${student.name} unsubscribed from job notifications',
        ),
        backgroundColor: updatedStudent.isSubscribedToJobs ? Colors.green : Colors.orange,
      ),
    );
  }
}

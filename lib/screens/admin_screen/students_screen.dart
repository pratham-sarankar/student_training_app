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

class _StudentsScreenState extends State<StudentsScreen> with WidgetsBindingObserver {
  
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
          final adminProvider = Provider.of<AdminProvider>(context, listen: false);
          adminProvider.loadAllStudents();
        }
      });
    }
  }

  void _exportStudentsList(List<UserModel> students) {
    // For now, just show a message
    // In a real implementation, this would generate a CSV or PDF file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Export functionality for ${students.length} students needs to be implemented',
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

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
                                    const SizedBox(height: 2),
                                    Text(
                                      'Manage student accounts and training progress',
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
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Students Table - Expanded to fill remaining space
                    Expanded(
                      child: adminProvider.isLoading 
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text(
                                  'Loading students...',
                                  style: TextStyle(
                                    color: Colors.grey,
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

  Widget _buildStudentsTable(BuildContext context, AdminProvider adminProvider) {
    // Use original students list directly
    final studentsList = adminProvider.allStudents;
    
    if (studentsList.isEmpty) {
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
              'No students found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Students will appear here once they register with the Student role',
              style: TextStyle(
                color: Colors.grey,
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
        final adminProvider = Provider.of<AdminProvider>(context, listen: false);
        await adminProvider.loadAllStudents();
      },
      child: SingleChildScrollView(
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
              'Registration Date',
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
              'Profile Status',
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
              'Training Status',
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
        rows: sortedStudents.map((student) {
          // Find which trainings this student is enrolled in
          final enrolledTrainings = <String>[];
          for (final training in adminProvider.trainings) {
            for (final schedule in training.schedules) {
              if (schedule.enrolledStudents.any((s) => s.id == student.uid)) {
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
                  _formatDate(student.createdAt),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              DataCell(
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: student.hasCompletedProfile ? Colors.green[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      student.hasCompletedProfile ? 'Complete' : 'Incomplete',
                      style: TextStyle(
                        color: student.hasCompletedProfile ? Colors.green[800] : Colors.orange[800],
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: student.jobAlerts ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      student.jobAlerts ? 'Subscribed' : 'Not Subscribed',
                      style: TextStyle(
                        color: student.jobAlerts ? Colors.green[800] : Colors.red[800],
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
                    color: enrolledTrainings.isNotEmpty ? Colors.grey[600] : Colors.orange[600],
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
                              student.jobAlerts ? Icons.notifications_off : Icons.notifications_active,
                              color: student.jobAlerts ? Colors.orange : Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              student.jobAlerts ? 'Unsubscribe' : 'Subscribe',
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

  void _showStudentDetails(BuildContext context, UserModel student, AdminProvider adminProvider) {
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
                            student.fullName,
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
                          if (student.phoneNumber != null && student.phoneNumber!.isNotEmpty)
                            _buildInfoTile(
                              Icons.phone,
                              'Phone',
                              student.phoneNumber!,
                              Colors.green,
                            ),
                          _buildInfoTile(
                            Icons.calendar_today,
                            'Registration Date',
                            _formatDate(student.createdAt),
                            Colors.green,
                          ),
                          if (student.dateOfBirth != null)
                            _buildInfoTile(
                              Icons.cake,
                              'Date of Birth',
                              student.formattedDateOfBirth ?? 'N/A',
                              Colors.purple,
                            ),
                          _buildInfoTile(
                            student.jobAlerts ? Icons.notifications_active : Icons.notifications_off,
                            'Job Notifications',
                            student.jobAlerts ? 'Subscribed' : 'Not Subscribed',
                            student.jobAlerts ? Colors.green : Colors.red,
                          ),
                          _buildInfoTile(
                            student.hasCompletedProfile ? Icons.check_circle : Icons.info_outline,
                            'Profile Status',
                            student.hasCompletedProfile ? 'Complete' : 'Incomplete',
                            student.hasCompletedProfile ? Colors.green : Colors.orange,
                          ),
                        ],
                      ),
                      if (student.bio != null && student.bio!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildInfoSection(
                          'Bio',
                          [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Text(
                                student.bio!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (student.jobCategories.isNotEmpty || student.preferredLocations.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildInfoSection(
                          'Preferences',
                          [
                            if (student.jobCategories.isNotEmpty)
                              _buildInfoTile(
                                Icons.work,
                                'Job Categories',
                                student.jobCategories.join(', '),
                                Colors.blue,
                              ),
                            if (student.preferredLocations.isNotEmpty)
                              _buildInfoTile(
                                Icons.location_on,
                                'Preferred Locations',
                                student.preferredLocations.join(', '),
                                Colors.green,
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Enrollments Section
                      _buildInfoSection(
                        enrollments.isNotEmpty 
                          ? 'Enrolled in ${enrollments.length} schedule(s)'
                          : 'Not enrolled in any training schedules',
                        enrollments.isNotEmpty 
                          ? enrollments.map((enrollment) => _buildEnrollmentTile(context, enrollment)).toList()
                          : [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.orange[600], size: 18),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'This student has not enrolled in any training schedules yet.',
                                        style: TextStyle(
                                          color: Colors.orange[800],
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

  void _toggleSubscription(BuildContext context, UserModel student, AdminProvider adminProvider) async {
    try {
      await adminProvider.updateUserJobAlerts(student.uid, !student.jobAlerts);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !student.jobAlerts 
              ? '${student.fullName} subscribed to job notifications'
              : '${student.fullName} unsubscribed from job notifications',
          ),
          backgroundColor: !student.jobAlerts ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update job notifications: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

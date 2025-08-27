import 'package:flutter/material.dart';
import 'package:learn_work/screens/admin_screen/instructor_chat_screen.dart';
import 'package:provider/provider.dart';
import 'package:forui/forui.dart';
import 'package:learn_work/providers/admin_provider.dart';
import 'package:learn_work/models/traning.dart';
import 'package:learn_work/screens/admin_screen/add_edit_training_screen.dart';
import 'package:learn_work/screens/admin_screen/upload_note_screen.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Training training;

  const CourseDetailsScreen({super.key, required this.training});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  Training? _currentTraining;

  @override
  void initState() {
    super.initState();
    _currentTraining = widget.training;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        // Get the latest training data from the provider
        final latestTraining = adminProvider.trainings.firstWhere(
          (t) => t.id == widget.training.id,
          orElse: () => _currentTraining ?? widget.training,
        );
        
        // Update current training if it changed
        if (_currentTraining != latestTraining) {
          _currentTraining = latestTraining;
        }

        // Use the latest training data
        final training = _currentTraining ?? widget.training;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              training.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.withOpacity(0.1),
                foregroundColor: Colors.grey[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _showTrainingFormDialog(context),
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: 'Edit Course',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
               IconButton(
                 onPressed: () => _deleteTraining(context),
                 icon: const Icon(Icons.delete_outline, size: 20),
                 tooltip: 'Delete Course',
                 style: IconButton.styleFrom(
                   backgroundColor: Colors.red.withOpacity(0.1),
                   foregroundColor: Colors.red,
                 ),
               ),
               const SizedBox(width: 8),
            ],
          ),
           body: SingleChildScrollView(
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Header Section
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.school,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  training.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  training.description,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.attach_money,
                              title: 'Price',
                              value: '₹${training.price.toStringAsFixed(2)}',
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.schedule,
                              title: 'Schedules',
                              value: '${training.schedules.length}',
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.people,
                              title: 'Total Students',
                              value: '${training.schedules.fold(0, (sum, schedule) => sum + schedule.enrolledStudents.length)}',
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Quick Actions Section
                Container(
                  width: double.infinity,
                  color: Colors.grey[50],
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.flash_on,
                            color: Theme.of(context).colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Quick Actions',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              icon: Icons.add,
                              title: 'Add Schedule',
                              subtitle: 'Create new course schedule',
                              onTap: () => _showScheduleFormDialog(context),
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              icon: Icons.upload_file,
                              title: 'Upload Notes',
                              subtitle: 'Add course materials',
                              onTap: () => _showUploadNoteScreen(context, training.id),
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              icon: Icons.chat,
                              title: 'Course Chat',
                              subtitle: 'View student messages',
                              onTap: () => _showInstructorChat(context),
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Course Content Summary Section
                if (training.schedules.any((schedule) => schedule.notes.isNotEmpty)) ...[
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.folder_open,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Course Content',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Notes: ${training.schedules.fold(0, (sum, schedule) => sum + schedule.notes.length)}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Notes are available across ${training.schedules.where((schedule) => schedule.notes.isNotEmpty).length} schedules',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Schedules Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
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
                              'Course Schedules',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Manage course schedules and student enrollments',
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
                ),
                
                // Schedules List
                if (training.schedules.isEmpty)
                  _buildEmptySchedulesState()
                else
                  ...training.schedules.map((schedule) => _buildScheduleCard(context, schedule)),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySchedulesState() {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.schedule_outlined,
                  size: 40,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No Schedules Yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create your first schedule to start\nenrolling students',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyEnrolledStudentsState() {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.people_outline,
                  size: 40,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No Students Enrolled Yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Once students enroll, they will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, TrainingSchedule schedule) {
    final enrollmentPercentage = schedule.capacity > 0 
        ? (schedule.enrolledStudents.length / schedule.capacity * 100).round()
        : 0;
    final isFull = schedule.enrolledStudents.length >= schedule.capacity;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isFull 
                    ? Colors.red.withOpacity(0.1)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                isFull ? Icons.event_busy : Icons.calendar_today,
                color: isFull 
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_formatDate(schedule.startDate)} - ${_formatDate(schedule.endDate)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 11,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        schedule.time.format(context),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.people,
                        size: 11,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${schedule.enrolledStudents.length}/${schedule.capacity} enrolled',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Enrollment status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: isFull 
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isFull 
                      ? Colors.red.withOpacity(0.3)
                      : Colors.green.withOpacity(0.3),
                ),
              ),
              child: Text(
                isFull ? 'Full' : 'Available',
                style: TextStyle(
                  color: isFull 
                      ? Colors.red
                      : Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          color: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditScheduleDialog(context, schedule);
                break;
              case 'delete':
                _deleteSchedule(context, schedule);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit Schedule'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16),
                  SizedBox(width: 8),
                  Text('Delete Schedule'),
                ],
              ),
            ),
          ],
          child: const Icon(Icons.more_vert),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        childrenPadding: EdgeInsets.zero,
        maintainState: true,
        children: [
          // Enrolled Students Section
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.school,
                      size: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Enrolled Students (${schedule.enrolledStudents.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (schedule.enrolledStudents.isEmpty)
                  _buildEmptyEnrolledStudentsState()
                else
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: schedule.enrolledStudents.map((student) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person,
                              size: 10,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              student.name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showTrainingFormDialog(BuildContext context) {
    final adminProvider = context.read<AdminProvider>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: adminProvider,
          child: AddEditTrainingScreen(training: _currentTraining ?? widget.training),
        ),
      ),
    );
  }

  void _showScheduleFormDialog(BuildContext context) {
    _showScheduleDialog(context);
  }

  void _showEditScheduleDialog(BuildContext context, TrainingSchedule schedule) {
    _showScheduleDialog(context, schedule: schedule);
  }

    void _showScheduleDialog(BuildContext context, {TrainingSchedule? schedule}) {
    // Get the admin provider from the current context before showing the bottom sheet
    final adminProvider = context.read<AdminProvider>();
    final currentTraining = adminProvider.trainings.firstWhere(
      (t) => t.id == widget.training.id,
      orElse: () => _currentTraining ?? widget.training,
    );
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 20,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                                         child: ScheduleDialog(
                       schedule: schedule,
                       onSave: (newSchedule) async {
                         try {
                           // Handle schedule save/update
                           if (schedule != null) {
                             // Update existing schedule
                             await adminProvider.updateScheduleInTraining(currentTraining.id, newSchedule);
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(
                                 content: Text('Schedule updated successfully'),
                                 backgroundColor: Colors.green,
                               ),
                             );
                           } else {
                             // Add new schedule
                             await adminProvider.addScheduleToTraining(currentTraining.id, newSchedule);
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(
                                 content: Text('Schedule added successfully'),
                                 backgroundColor: Colors.green,
                               ),
                             );
                           }
                           
                           // Close the bottom sheet
                           Navigator.of(context).pop();
                           
                           // Refresh the training data from the provider
                           await adminProvider.loadTrainings();
                           
                           // Update the local current training reference
                           final updatedTraining = adminProvider.trainings.firstWhere(
                             (t) => t.id == widget.training.id,
                             orElse: () => widget.training,
                           );
                           setState(() {
                             _currentTraining = updatedTraining;
                           });
                         } catch (e) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                               content: Text('Error: ${e.toString()}'),
                               backgroundColor: Colors.red,
                             ),
                           );
                         }
                       },
                     ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteSchedule(BuildContext context, TrainingSchedule schedule) {
    try {
      // Get the admin provider from the current context before showing the dialog
      final adminProvider = context.read<AdminProvider>();
      
      showDialog(
        context: context,
        builder: (dialogContext) => FDialog(
          title: const Text('Delete Schedule'),
          body: Text(
            'Are you sure you want to delete this schedule?\n\n'
            'This will permanently delete:\n'
            '• Schedule: ${_formatDate(schedule.startDate)} - ${_formatDate(schedule.endDate)}\n'
            '• All student enrollments (${schedule.enrolledStudents.length} students)\n'
            '• All schedule materials and notes\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            FButton(
              style: FButtonStyle.outline,
              onPress: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FButton(
              style: FButtonStyle.primary,
              onPress: () async {
                try {
                  // Show loading state
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleting schedule...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  
                  // Delete the schedule using the admin provider from the parent context
                  final currentTraining = adminProvider.trainings.firstWhere(
                    (t) => t.id == widget.training.id,
                    orElse: () => _currentTraining ?? widget.training,
                  );
                  
                  await adminProvider.deleteScheduleFromTraining(currentTraining.id, schedule.id);
                
                  // Close the modal
                  Navigator.of(dialogContext).pop();
                  
                  // Force a rebuild by updating the local state immediately
                  setState(() {
                    // Remove the schedule from local state as well
                    if (_currentTraining != null) {
                      _currentTraining!.schedules.removeWhere((s) => s.id == schedule.id);
                    }
                  });
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Schedule deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete schedule: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to show delete dialog: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteTraining(BuildContext context) {
    // Get the admin provider from the current context before showing the dialog
    final adminProvider = context.read<AdminProvider>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => FDialog(
        title: const Text('Delete Training'),
        body: Text(
          'Are you sure you want to delete "${_currentTraining?.title ?? widget.training.title}"?\n\n'
          'This will permanently delete:\n'
          '• All course schedules (${_currentTraining?.schedules.length ?? widget.training.schedules.length})\n'
          '• All student enrollments\n'
          '• All course materials and notes\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          FButton(
            style: FButtonStyle.outline,
            onPress: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FButton(
            style: FButtonStyle.primary,
            onPress: () async {
              try {
                // Show loading state
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Deleting training...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                
                // Delete the training using the admin provider from the parent context
                final currentTraining = adminProvider.trainings.firstWhere(
                  (t) => t.id == widget.training.id,
                  orElse: () => _currentTraining ?? widget.training,
                );
                
                await adminProvider.deleteTraining(currentTraining.id);
                
                // Ensure the state is properly updated before navigation
                // Wait for the admin provider to finish processing the deletion
                await Future.delayed(const Duration(milliseconds: 200));
                
                // Verify that the training was actually deleted from the admin provider
                final remainingTraining = adminProvider.trainings.any((t) => t.id == currentTraining.id);
                if (remainingTraining) {
                  // Force a refresh of the admin provider
                  await adminProvider.loadTrainings();
                }
                
                // Close the modal and navigate back
                Navigator.of(dialogContext).pop();
                
                // Navigate back to trainings list
                Navigator.of(context).pop(); // Go back to trainings list
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Training deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete training: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }


  void _showUploadNoteScreen(BuildContext context, String trainingId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadNoteScreen(
          trainingId: trainingId,
          training: _currentTraining ?? widget.training,
        ),
      ),
    );
  }

  void _showInstructorChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstructorChatScreen(
          courseId: _currentTraining?.id ?? widget.training.id,
          courseTitle: _currentTraining?.title ?? widget.training.title,
          studentId: '',
          studentName: '',
          studentEmail: '',
        ),
      ),
    );
  }

}

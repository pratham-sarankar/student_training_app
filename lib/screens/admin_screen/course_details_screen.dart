import 'package:flutter/material.dart';
import 'package:learn_work/screens/admin_screen/instructor_chat_screen.dart';
import 'package:provider/provider.dart';
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
    final theme = Theme.of(context);

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
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: Text(
              training.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                foregroundColor: theme.colorScheme.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _showTrainingFormDialog(context),
                icon: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                tooltip: 'Edit Course',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: () => _deleteTraining(context),
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: theme.colorScheme.error,
                ),
                tooltip: 'Delete Course',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.error.withValues(
                    alpha: 0.1,
                  ),
                  foregroundColor: theme.colorScheme.error,
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
                  color: theme.colorScheme.surface,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.school,
                              color: theme.colorScheme.primary,
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
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  training.description,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
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
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.schedule,
                              title: 'Schedules',
                              value: '${training.schedules.length}',
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.people,
                              title: 'Total Students',
                              value:
                                  '${training.schedules.fold(0, (sum, schedule) => sum + schedule.enrolledStudents.length)}',
                              color: theme.colorScheme.primary,
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
                  color: theme.colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.flash_on,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Quick Actions',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              icon: Icons.add,
                              title: 'Add Schedule',
                              subtitle: 'New schedule',
                              onTap: () => _showScheduleFormDialog(context),
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              icon: Icons.upload_file,
                              title: 'Upload Notes',
                              subtitle: 'Add course materials',
                              onTap:
                                  () => _showUploadNoteScreen(
                                    context,
                                    training.id,
                                  ),
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildQuickActionCard(
                              context,
                              icon: Icons.chat,
                              title: 'Course Chat',
                              subtitle: 'View messages',
                              onTap: () => _showInstructorChat(context),
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Course Content Summary Section
                if (training.schedules.any(
                  (schedule) => schedule.notes.isNotEmpty,
                )) ...[
                  Container(
                    width: double.infinity,
                    color: theme.colorScheme.surface,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.folder_open,
                              color: theme.colorScheme.secondary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Course Content',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Notes: ${training.schedules.fold(0, (sum, schedule) => sum + schedule.notes.length)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Notes are available across ${training.schedules.where((schedule) => schedule.notes.isNotEmpty).length} schedules',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
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
                              'Course Schedules',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Manage course schedules and student enrollments',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
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
                  ...training.schedules.map(
                    (schedule) => _buildScheduleCard(context, schedule),
                  ),

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
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 6),
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color.withValues(alpha: 0.7),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
    final theme = Theme.of(context);

    return Builder(
      builder:
          (context) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.schedule_outlined,
                      size: 40,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Schedules Yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create your first schedule to start\nenrolling students',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildEmptyEnrolledStudentsState() {
    final theme = Theme.of(context);

    return Builder(
      builder:
          (context) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.people_outline,
                      size: 40,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Students Enrolled Yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Once students enroll, they will appear here.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, TrainingSchedule schedule) {
    final theme = Theme.of(context);

    final isFull = schedule.enrolledStudents.length >= schedule.capacity;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
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
                color:
                    isFull
                        ? theme.colorScheme.error.withValues(alpha: 0.1)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                isFull ? Icons.event_busy : Icons.calendar_today,
                color:
                    isFull
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        schedule.time.format(context),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.people,
                        size: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${schedule.enrolledStudents.length}/${schedule.capacity} enrolled',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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
                color:
                    isFull
                        ? theme.colorScheme.error.withValues(alpha: 0.1)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      isFull
                          ? theme.colorScheme.error.withValues(alpha: 0.3)
                          : theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                isFull ? 'Full' : 'Available',
                style: TextStyle(
                  color:
                      isFull
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          color: theme.colorScheme.surface,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outline),
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
          itemBuilder:
              (context) => [
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
          child: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Enrolled Students (${schedule.enrolledStudents.length})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
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
                    children:
                        schedule.enrolledStudents.map((student) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 10,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  student.name,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
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
        builder:
            (context) => ChangeNotifierProvider.value(
              value: adminProvider,
              child: AddEditTrainingScreen(
                training: _currentTraining ?? widget.training,
              ),
            ),
      ),
    );
  }

  void _showScheduleFormDialog(BuildContext context) {
    _showScheduleDialog(context);
  }

  void _showEditScheduleDialog(
    BuildContext context,
    TrainingSchedule schedule,
  ) {
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
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.6,
              maxChildSize: 0.95,
              builder:
                  (context, scrollController) => Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
                                    await adminProvider
                                        .updateScheduleInTraining(
                                          currentTraining.id,
                                          newSchedule,
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Schedule updated successfully',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    // Add new schedule
                                    await adminProvider.addScheduleToTraining(
                                      currentTraining.id,
                                      newSchedule,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Schedule added successfully',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }

                                  // Close the bottom sheet
                                  Navigator.of(context).pop();

                                  // Refresh the training data from the provider
                                  await adminProvider.loadTrainings();

                                  // Update the local current training reference
                                  final updatedTraining = adminProvider
                                      .trainings
                                      .firstWhere(
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
        builder:
            (dialogContext) => AlertDialog(
              title: const Text('Delete Schedule'),
              content: Text(
                'Are you sure you want to delete this schedule?\n\n'
                'This will permanently delete:\n'
                '• Schedule: ${_formatDate(schedule.startDate)} - ${_formatDate(schedule.endDate)}\n'
                '• All student enrollments (${schedule.enrolledStudents.length} students)\n'
                '• All schedule materials and notes\n\n'
                'This action cannot be undone.',
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      // Show loading state
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Deleting schedule...'),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      // Delete the schedule using the admin provider from the parent context
                      final currentTraining = adminProvider.trainings
                          .firstWhere(
                            (t) => t.id == widget.training.id,
                            orElse: () => _currentTraining ?? widget.training,
                          );

                      await adminProvider.deleteScheduleFromTraining(
                        currentTraining.id,
                        schedule.id,
                      );

                      // Close the modal
                      Navigator.of(dialogContext).pop();

                      // Force a rebuild by updating the local state immediately
                      setState(() {
                        // Remove the schedule from local state as well
                        if (_currentTraining != null) {
                          _currentTraining!.schedules.removeWhere(
                            (s) => s.id == schedule.id,
                          );
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
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Delete Training'),
            content: Text(
              'Are you sure you want to delete "${_currentTraining?.title ?? widget.training.title}"?\n\n'
              'This will permanently delete:\n'
              '• All course schedules (${_currentTraining?.schedules.length ?? widget.training.schedules.length})\n'
              '• All student enrollments\n'
              '• All course materials and notes\n\n'
              'This action cannot be undone.',
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
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
                    final remainingTraining = adminProvider.trainings.any(
                      (t) => t.id == currentTraining.id,
                    );
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
        builder:
            (context) => UploadNoteScreen(
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
        builder:
            (context) => InstructorChatScreen(
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

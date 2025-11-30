import 'package:flutter/material.dart';
import 'package:learn_work/models/traning.dart';
import 'package:learn_work/widgets/upload_note_dialog.dart';

class UploadNoteScreen extends StatelessWidget {
  final String trainingId;
  final Training training;

  const UploadNoteScreen({
    super.key,
    required this.trainingId,
    required this.training,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Upload Notes',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
            foregroundColor: theme.colorScheme.onSurfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
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
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.upload_file,
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
                              'Upload Notes',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Choose a schedule and add course materials for students',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Schedules List
            if (training.schedules.isEmpty)
              _buildEmptySchedulesState(theme)
            else
              ...training.schedules.map(
                (schedule) => _buildScheduleCard(context, schedule, theme),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySchedulesState(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
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
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.schedule_outlined,
                size: 32,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No Schedules Available',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please create a schedule first before\nuploading notes',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    TrainingSchedule schedule,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        childrenPadding: EdgeInsets.zero,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.calendar_today,
                color: theme.colorScheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_formatDate(schedule.startDate)} - ${_formatDate(schedule.endDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        schedule.time.format(context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.people,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${schedule.enrolledStudents.length}/${schedule.capacity} students',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.note, size: 14, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Notes (${schedule.notes.length})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (schedule.notes.isEmpty)
                  _buildEmptyNotesState(theme)
                else
                  ...schedule.notes.map(
                    (note) => _buildNoteItem(context, note, theme),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
        onPressed:
                        () => _showUploadNoteDialog(
                          context,
                          trainingId,
                          schedule.id,
                        ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, size: 16),
                        SizedBox(width: 8),
                        Text('Upload Note'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(BuildContext context, Note note, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(Icons.description, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${note.fileType.toUpperCase()} • ${_formatDate(note.uploadedAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteNote(context, note.id, theme),
            icon: Icon(
              Icons.delete_outline,
              size: 16,
              color: theme.colorScheme.error,
            ),
            tooltip: 'Delete Note',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNotesState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.note_outlined,
              size: 24,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            Text(
              'No notes uploaded yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Upload your first note to get started',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showUploadNoteDialog(
    BuildContext context,
    String trainingId,
    String scheduleId,
  ) {
    showDialog(
      context: context,
      builder:
          (context) =>
              UploadNoteDialog(trainingId: trainingId, scheduleId: scheduleId),
    );
  }

  void _deleteNote(BuildContext context, String noteId, ThemeData theme) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Note',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to delete this note? This action cannot be undone.',
              style: theme.textTheme.bodySmall,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implement note deletion
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Note deleted successfully'),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }
}

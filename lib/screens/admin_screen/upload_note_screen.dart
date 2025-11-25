import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
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
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        title: Text(
          'Upload Notes',
          style: theme.typography.lg.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: theme.colors.foreground,
          ),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          style: IconButton.styleFrom(
            backgroundColor: theme.colors.muted,
            foregroundColor: theme.colors.mutedForeground,
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
              color: theme.colors.background,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.upload_file,
                          color: theme.colors.primary,
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
                              style: theme.typography.lg.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Choose a schedule and add course materials for students',
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

  Widget _buildEmptySchedulesState(FThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colors.border.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colors.muted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.schedule_outlined,
                size: 32,
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No Schedules Available',
              style: theme.typography.lg.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colors.foreground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please create a schedule first before\nuploading notes',
              textAlign: TextAlign.center,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
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
    FThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.colors.foreground.withValues(alpha: 0.04),
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
                color: theme.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.calendar_today,
                color: theme.colors.primary,
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
                    style: theme.typography.sm.copyWith(
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
                        color: theme.colors.mutedForeground,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        schedule.time.format(context),
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.people,
                        size: 12,
                        color: theme.colors.mutedForeground,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${schedule.enrolledStudents.length}/${schedule.capacity} students',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
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
                    Icon(Icons.note, size: 14, color: theme.colors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Notes (${schedule.notes.length})',
                      style: theme.typography.sm.copyWith(
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
                  child: FButton(
                    onPress:
                        () => _showUploadNoteDialog(
                          context,
                          trainingId,
                          schedule.id,
                        ),
                    style: FButtonStyle.primary,
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

  Widget _buildNoteItem(BuildContext context, Note note, FThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colors.muted,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.colors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.description, size: 16, color: theme.colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${note.fileType.toUpperCase()} • ${_formatDate(note.uploadedAt)}',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
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
              color: theme.colors.destructive,
            ),
            tooltip: 'Delete Note',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNotesState(FThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colors.muted,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.colors.border),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.note_outlined,
              size: 24,
              color: theme.colors.mutedForeground,
            ),
            const SizedBox(height: 6),
            Text(
              'No notes uploaded yet',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Upload your first note to get started',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
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

  void _deleteNote(BuildContext context, String noteId, FThemeData theme) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Note',
              style: theme.typography.lg.copyWith(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to delete this note? This action cannot be undone.',
              style: theme.typography.sm,
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
                      backgroundColor: theme.colors.primary,
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: theme.colors.destructive,
                ),
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }
}

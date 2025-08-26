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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Upload Notes',
          style: TextStyle(
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                         // Header Section
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
                           color: Colors.blue.withOpacity(0.1),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: const Icon(
                           Icons.upload_file,
                           color: Colors.blue,
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
                               style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                 fontWeight: FontWeight.bold,
                                 color: Colors.blue,
                               ),
                             ),
                             const SizedBox(height: 2),
                             Text(
                               'Choose a schedule and add course materials for students',
                               style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                 color: Colors.grey[600],
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
              _buildEmptySchedulesState()
            else
              ...training.schedules.map((schedule) => _buildScheduleCard(context, schedule)),

                         const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

     Widget _buildEmptySchedulesState() {
     return Container(
       margin: const EdgeInsets.all(12),
       padding: const EdgeInsets.all(24),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(8),
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
                 borderRadius: BorderRadius.circular(8),
               ),
               child: Icon(
                 Icons.schedule_outlined,
                 size: 32,
                 color: Colors.grey[400],
               ),
             ),
             const SizedBox(height: 12),
             Text(
               'No Schedules Available',
               style: TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.bold,
                 color: Colors.grey[600],
               ),
             ),
             const SizedBox(height: 6),
             Text(
               'Please create a schedule first before\nuploading notes',
               textAlign: TextAlign.center,
               style: TextStyle(
                 color: Colors.grey[500],
                 fontSize: 12,
               ),
             ),
           ],
         ),
       ),
     );
   }

     Widget _buildScheduleCard(BuildContext context, TrainingSchedule schedule) {
     return Container(
       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(8),
         ),
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
                 color: Colors.blue.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(6),
               ),
               child: const Icon(
                 Icons.calendar_today,
                 color: Colors.blue,
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
                     style: const TextStyle(
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
                         color: Colors.grey[600],
                       ),
                       const SizedBox(width: 3),
                       Text(
                         schedule.time.format(context),
                         style: TextStyle(
                           color: Colors.grey[600],
                           fontSize: 12,
                         ),
                       ),
                       const SizedBox(width: 12),
                       Icon(
                         Icons.people,
                         size: 12,
                         color: Colors.grey[600],
                       ),
                       const SizedBox(width: 3),
                       Text(
                         '${schedule.enrolledStudents.length}/${schedule.capacity} students',
                         style: TextStyle(
                           color: Colors.grey[600],
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
                     Icon(
                       Icons.note,
                       size: 14,
                       color: Colors.blue,
                     ),
                     const SizedBox(width: 6),
                     Text(
                       'Notes (${schedule.notes.length})',
                       style: const TextStyle(
                         fontWeight: FontWeight.w600,
                         fontSize: 13,
                       ),
                     ),
                   ],
                 ),
                 const SizedBox(height: 8),
                 if (schedule.notes.isEmpty)
                   _buildEmptyNotesState()
                 else
                   ...schedule.notes.map((note) => _buildNoteItem(context, note)),
                 const SizedBox(height: 12),
                 SizedBox(
                   width: double.infinity,
                   child: ElevatedButton.icon(
                     onPressed: () => _showUploadNoteDialog(context, trainingId, schedule.id),
                     icon: const Icon(Icons.upload_file, size: 16),
                     label: const Text('Upload Note'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.blue,
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(6),
                       ),
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

     Widget _buildNoteItem(BuildContext context, Note note) {
     return Container(
       margin: const EdgeInsets.only(bottom: 6),
       padding: const EdgeInsets.all(10),
       decoration: BoxDecoration(
         color: Colors.grey[50],
         borderRadius: BorderRadius.circular(6),
         border: Border.all(color: Colors.grey[300]!),
       ),
       child: Row(
         children: [
           Icon(
             Icons.description,
             size: 16,
             color: Colors.blue,
           ),
           const SizedBox(width: 8),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   note.title,
                   style: const TextStyle(
                     fontWeight: FontWeight.w600,
                     fontSize: 13,
                   ),
                 ),
                 const SizedBox(height: 2),
                 Text(
                   '${note.fileType.toUpperCase()} • ${_formatDate(note.uploadedAt)}',
                   style: TextStyle(
                     color: Colors.grey[600],
                     fontSize: 11,
                   ),
                 ),
               ],
             ),
           ),
           IconButton(
             onPressed: () => _deleteNote(context, note.id),
             icon: const Icon(Icons.delete_outline, size: 16),
             color: Colors.red,
             tooltip: 'Delete Note',
             padding: EdgeInsets.zero,
             constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
           ),
         ],
       ),
     );
   }

     Widget _buildEmptyNotesState() {
     return Container(
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(
         color: Colors.grey[50],
         borderRadius: BorderRadius.circular(6),
         border: Border.all(color: Colors.grey[300]!),
       ),
       child: Center(
         child: Column(
           children: [
             Icon(
               Icons.note_outlined,
               size: 24,
               color: Colors.grey[400],
             ),
             const SizedBox(height: 6),
             Text(
               'No notes uploaded yet',
               style: TextStyle(
                 color: Colors.grey[600],
                 fontSize: 12,
                 fontWeight: FontWeight.w500,
               ),
             ),
             const SizedBox(height: 2),
             Text(
               'Upload your first note to get started',
               style: TextStyle(
                 color: Colors.grey[500],
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

  void _showUploadNoteDialog(BuildContext context, String trainingId, String scheduleId) {
    showDialog(
      context: context,
      builder: (context) => UploadNoteDialog(
        trainingId: trainingId,
        scheduleId: scheduleId,
      ),
    );
  }

  void _deleteNote(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement note deletion
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note deleted successfully'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

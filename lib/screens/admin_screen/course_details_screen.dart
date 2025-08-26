import 'package:flutter/material.dart';
import 'package:learn_work/screens/admin_screen/instructor_chat_screen.dart';
import 'package:provider/provider.dart';
import 'package:forui/forui.dart';
import 'package:learn_work/providers/admin_provider.dart';
import 'package:learn_work/models/traning.dart';
import 'package:learn_work/screens/admin_screen/add_edit_training_screen.dart';
import 'package:learn_work/widgets/schedule_form_dialog.dart';
import 'package:learn_work/widgets/upload_note_dialog.dart';
import 'package:learn_work/screens/admin_screen/upload_note_screen.dart';


class CourseDetailsScreen extends StatelessWidget {
  final Training training;

  const CourseDetailsScreen({super.key, required this.training});

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _deleteTraining(context),
            icon: const Icon(Icons.delete_outline, size: 20),
            tooltip: 'Delete Course',
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              foregroundColor: Colors.red,
            ),
          ),
          const SizedBox(width: 16),
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
               color: Colors.white,
               padding: const EdgeInsets.all(12),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       Icon(
                         Icons.flash_on,
                         color: Theme.of(context).colorScheme.secondary,
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
                          icon: Icons.upload_file,
                          title: 'Upload Notes',
                          subtitle: 'Add course materials',
                          color: Colors.blue,
                          onTap: () => _showUploadNoteScreen(context, training.id),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.schedule,
                          title: 'Add Schedule',
                          subtitle: 'Create new session',
                          color: Theme.of(context).colorScheme.primary,
                          onTap: () => _showScheduleFormDialog(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.chat_bubble_outline,
                          title: 'Instructor Chat',
                          subtitle: 'Chat with students',
                          color: Colors.orange,
                          onTap: () => _showInstructorChat(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(), // Empty space for balance
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(), // Empty space for balance
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
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          if (training.schedules.any((schedule) => schedule.notes.isNotEmpty)) ...[
                            Icon(Icons.note, size: 16, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              '${training.schedules.fold(0, (sum, schedule) => sum + schedule.notes.length)} notes',
                              style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditTrainingScreen(training: training),
      ),
    );
  }

  void _showScheduleFormDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.5,
        maxChildSize: 0.85,
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
              // Compact handle bar
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Compact header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[100]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.schedule_outlined,
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
                            'Add Schedule',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Create a new course session schedule',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[50],
                        foregroundColor: Colors.grey[700],
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ],
                ),
              ),
              // Compact content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: ScheduleFormDialog(trainingId: training.id),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditScheduleDialog(BuildContext context, TrainingSchedule schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.5,
        maxChildSize: 0.85,
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
              // Compact handle bar
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Compact header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[100]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
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
                            'Edit Schedule',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Modify schedule details',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[50],
                        foregroundColor: Colors.grey[700],
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ],
                ),
              ),
              // Compact content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: ScheduleFormDialog(
                    trainingId: training.id,
                    schedule: schedule,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteSchedule(BuildContext context, TrainingSchedule schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.6,
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
              // Compact handle bar
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Compact header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[100]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delete Schedule',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'This action cannot be undone',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[50],
                        foregroundColor: Colors.grey[700],
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ],
                ),
              ),
              // Content - Made scrollable to prevent overflow
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Are you sure you want to delete this schedule?',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This will permanently delete:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDeleteWarningItem(
                        icon: Icons.calendar_today,
                        text: 'Schedule: ${_formatDate(schedule.startDate)} - ${_formatDate(schedule.endDate)}',
                      ),
                      const SizedBox(height: 8),
                      _buildDeleteWarningItem(
                        icon: Icons.people,
                        text: 'All student enrollments (${schedule.enrolledStudents.length} students)',
                      ),
                      const SizedBox(height: 8),
                      _buildDeleteWarningItem(
                        icon: Icons.note,
                        text: 'All schedule materials and notes',
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<AdminProvider>().deleteScheduleFromTraining(training.id, schedule.id);
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Schedule deleted successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Delete Schedule',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  void _deleteTraining(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.7,
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
              // Compact handle bar
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Compact header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[100]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delete Training',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'This action cannot be undone',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[50],
                        foregroundColor: Colors.grey[700],
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ],
                ),
              ),
              // Content - Made scrollable to prevent overflow
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Are you sure you want to delete "${training.title}"?',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This will permanently delete:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDeleteWarningItem(
                        icon: Icons.schedule,
                        text: 'All course schedules (${training.schedules.length})',
                      ),
                      const SizedBox(height: 8),
                      _buildDeleteWarningItem(
                        icon: Icons.people,
                        text: 'All student enrollments',
                      ),
                      const SizedBox(height: 8),
                      _buildDeleteWarningItem(
                        icon: Icons.note,
                        text: 'All course materials and notes',
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<AdminProvider>().deleteTraining(training.id);
                                Navigator.of(context).pop();
                                Navigator.of(context).pop(); // Go back to trainings list
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Training deleted successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Delete Training',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildDeleteWarningItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.red[400],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 6),
        Text(
          '$title ($count)',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }




  void _showUploadNoteScreen(BuildContext context, String trainingId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadNoteScreen(
          trainingId: trainingId,
          training: training,
        ),
      ),
    );
  }

  void _showScheduleSelectionDialog(BuildContext context, String trainingId) {
    if (training.schedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No schedules available. Please create a schedule first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Container(
          padding: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.note_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Select Schedule for Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: training.schedules.map((schedule) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    '${_formatDate(schedule.startDate)} - ${_formatDate(schedule.endDate)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${schedule.time.format(context)} | ${schedule.enrolledStudents.length}/${schedule.capacity} students',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    // Use a small delay to ensure the dialog is fully closed before showing the next screen
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _showUploadNoteScreen(context, trainingId);
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
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

  void _showInstructorChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstructorChatScreen(
          courseId: training.id,
          courseTitle: training.title,
          studentId: '',
          studentName: '',
          studentEmail: '',
        ),
      ),
    );
  }
}

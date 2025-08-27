import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_work/providers/admin_provider.dart';
import 'package:learn_work/models/traning.dart';

class AddEditTrainingScreen extends StatefulWidget {
  final Training? training; // null for add, non-null for edit

  const AddEditTrainingScreen({super.key, this.training});

  @override
  State<AddEditTrainingScreen> createState() => _AddEditTrainingScreenState();
}

class _AddEditTrainingScreenState extends State<AddEditTrainingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  List<TrainingSchedule> _schedules = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.training != null) {
      // Edit mode - populate fields
      _titleController.text = widget.training!.title;
      _descriptionController.text = widget.training!.description;
      _priceController.text = widget.training!.price.toString();
      _schedules = List.from(widget.training!.schedules);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.training != null;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Compact header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  FButton(
                    onPress: () => Navigator.of(context).pop(),
                    style: FButtonStyle.outline,
                    child: Icon(
                      Icons.arrow_back,
                      size: 16.sp,
                      color: const Color(0xFF666666),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    isEditMode ? 'Edit Training' : 'Add New Training',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Section
                      _buildSectionHeader('Basic Information'),
                      SizedBox(height: 12.h),

                      // Title field
                      _buildTextField(
                        controller: _titleController,
                        label: 'Training Title',
                        hint: 'Enter training course title',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Description field
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Enter training description',
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Price field
                      _buildTextField(
                        controller: _priceController,
                        label: 'Price (₹)',
                        hint: '0.00',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Price is required';
                          }
                          final price = double.tryParse(value);
                          if (price == null || price < 0) {
                            return 'Please enter a valid price';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),

                      // Schedules Section
                      _buildSectionHeader('Training Schedules'),
                      SizedBox(height: 8.h),

                      if (_schedules.isEmpty)
                        _buildEmptySchedulesState()
                      else
                        ..._schedules.asMap().entries.map((entry) {
                          final index = entry.key;
                          final schedule = entry.value;
                          return _buildScheduleCard(index, schedule);
                        }).toList(),

                      SizedBox(height: 24.h),

                      // Add Schedule Button
                      Center(
                        child: FButton(
                          onPress: _addNewSchedule,
                          style: FButtonStyle.outline,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 16.sp,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Add Schedule',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 120.h,
                      ), // Increased space for FAB to avoid overlap
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: FButton(
          onPress: _isLoading ? null : _saveTraining,
          style: FButtonStyle.primary,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child:
                _isLoading
                    ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isEditMode ? Icons.save : Icons.add,
                          size: 16.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          isEditMode ? 'Update Training' : 'Create Training',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1A1A),
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 6.h),
        FTextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          hint: hint,
          label: null,
          description: null,
        ),
      ],
    );
  }

  Widget _buildEmptySchedulesState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.schedule_outlined, size: 32.sp, color: Colors.grey[400]),
          SizedBox(height: 8.h),
          Text(
            'No schedules added yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Add at least one schedule for students to enroll',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 11.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(int index, TrainingSchedule schedule) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Schedule ${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              FButton(
                onPress: () => _editSchedule(index),
                style: FButtonStyle.outline,
                child: Icon(
                  Icons.edit,
                  size: 14.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: 6.w),
              FButton(
                onPress: () => _showDeleteScheduleDialog(index),
                style: FButtonStyle.outline,
                child: Icon(Icons.delete, size: 14.sp, color: Colors.red[400]),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildScheduleInfo(
                  Icons.calendar_today,
                  'Start: ${_formatDate(schedule.startDate)}',
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildScheduleInfo(
                  Icons.access_time,
                  'Time: ${_formatTime(schedule.time)}',
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: _buildScheduleInfo(
                  Icons.people,
                  'Capacity: ${schedule.capacity}',
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildScheduleInfo(
                  Icons.school,
                  'Enrolled: ${schedule.enrolledStudents.length}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: Colors.grey[600]),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _addNewSchedule() {
    _showScheduleDialog();
  }

  void _editSchedule(int index) {
    final schedule = _schedules[index];

    // Show confirmation that we're editing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Editing schedule: ${_formatDate(schedule.startDate)} - ${_formatDate(schedule.endDate)}',
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );

    _showScheduleDialog(schedule: schedule, index: index);
  }


  void _showDeleteScheduleDialog(int index) {
    final schedule = _schedules[index];
    
    showDialog(
      context: context,
      builder: (dialogContext) => FDialog(
        title: const Text('Delete Schedule'),
        body: Text(
          'Are you sure you want to delete this schedule?\n\n'
          'This will permanently delete:\n'
          '• Schedule: ${_formatDate(schedule.startDate)} - ${_formatDate(schedule.endDate)}\n'
          '• Time: ${_formatTime(schedule.time)}\n'
          '• Capacity: ${schedule.capacity}\n'
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
                
                // Close the modal
                Navigator.of(dialogContext).pop();
                
                // If we're editing an existing training, delete from Firestore
                if (widget.training != null && 
                    widget.training!.id.isNotEmpty && 
                    widget.training!.id != 'null' && 
                    widget.training!.id.length > 5) { // Ensure ID is reasonable length
                  
                  final adminProvider = Provider.of<AdminProvider>(context, listen: false);
                  
                  try {
                    // Verify the training exists in the admin provider before deletion
                    final existingTrainingIndex = adminProvider.trainings.indexWhere(
                      (t) => t.id == widget.training!.id,
                    );
                    
                    if (existingTrainingIndex != -1) {
                      // Delete the schedule from the training in Firestore
                      await adminProvider.deleteScheduleFromTraining(widget.training!.id, schedule.id);
                      
                      // Also update the local training object to keep it in sync
                      widget.training!.schedules.removeWhere((s) => s.id == schedule.id);
                    } else {
                      // Still remove from local state
                      widget.training!.schedules.removeWhere((s) => s.id == schedule.id);
                    }
                  } catch (e) {
                    // Even if Firestore deletion fails, we should still remove from local state
                    // and show a warning to the user
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Schedule removed locally but failed to sync with server: $e'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
                
                // Remove the schedule from local state
                setState(() {
                  _schedules.removeAt(index);
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
  }

  void _showScheduleDialog({TrainingSchedule? schedule, int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (sheetContext, scrollController) => Container(
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
                      onSave: (newSchedule) {
                        setState(() {
                          if (index != null) {
                            _schedules[index] = newSchedule;
                            // Show success message for editing
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Schedule updated successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            _schedules.add(newSchedule);
                            // Show success message for adding
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Schedule added successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        });
                        Navigator.of(bottomSheetContext).pop();
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

  Future<void> _saveTraining() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_schedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add at least one schedule'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);

      final training = Training(
        id:
            widget.training?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        schedules: _schedules,
        createdAt: widget.training?.createdAt ?? DateTime.now(),
      );

      // Validate that we have the correct ID for editing
      if (widget.training != null && training.id != widget.training!.id) {
        throw Exception('Training ID mismatch during edit operation');
      }

      if (widget.training != null) {
        await adminProvider.updateTraining(training);
      } else {
        await adminProvider.addTraining(training);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.training != null
                  ? 'Training updated successfully!'
                  : 'Training created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// Schedule Dialog for adding/editing schedules
class ScheduleDialog extends StatefulWidget {
  final TrainingSchedule? schedule;
  final Function(TrainingSchedule) onSave;

  const ScheduleDialog({super.key, this.schedule, required this.onSave});

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  final _capacityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _startDate = widget.schedule!.startDate;
      _endDate = widget.schedule!.endDate;
      _time = widget.schedule!.time;
      _capacityController.text = widget.schedule!.capacity.toString();
    } else {
      _capacityController.text = '20';
    }
  }

  @override
  void dispose() {
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.schedule != null;

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  isEditMode ? 'Edit Schedule' : 'Add New Schedule',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Start Date
            _buildDateField(
              label: 'Start Date',
              value: _startDate,
              onChanged: (date) => setState(() => _startDate = date),
            ),
            SizedBox(height: 16.h),

            // End Date
            _buildDateField(
              label: 'End Date',
              value: _endDate,
              onChanged: (date) => setState(() => _endDate = date),
            ),
            SizedBox(height: 16.h),

            // Time
            _buildTimeField(),
            SizedBox(height: 16.h),

            // Capacity
            _buildTextField(
              controller: _capacityController,
              label: 'Capacity',
              hint: '20',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Capacity is required';
                }
                final capacity = int.tryParse(value);
                if (capacity == null || capacity <= 0) {
                  return 'Please enter a valid capacity';
                }
                return null;
              },
            ),

            SizedBox(height: 32.h),

            // Actions
            Row(
              children: [
                Expanded(
                  child: FButton(
                    onPress: () => Navigator.of(context).pop(),
                    style: FButtonStyle.outline,
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: FButton(
                    onPress: _saveSchedule,
                    style: FButtonStyle.primary,
                    child: Text(isEditMode ? 'Update' : 'Add'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h), // Increased bottom padding for keyboard safety
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required Function(DateTime) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.sp),
        ),
        SizedBox(height: 6.h),
        FDateField.calendar(
          controller: FDateFieldController(vsync: this, initialDate: value),
          start:
              widget.schedule != null ? DateTime(2020, 1, 1) : DateTime.now(),
          end: DateTime.now().add(const Duration(days: 365)),
          today: DateTime.now(),
          onChange: (date) {
            if (date != null) {
              onChanged(date);
            }
          },
          hint: 'Select date',
          clearable: true,
          label: null,
          description: null,
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.sp),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: SizedBox(
            height: 44.h, // Fixed height to prevent infinite constraints
            child: FTimePicker(
              controller: FTimePickerController(),
              onChange: (time) {
                // Convert FTime to TimeOfDay and schedule the state update
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(
                      () =>
                          _time = TimeOfDay(
                            hour: time.hour,
                            minute: time.minute,
                          ),
                    );
                  }
                });
                            },
              hour24: false,
              hourInterval: 1,
              minuteInterval: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.sp),
        ),
        SizedBox(height: 6.h),
        FTextField(
          controller: controller,
          keyboardType: keyboardType,
          hint: hint,
          label: null,
          description: null,
        ),
      ],
    );
  }

  void _saveSchedule() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional date validation
    final now = DateTime.now();
    final minDate = DateTime(2020, 1, 1);
    final maxDate = now.add(const Duration(days: 365));

    if (_startDate.isBefore(minDate) || _startDate.isAfter(maxDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Start date must be between 2020 and next year'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_endDate.isBefore(minDate) || _endDate.isAfter(maxDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('End date must be between 2020 and next year'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('End date cannot be before start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final schedule = TrainingSchedule(
      id:
          widget.schedule?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: _startDate,
      endDate: _endDate,
      time: _time,
      capacity: int.parse(_capacityController.text.trim()),
      enrolledStudents: widget.schedule?.enrolledStudents ?? [],
      notes: widget.schedule?.notes ?? [],
      messages: widget.schedule?.messages ?? [],
    );

    // Validate that we have the correct ID for editing
    if (widget.schedule != null && schedule.id != widget.schedule!.id) {
      throw Exception('Schedule ID mismatch during edit operation');
    }

    widget.onSave(schedule);
  }
}

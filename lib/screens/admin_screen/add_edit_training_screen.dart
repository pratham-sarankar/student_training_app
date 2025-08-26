import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_work/providers/admin_provider.dart';
import 'package:learn_work/models/traning.dart';

class AddEditTrainingScreen extends StatefulWidget {
  final Training? training; // null for add, non-null for edit
  
  const AddEditTrainingScreen({
    super.key,
    this.training,
  });

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

                      SizedBox(height: 16.h),
                      
                      // Add Schedule Button
                      Center(
                        child: FButton(
                          onPress: _addNewSchedule,
                          style: FButtonStyle.outline,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 60.h), // Space for FAB
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        child: FButton(
          onPress: _isLoading ? null : _saveTraining,
          style: FButtonStyle.primary,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: _isLoading
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
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 13.sp,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.red[300]!),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          ),
          style: TextStyle(fontSize: 13.sp),
        ),
      ],
    );
  }

  Widget _buildEmptySchedulesState() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 32.sp,
            color: Colors.grey[400],
          ),
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
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11.sp,
            ),
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
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Icon(
                    Icons.edit,
                    size: 14.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              FButton(
                onPress: () => _removeSchedule(index),
                style: FButtonStyle.outline,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Icon(
                    Icons.delete,
                    size: 14.sp,
                    color: Colors.red[400],
                  ),
                ),
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
        Icon(
          icon,
          size: 14.sp,
          color: Colors.grey[600],
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
            ),
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
    _showScheduleDialog(schedule: _schedules[index], index: index);
  }

  void _removeSchedule(int index) {
    setState(() {
      _schedules.removeAt(index);
    });
  }

  void _showScheduleDialog({TrainingSchedule? schedule, int? index}) {
    showDialog(
      context: context,
      builder: (context) => ScheduleDialog(
        schedule: schedule,
        onSave: (newSchedule) {
          setState(() {
            if (index != null) {
              _schedules[index] = newSchedule;
            } else {
              _schedules.add(newSchedule);
            }
          });
        },
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
        id: widget.training?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        schedules: _schedules,
        createdAt: widget.training?.createdAt ?? DateTime.now(),
      );

      if (widget.training != null) {
        adminProvider.updateTraining(training);
      } else {
        adminProvider.addTraining(training);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.training != null 
                  ? 'Training updated successfully!' 
                  : 'Training created successfully!'
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

  const ScheduleDialog({
    super.key,
    this.schedule,
    required this.onSave,
  });

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
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
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400.w),
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditMode ? 'Edit Schedule' : 'Add New Schedule',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),

              // Start Date
              _buildDateField(
                label: 'Start Date',
                value: _startDate,
                onChanged: (date) => setState(() => _startDate = date),
              ),
              SizedBox(height: 12.h),

              // End Date
              _buildDateField(
                label: 'End Date',
                value: _endDate,
                onChanged: (date) => setState(() => _endDate = date),
              ),
              SizedBox(height: 12.h),

              // Time
              _buildTimeField(),
              SizedBox(height: 12.h),

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

              SizedBox(height: 20.h),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FButton(
                    onPress: () => Navigator.of(context).pop(),
                    style: FButtonStyle.outline,
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 8.w),
                  FButton(
                    onPress: _saveSchedule,
                    style: FButtonStyle.primary,
                    child: Text(isEditMode ? 'Update' : 'Add'),
                  ),
                ],
              ),
            ],
          ),
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
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 6.h),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              onChanged(date);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16.sp,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 8.w),
                Text(
                  '${value.day}/${value.month}/${value.year}',
                  style: TextStyle(fontSize: 13.sp),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
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
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 6.h),
        InkWell(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _time,
            );
            if (time != null) {
              setState(() => _time = time);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16.sp,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 8.w),
                Text(
                  '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 13.sp),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[600],
                ),
              ],
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
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          ),
          style: TextStyle(fontSize: 13.sp),
        ),
      ],
    );
  }

  void _saveSchedule() {
    if (!_formKey.currentState!.validate()) {
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
      id: widget.schedule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: _startDate,
      endDate: _endDate,
      time: _time,
      capacity: int.parse(_capacityController.text.trim()),
      enrolledStudents: widget.schedule?.enrolledStudents ?? [],
      notes: widget.schedule?.notes ?? [],
      messages: widget.schedule?.messages ?? [],
    );

    widget.onSave(schedule);
    Navigator.of(context).pop();
  }
}

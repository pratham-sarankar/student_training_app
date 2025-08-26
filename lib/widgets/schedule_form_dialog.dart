import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_work/models/traning.dart';
import 'package:learn_work/providers/admin_provider.dart';

class ScheduleFormDialog extends StatefulWidget {
  final String trainingId;
  final TrainingSchedule? schedule; // Add optional schedule for editing

  const ScheduleFormDialog({
    super.key, 
    required this.trainingId,
    this.schedule, // Add this parameter
  });

  @override
  State<ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends State<ScheduleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _time;
  final _capacityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with existing schedule data if editing
    if (widget.schedule != null) {
      _startDate = widget.schedule!.startDate;
      _endDate = widget.schedule!.endDate;
      _time = widget.schedule!.time;
      _capacityController.text = widget.schedule!.capacity.toString();
    }
  }

  @override
  void dispose() {
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.schedule != null;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form fields with compact styling
          _buildDateField(
            context: context,
            label: 'Start Date',
            value: _startDate,
            onTap: () => _selectStartDate(context),
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 16),
          
          _buildDateField(
            context: context,
            label: 'End Date',
            value: _endDate,
            onTap: () => _selectEndDate(context),
            icon: Icons.calendar_today_outlined,
            isEnabled: _startDate != null,
          ),
          const SizedBox(height: 16),
          
          _buildTimeField(context),
          const SizedBox(height: 16),
          
          _buildCapacityField(context),
          
          const Spacer(),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                child: FilledButton(
                  onPressed: _saveSchedule,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(
                    isEditing ? 'Update Schedule' : 'Add Schedule',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    required IconData icon,
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isEnabled ? Colors.white : Colors.grey[50],
              border: Border.all(
                color: isEnabled ? Colors.grey[300]! : Colors.grey[200]!,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isEnabled ? Theme.of(context).colorScheme.primary : Colors.grey[400],
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value != null 
                      ? '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}'
                      : 'Select ${label.toLowerCase()}',
                    style: TextStyle(
                      color: value != null ? Colors.grey[800] : Colors.grey[500],
                      fontSize: 15,
                      fontWeight: value != null ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: isEnabled ? Colors.grey[600] : Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _selectTime(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _time != null 
                      ? _time!.format(context)
                      : 'Select time',
                    style: TextStyle(
                      color: _time != null ? Colors.grey[800] : Colors.grey[500],
                      fontSize: 15,
                      fontWeight: _time != null ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapacityField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Capacity',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _capacityController,
          decoration: InputDecoration(
            hintText: 'Enter maximum number of students',
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(12),
            prefixIcon: Icon(
              Icons.people_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
          ),
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter capacity';
            }
            final capacity = int.tryParse(value);
            if (capacity == null || capacity <= 0) {
              return 'Please enter a valid capacity';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        // Reset end date if it's before the new start date
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start date first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!,
      lastDate: _startDate!.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _time = time;
      });
    }
  }

  void _saveSchedule() {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null &&
        _time != null) {
      
      if (_endDate!.isBefore(_startDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End date cannot be before start date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final schedule = TrainingSchedule(
        id: widget.schedule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        startDate: _startDate!,
        endDate: _endDate!,
        time: _time!,
        capacity: int.parse(_capacityController.text.trim()),
        enrolledStudents: widget.schedule?.enrolledStudents ?? [],
        notes: widget.schedule?.notes ?? [],
        messages: widget.schedule?.messages ?? [],
      );

      if (widget.schedule != null) {
        // Update existing schedule
        context.read<AdminProvider>().updateScheduleInTraining(widget.trainingId, schedule);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule updated successfully')),
        );
      } else {
        // Add new schedule
        context.read<AdminProvider>().addScheduleToTraining(widget.trainingId, schedule);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule added successfully')),
        );
      }

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

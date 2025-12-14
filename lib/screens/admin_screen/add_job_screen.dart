import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forui/forui.dart';
import 'package:learn_work/models/job.dart';
import 'package:learn_work/providers/admin_provider.dart';
import 'package:intl/intl.dart';

class AddJobScreen extends StatefulWidget {
  final Job? job;

  const AddJobScreen({super.key, this.job});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _salaryController;
  late TextEditingController _typeController;
  late TextEditingController _categoryController;
  late TextEditingController _requirementsController;
  late TextEditingController _responsibilitiesController;
  bool _isActive = true;
  bool _isLoading = false;

  // State variables for requirements and responsibilities
  List<String> _requirements = [];
  List<String> _responsibilities = [];

  // Dropdown selection variables
  String? _selectedJobType;
  String? _selectedCategory;
  DateTime? _selectedDeadline;
  late TextEditingController _deadlineController;

  // Job type options
  final List<String> _jobTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Internship',
    'Freelance',
    'Temporary',
    'Remote',
    'Hybrid',
  ];

  // Job category options
  final List<String> _jobCategories = [
    'General',
    'Technology',
    'Marketing',
    'Sales',
    'Finance',
    'Healthcare',
    'Education',
    'Engineering',
    'Design',
    'Customer Service',
    'Human Resources',
    'Operations',
    'Research',
    'Legal',
    'Media',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.job?.title ?? '');
    _companyController = TextEditingController(text: widget.job?.company ?? '');
    _locationController = TextEditingController(
      text: widget.job?.location ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.job?.description ?? '',
    );
    _salaryController = TextEditingController(text: widget.job?.salary ?? '');
    _typeController = TextEditingController(
      text: widget.job?.type ?? 'Full-time',
    );
    _categoryController = TextEditingController(
      text: widget.job?.category ?? 'General',
    );

    // Initialize dropdown selections
    _selectedJobType = widget.job?.type ?? 'Full-time';
    _selectedCategory = widget.job?.category ?? 'General';
    _selectedDeadline = widget.job?.deadline;
    _deadlineController = TextEditingController(
      text:
          _selectedDeadline != null
              ? DateFormat('MMM d, yyyy').format(_selectedDeadline!)
              : '',
    );

    // Ensure selected values exist in dropdown options to avoid crashes
    if (_selectedJobType != null && !_jobTypes.contains(_selectedJobType)) {
      _jobTypes.add(_selectedJobType!);
    }
    if (_selectedCategory != null &&
        !_jobCategories.contains(_selectedCategory)) {
      _jobCategories.add(_selectedCategory!);
    }

    // Handle requirements and responsibilities initialization safely
    if (widget.job != null) {
      print('Initializing with existing job:');
      print('Job requirements: ${widget.job!.requirements}');
      print('Job responsibilities: ${widget.job!.responsibilities}');
      print('Requirements length: ${widget.job!.requirements.length}');
      print('Responsibilities length: ${widget.job!.responsibilities.length}');

      // Initialize state variables with existing data
      _requirements = List<String>.from(widget.job!.requirements);
      _responsibilities = List<String>.from(widget.job!.responsibilities);

      print('State requirements: $_requirements');
      print('State responsibilities: $_responsibilities');
    } else {
      print('Initializing for new job');
      _requirements = [];
      _responsibilities = [];
    }

    _requirementsController = TextEditingController();
    _responsibilitiesController = TextEditingController();
    _isActive = widget.job?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _typeController.dispose();
    _categoryController.dispose();
    _requirementsController.dispose();
    _responsibilitiesController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isEditing = widget.job != null;

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        elevation: 0,
        toolbarHeight: 48,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colors.foreground,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? 'Edit Job' : 'Add New Job',
          style: theme.typography.sm.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colors.foreground,
          ),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(
                Icons.delete,
                color: theme.colors.destructive,
                size: 18,
              ),
              onPressed: _showDeleteConfirmation,
              tooltip: 'Delete Job',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compact Header Section
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: theme.colors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.work,
                          color: theme.colors.primary,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing
                                  ? 'Edit Job Details'
                                  : 'Create New Job Posting',
                              style: theme.typography.sm.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colors.foreground,
                              ),
                            ),
                            Text(
                              isEditing
                                  ? 'Update the job information below'
                                  : 'Fill in the details to create a new job posting',
                              style: theme.typography.xs.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                            if (isEditing &&
                                widget.job?.type.isNotEmpty == true)
                              Text(
                                'Current Type: ${widget.job!.type}',
                                style: theme.typography.xs.copyWith(
                                  color: theme.colors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Job Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Job Title *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    prefixIcon: Icon(
                      Icons.work_outline,
                      color: theme.colors.primary,
                      size: 16,
                    ),
                    hintText: 'e.g., Senior Software Engineer',
                    filled: true,
                    fillColor: theme.colors.muted,
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a job title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Company and Location Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      return Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _companyController,
                              decoration: InputDecoration(
                                labelText: 'Company *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                prefixIcon: Icon(
                                  Icons.business,
                                  color: theme.colors.primary,
                                  size: 16,
                                ),
                                hintText: 'e.g., Tech Corp Inc.',
                                filled: true,
                                fillColor: theme.colors.muted,
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a company name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                labelText: 'Location *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: theme.colors.primary,
                                  size: 16,
                                ),
                                hintText: 'e.g., New York, NY',
                                filled: true,
                                fillColor: theme.colors.muted,
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a location';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          TextFormField(
                            controller: _companyController,
                            decoration: InputDecoration(
                              labelText: 'Company *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              prefixIcon: Icon(
                                Icons.business,
                                color: theme.colors.primary,
                                size: 16,
                              ),
                              hintText: 'e.g., Tech Corp Inc.',
                              filled: true,
                              fillColor: theme.colors.muted,
                              isDense: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a company name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: 'Location *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              prefixIcon: Icon(
                                Icons.location_on,
                                color: theme.colors.primary,
                                size: 16,
                              ),
                              hintText: 'e.g., New York, NY',
                              filled: true,
                              fillColor: theme.colors.muted,
                              isDense: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a location';
                              }
                              return null;
                            },
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Job Description *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    prefixIcon: Icon(
                      Icons.description,
                      color: theme.colors.primary,
                      size: 16,
                    ),
                    hintText:
                        'Describe the role, responsibilities, and requirements...',
                    filled: true,
                    fillColor: theme.colors.muted,
                    isDense: true,
                    alignLabelWithHint: false,
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a job description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Salary
                TextFormField(
                  controller: _salaryController,
                  decoration: InputDecoration(
                    labelText: 'Salary *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    prefixIcon: Icon(
                      Icons.currency_rupee,
                      color: theme.colors.primary,
                      size: 16,
                    ),
                    hintText: 'e.g., 50,000 - 80,000 annually',
                    filled: true,
                    fillColor: theme.colors.muted,
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter salary information';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Deadline
                TextFormField(
                  controller: _deadlineController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Job Deadline',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: theme.colors.primary,
                      size: 16,
                    ),
                    hintText: 'Select deadline date',
                    filled: true,
                    fillColor: theme.colors.muted,
                    isDense: true,
                    suffixIcon:
                        _selectedDeadline != null
                            ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                size: 16,
                                color: theme.colors.mutedForeground,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedDeadline = null;
                                  _deadlineController.clear();
                                });
                              },
                            )
                            : null,
                  ),
                  onTap: () async {
                    final now = DateTime.now();
                    // Ensure firstDate includes the current selection even if it's in the past
                    final firstDate =
                        (_selectedDeadline != null &&
                                _selectedDeadline!.isBefore(now))
                            ? _selectedDeadline!
                            : now;

                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate:
                          _selectedDeadline ??
                          now.add(const Duration(days: 30)),
                      firstDate: firstDate,
                      lastDate: now.add(const Duration(days: 365 * 2)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: theme.colors.primary,
                              onPrimary: theme.colors.primaryForeground,
                              surface: theme.colors.background,
                              onSurface: theme.colors.foreground,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      setState(() {
                        _selectedDeadline = pickedDate;
                        _deadlineController.text = DateFormat(
                          'MMM d, yyyy',
                        ).format(pickedDate);
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),

                // Job Type
                DropdownButtonFormField<String>(
                  value: _selectedJobType,
                  decoration: InputDecoration(
                    labelText: 'Job Type *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    prefixIcon: Icon(
                      Icons.work,
                      color: theme.colors.primary,
                      size: 16,
                    ),
                    hintText: 'Select job type',
                    filled: true,
                    fillColor: theme.colors.muted,
                    isDense: true,
                  ),
                  items:
                      _jobTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: TextStyle(color: theme.colors.foreground),
                          ),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedJobType = newValue;
                        _typeController.text = newValue;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a job type';
                    }
                    return null;
                  },
                  dropdownColor: theme.colors.background,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: theme.colors.primary,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colors.foreground,
                  ),
                ),
                const SizedBox(height: 8),

                // Category
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Job Category *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    prefixIcon: Icon(
                      Icons.category,
                      color: theme.colors.primary,
                      size: 16,
                    ),
                    hintText: 'Select job category',
                    filled: true,
                    fillColor: theme.colors.muted,
                    isDense: true,
                  ),
                  items:
                      _jobCategories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category,
                            style: TextStyle(color: theme.colors.foreground),
                          ),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                        _categoryController.text = newValue;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a job category';
                    }
                    return null;
                  },
                  dropdownColor: theme.colors.background,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: theme.colors.primary,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colors.foreground,
                  ),
                ),
                const SizedBox(height: 8),

                // Requirements
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colors.border),
                    borderRadius: BorderRadius.circular(8),
                    color: theme.colors.background,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.primary.withValues(alpha: 0.05),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: theme.colors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color: theme.colors.primary,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Requirements *',
                              style: theme.typography.sm.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colors.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display existing requirements
                            if (_requirements.isNotEmpty) ...[
                              ..._requirements.asMap().entries.map((entry) {
                                final index = entry.key;
                                final req = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 4,
                                        margin: const EdgeInsets.only(
                                          top: 8,
                                          right: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          req,
                                          style: theme.typography.sm.copyWith(
                                            height: 1.4,
                                            color: theme.colors.foreground,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _requirements.removeAt(index);
                                          });
                                        },
                                        child: Icon(
                                          Icons.remove_circle_outline,
                                          size: 16,
                                          color: theme.colors.destructive,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 12),
                            ],

                            // Input field for new requirements
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 38,
                                    child: TextFormField(
                                      controller: _requirementsController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter a new requirement...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          borderSide: BorderSide(
                                            color: theme.colors.border,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          borderSide: BorderSide(
                                            color: theme.colors.primary,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                        filled: true,
                                        fillColor: theme.colors.background,
                                        suffixIcon:
                                            _requirementsController
                                                    .text
                                                    .isNotEmpty
                                                ? IconButton(
                                                  icon: Icon(
                                                    Icons.clear,
                                                    size: 16,
                                                    color:
                                                        theme
                                                            .colors
                                                            .mutedForeground,
                                                  ),
                                                  onPressed:
                                                      () =>
                                                          _requirementsController
                                                              .clear(),
                                                  tooltip: 'Clear',
                                                )
                                                : null,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: theme.colors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      size: 18,
                                      color: theme.colors.primaryForeground,
                                    ),
                                    onPressed: () {
                                      if (_requirementsController.text
                                          .trim()
                                          .isNotEmpty) {
                                        setState(() {
                                          final newReq =
                                              _requirementsController.text
                                                  .trim();
                                          _requirements.add(newReq);
                                          _requirementsController.clear();
                                        });
                                      }
                                    },
                                    tooltip: 'Add requirement',
                                    padding: const EdgeInsets.all(8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Responsibilities
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colors.border),
                    borderRadius: BorderRadius.circular(8),
                    color: theme.colors.background,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.primary.withValues(alpha: 0.05),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: theme.colors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.task_alt,
                                color: theme.colors.primary,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Responsibilities *',
                              style: theme.typography.sm.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colors.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display existing responsibilities
                            if (_responsibilities.isNotEmpty) ...[
                              ..._responsibilities.asMap().entries.map((entry) {
                                final index = entry.key;
                                final resp = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 4,
                                        margin: const EdgeInsets.only(
                                          top: 8,
                                          right: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          resp,
                                          style: theme.typography.sm.copyWith(
                                            height: 1.4,
                                            color: theme.colors.foreground,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _responsibilities.removeAt(index);
                                          });
                                        },
                                        child: Icon(
                                          Icons.remove_circle_outline,
                                          size: 16,
                                          color: theme.colors.destructive,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 12),
                            ],

                            // Input field for new responsibilities
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 38,
                                    child: TextFormField(
                                      controller: _responsibilitiesController,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Enter a new responsibility...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          borderSide: BorderSide(
                                            color: theme.colors.border,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          borderSide: BorderSide(
                                            color: theme.colors.primary,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                        filled: true,
                                        fillColor: theme.colors.background,
                                        suffixIcon:
                                            _responsibilitiesController
                                                    .text
                                                    .isNotEmpty
                                                ? IconButton(
                                                  icon: Icon(
                                                    Icons.clear,
                                                    size: 16,
                                                    color:
                                                        theme
                                                            .colors
                                                            .mutedForeground,
                                                  ),
                                                  onPressed:
                                                      () =>
                                                          _responsibilitiesController
                                                              .clear(),
                                                  tooltip: 'Clear',
                                                )
                                                : null,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: theme.colors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      size: 18,
                                      color: theme.colors.primaryForeground,
                                    ),
                                    onPressed: () {
                                      if (_responsibilitiesController.text
                                          .trim()
                                          .isNotEmpty) {
                                        setState(() {
                                          final newResp =
                                              _responsibilitiesController.text
                                                  .trim();
                                          _responsibilities.add(newResp);
                                          _responsibilitiesController.clear();
                                        });
                                      }
                                    },
                                    tooltip: 'Add responsibility',
                                    padding: const EdgeInsets.all(8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Compact Active Status
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colors.primary.withValues(alpha: 0.02),
                    border: Border.all(
                      color: theme.colors.primary.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) {
                          final isExpired =
                              _selectedDeadline != null &&
                              _selectedDeadline!.isBefore(DateTime.now());
                          return Checkbox(
                            value: isExpired ? false : _isActive,
                            onChanged:
                                isExpired
                                    ? null
                                    : (value) {
                                      setState(() {
                                        _isActive = value ?? true;
                                      });
                                    },
                            activeColor: theme.colors.primary,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Job Status',
                              style: theme.typography.sm.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colors.foreground,
                              ),
                            ),
                            Builder(
                              builder: (context) {
                                final isExpired =
                                    _selectedDeadline != null &&
                                    _selectedDeadline!.isBefore(DateTime.now());
                                return Text(
                                  isExpired
                                      ? 'Inactive (Deadline Passed)'
                                      : (_isActive
                                          ? 'Active and visible to students'
                                          : 'Inactive and hidden from students'),
                                  style: theme.typography.xs.copyWith(
                                    color:
                                        isExpired
                                            ? theme.colors.destructive
                                            : theme.colors.mutedForeground,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Compact Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: BorderSide(
                            color: theme.colors.border,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.foreground,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isLoading ? null : _saveJob,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: theme.colors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child:
                            _isLoading
                                ? SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colors.primaryForeground,
                                    ),
                                  ),
                                )
                                : Text(
                                  isEditing ? 'Update Job' : 'Create Job',
                                  style: theme.typography.sm.copyWith(
                                    color: theme.colors.primaryForeground,
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
      ),
    );
  }

  void _saveJob() async {
    final theme = context.theme;
    print('_saveJob called - starting validation...');
    if (_formKey.currentState!.validate()) {
      print('Form validation passed!');
      setState(() {
        _isLoading = true;
      });

      try {
        print('Creating job object...');
        print('Existing job requirements: ${widget.job?.requirements}');
        print('Existing job responsibilities: ${widget.job?.responsibilities}');
        print(
          'Requirements controller text: "${_requirementsController.text}"',
        );
        print(
          'Responsibilities controller text: "${_responsibilitiesController.text}"',
        );

        // Use the state variables for requirements and responsibilities
        List<String> requirements = List<String>.from(_requirements);
        List<String> responsibilities = List<String>.from(_responsibilities);

        // Add any new text from the controllers if they're not empty
        if (_requirementsController.text.trim().isNotEmpty) {
          requirements.add(_requirementsController.text.trim());
        }

        if (_responsibilitiesController.text.trim().isNotEmpty) {
          responsibilities.add(_responsibilitiesController.text.trim());
        }

        print('Final requirements list: $requirements');
        print('Final responsibilities list: $responsibilities');

        // Ensure salary has rupee symbol
        String salary = _salaryController.text.trim();
        if (salary.isNotEmpty && !salary.startsWith('₹')) {
          salary = '₹$salary';
        }

        final isExpired =
            _selectedDeadline != null &&
            _selectedDeadline!.isBefore(DateTime.now());

        final job = Job(
          id:
              widget.job?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          company: _companyController.text.trim(),
          location: _locationController.text.trim(),
          type: _typeController.text.trim(),
          salary: salary,
          category: _categoryController.text.trim(),
          posted:
              widget.job?.posted ??
              'Just now', // Preserve original posted date when editing
          logo:
              widget.job?.logo ??
              'https://example.com/default-logo.png', // Preserve original logo when editing
          description: _descriptionController.text.trim(),
          requirements: requirements,
          responsibilities: responsibilities,
          createdAt: widget.job?.createdAt ?? DateTime.now(),
          isActive: isExpired ? false : _isActive,
          deadline: _selectedDeadline,
        );
        print('Job object created successfully with ID: ${job.id}');

        if (widget.job == null) {
          // Creating new job
          print('Creating new job...');
          await context.read<AdminProvider>().addJob(job);
          print('Job created successfully');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Job created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate success
          }
        } else {
          // Updating existing job
          print('Updating existing job with ID: ${widget.job!.id}');
          await context.read<AdminProvider>().updateJob(job);
          print('Job updated successfully');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Job updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate success
          }
        }
      } catch (e) {
        print('Error saving job: $e');
        print('Error stack trace: ${StackTrace.current}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: theme.colors.destructive,
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
    } else {
      print('Form validation failed');
    }
  }

  void _showDeleteConfirmation() {
    final theme = context.theme;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Job'),
            content: const Text(
              'Are you sure you want to delete this job? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteJob();
                },
                style: TextButton.styleFrom(
                  foregroundColor: theme.colors.destructive,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _deleteJob() async {
    final theme = context.theme;
    if (widget.job != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        context.read<AdminProvider>().deleteJob(widget.job!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job deleted successfully'),
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
              backgroundColor: theme.colors.destructive,
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
  }
}

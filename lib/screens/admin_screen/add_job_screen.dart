import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forui/forui.dart';
import 'package:learn_work/models/job.dart';
import 'package:learn_work/providers/admin_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

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
  late TextEditingController _eligibilityController;
  bool _isActive = true;
  bool _isLoading = false;

  // State variables for eligibility
  List<String> _eligibility = [];

  // Dropdown selection variables
  String? _selectedJobType;
  String? _selectedCategory;
  DateTime? _selectedDeadline;
  late TextEditingController _deadlineController;
  late TextEditingController _applyLinkController;

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
    _applyLinkController = TextEditingController(
      text: widget.job?.applyLink ?? '',
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

    // Handle eligibility initialization safely
    if (widget.job != null) {
      print('Initializing with existing job:');
      print('Job eligibility: ${widget.job!.eligibility}');
      print('Eligibility length: ${widget.job!.eligibility.length}');

      // Initialize state variables with existing data
      _eligibility = List<String>.from(widget.job!.eligibility);

      print('State eligibility: $_eligibility');
    } else {
      print('Initializing for new job');
      _eligibility = [];
    }

    _eligibilityController = TextEditingController();
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
    _eligibilityController.dispose();
    _deadlineController.dispose();
    _applyLinkController.dispose();
    super.dispose();
  }

  Future<void> _importCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final path = result.files.single.path;
        if (path != null) {
          final file = File(path);
          final csvString = await file.readAsString();
          // Use a custom converter to handle different EOL styles if needed
          final List<List<dynamic>> rows = const CsvToListConverter(
            eol: '\n',
          ).convert(csvString);

          // If rows is small (maybe 1 row), check if it's because of \r\n
          List<List<dynamic>> processedRows = rows;
          if (rows.length <= 1 && csvString.contains('\r\n')) {
            processedRows = const CsvToListConverter(
              eol: '\r\n',
            ).convert(csvString);
          }

          if (processedRows.isEmpty) return;

          // Check for header
          int startRow = 0;
          if (processedRows.isNotEmpty &&
              processedRows[0].isNotEmpty &&
              processedRows[0][0].toString().toLowerCase().contains('title')) {
            startRow = 1;
          }

          List<Job> jobs = [];
          int duplicatesSkipped = 0;

          // Get existing jobs to check for duplicates
          final adminProvider = Provider.of<AdminProvider>(
            context,
            listen: false,
          );
          final existingJobs = adminProvider.jobs;

          for (int i = startRow; i < processedRows.length; i++) {
            final row = processedRows[i];
            // Expected columns: Title, Company, Location, Description, Salary, Apply Link, Deadline, Job Type, Job Category, Eligibility, Job Status

            if (row.length < 3) continue; // Skip incomplete provided rows

            String title = row[0].toString().trim();
            String company = row[1].toString().trim();
            String location = row[2].toString().trim();

            // Check if job already exists (case-insensitive title and company check)
            bool isDuplicate =
                existingJobs.any(
                  (job) =>
                      job.title.toLowerCase() == title.toLowerCase() &&
                      job.company.toLowerCase() == company.toLowerCase(),
                ) ||
                jobs.any(
                  (job) =>
                      job.title.toLowerCase() == title.toLowerCase() &&
                      job.company.toLowerCase() == company.toLowerCase(),
                );

            if (isDuplicate) {
              duplicatesSkipped++;
              continue;
            }

            String descriptionString =
                row.length > 3 ? row[3].toString() : 'No description provided.';
            String salary = row.length > 4 ? row[4].toString() : '';
            String applyLink = row.length > 5 ? row[5].toString() : '';
            String deadlineString = row.length > 6 ? row[6].toString() : '';
            String type = row.length > 7 ? row[7].toString() : 'Full-time';
            String category = row.length > 8 ? row[8].toString() : 'General';
            String eligibilityString = row.length > 9 ? row[9].toString() : '';
            String statusString =
                row.length > 10 ? row[10].toString() : 'Active';

            List<String> eligibilityList =
                eligibilityString.isNotEmpty
                    ? eligibilityString.split(',').map((e) => e.trim()).toList()
                    : [];

            DateTime? deadline;
            if (deadlineString.isNotEmpty) {
              try {
                deadline = DateFormat('dd-MM-yyyy').parse(deadlineString);
              } catch (e) {
                print('Error parsing date: $deadlineString');
              }
            }

            jobs.add(
              Job(
                id: '', // generated by provider
                title: title,
                company: company,
                location: location,
                type: type,
                salary: salary,
                category: category,
                posted: DateFormat('MMM d, yyyy').format(DateTime.now()),
                logo: '',
                description: descriptionString,
                eligibility: eligibilityList,
                createdAt: DateTime.now(),
                isActive: statusString.toLowerCase() == 'active',
                deadline: deadline,
                applyLink: applyLink,
              ),
            );
          }

          if (jobs.isNotEmpty && mounted) {
            await adminProvider.addJobs(jobs);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Successfully imported ${jobs.length} jobs. Skipped $duplicatesSkipped duplicates.',
                ),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pop(context);
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No valid jobs found in CSV')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            )
          else
            IconButton(
              icon: Icon(Icons.upload_file, color: theme.colors.primary),
              onPressed: _importCSV,
              tooltip: 'Import from CSV',
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
                // Company and Location Row
                Builder(
                  builder: (context) {
                    final isWide = MediaQuery.of(context).size.width > 600;
                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              key: const ValueKey('company'),
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
                              key: const ValueKey('location'),
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
                            key: const ValueKey('company'),
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
                            key: const ValueKey('location'),
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
                    labelText: 'Salary',
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
                    hintText: 'e.g., 50,000 - 80,000 annually (optional)',
                    filled: true,
                    fillColor: theme.colors.muted,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),

                // Apply Link
                TextFormField(
                  controller: _applyLinkController,
                  decoration: InputDecoration(
                    labelText: 'Apply Link',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    prefixIcon: Icon(
                      Icons.link,
                      color: theme.colors.primary,
                      size: 16,
                    ),
                    hintText: 'e.g., https://example.com/apply',
                    filled: true,
                    fillColor: theme.colors.muted,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),

                // Deadline
                TextFormField(
                  controller: _deadlineController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Application Deadline',
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
                TextFormField(
                  controller: _typeController,
                  readOnly: true,
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
                    suffixIcon: Icon(
                      Icons.arrow_drop_down,
                      color: theme.colors.primary,
                    ),
                    hintText: 'Select job type',
                    filled: true,
                    fillColor: theme.colors.muted,
                    isDense: true,
                  ),
                  onTap: () {
                    _showSelectionSheet(
                      title: 'Select Job Type',
                      items: _jobTypes,
                      selectedItem: _selectedJobType,
                      onSelected: (value) {
                        setState(() {
                          _selectedJobType = value;
                          _typeController.text = value;
                        });
                      },
                    );
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a job type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Category
                TextFormField(
                  controller: _categoryController,
                  readOnly: true,
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
                    suffixIcon: Icon(
                      Icons.arrow_drop_down,
                      color: theme.colors.primary,
                    ),
                    hintText: 'Select job category',
                    filled: true,
                    fillColor: theme.colors.muted,
                    isDense: true,
                  ),
                  onTap: () {
                    _showSelectionSheet(
                      title: 'Select Job Category',
                      items: _jobCategories,
                      selectedItem: _selectedCategory,
                      onSelected: (value) {
                        setState(() {
                          _selectedCategory = value;
                          _categoryController.text = value;
                        });
                      },
                    );
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a job category';
                    }
                    return null;
                  },
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
                              'Eligibility',
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
                            // Display existing eligibility
                            if (_eligibility.isNotEmpty) ...[
                              ..._eligibility.asMap().entries.map((entry) {
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
                                            _eligibility.removeAt(index);
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

                            // Input field for new eligibility
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 38,
                                    child: TextFormField(
                                      controller: _eligibilityController,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Enter eligibility criteria...',
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
                                            _eligibilityController
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
                                                          _eligibilityController
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
                                      if (_eligibilityController.text
                                          .trim()
                                          .isNotEmpty) {
                                        setState(() {
                                          final newReq =
                                              _eligibilityController.text
                                                  .trim();
                                          _eligibility.add(newReq);
                                          _eligibilityController.clear();
                                        });
                                      }
                                    },
                                    tooltip: 'Add eligibility',
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
        print('Existing job eligibility: ${widget.job?.eligibility}');
        print('Eligibility controller text: "${_eligibilityController.text}"');

        // Use the state variables for eligibility
        List<String> requirements = List<String>.from(_eligibility);

        // Add any new text from the controller if it's not empty
        if (_eligibilityController.text.trim().isNotEmpty) {
          requirements.add(_eligibilityController.text.trim());
        }

        print('Final eligibility list: $requirements');

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
          eligibility: requirements,
          createdAt: widget.job?.createdAt ?? DateTime.now(),
          isActive: isExpired ? false : _isActive,
          deadline: _selectedDeadline,
          applyLink: _applyLinkController.text.trim(),
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

  void _showSelectionSheet({
    required String title,
    required List<String> items,
    required String? selectedItem,
    required Function(String) onSelected,
  }) {
    final theme = context.theme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: theme.colors.background,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colors.mutedForeground.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: theme.typography.lg.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colors.foreground,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              color: theme.colors.mutedForeground,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // List
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isSelected = item == selectedItem;

                            return InkWell(
                              onTap: () {
                                onSelected(item);
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? theme.colors.primary.withValues(
                                            alpha: 0.05,
                                          )
                                          : null,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: theme.colors.border.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                          color:
                                              isSelected
                                                  ? theme.colors.primary
                                                  : theme.colors.foreground,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check,
                                        color: theme.colors.primary,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
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

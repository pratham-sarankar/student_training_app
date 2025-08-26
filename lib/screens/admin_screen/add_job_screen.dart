import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forui/forui.dart';
import 'package:learn_work/models/job.dart';
import 'package:learn_work/providers/admin_provider.dart';

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
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.job?.title ?? '');
    _companyController = TextEditingController(text: widget.job?.company ?? '');
    _locationController = TextEditingController(text: widget.job?.location ?? '');
    _descriptionController = TextEditingController(text: widget.job?.description ?? '');
    _salaryController = TextEditingController(text: widget.job?.salary ?? '');
    _isActive = widget.job?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.job != null;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 48,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? 'Edit Job' : 'Add New Job',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
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
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.work,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'Edit Job Details' : 'Create New Job Posting',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              isEditing 
                                ? 'Update the job information below'
                                : 'Fill in the details to create a new job posting',
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
                const SizedBox(height: 12),

                // Job Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Job Title *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    prefixIcon: Icon(
                      Icons.work_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                    hintText: 'e.g., Senior Software Engineer',
                    filled: true,
                    fillColor: Colors.grey.shade50,
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
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                prefixIcon: Icon(
                                  Icons.business,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 16,
                                ),
                                hintText: 'e.g., Tech Corp Inc.',
                                filled: true,
                                fillColor: Colors.grey.shade50,
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
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 16,
                                ),
                                hintText: 'e.g., New York, NY',
                                filled: true,
                                fillColor: Colors.grey.shade50,
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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              prefixIcon: Icon(
                                Icons.business,
                                color: Theme.of(context).colorScheme.primary,
                                size: 16,
                              ),
                              hintText: 'e.g., Tech Corp Inc.',
                              filled: true,
                              fillColor: Colors.grey.shade50,
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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              prefixIcon: Icon(
                                Icons.location_on,
                                color: Theme.of(context).colorScheme.primary,
                                size: 16,
                              ),
                              hintText: 'e.g., New York, NY',
                              filled: true,
                              fillColor: Colors.grey.shade50,
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    prefixIcon: Icon(
                      Icons.description,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                    hintText: 'Describe the role, responsibilities, and requirements...',
                    filled: true,
                    fillColor: Colors.grey.shade50,
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: Theme.of(context).colorScheme.primary,
                      size: 16,
                    ),
                    hintText: 'e.g., \$50,000 - \$80,000 annually',
                    filled: true,
                    fillColor: Colors.grey.shade50,
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

                // Compact Active Status
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.02),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value ?? true;
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Job Status',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              _isActive 
                                ? 'Active and visible to students'
                                : 'Inactive and hidden from students',
                              style: TextStyle(
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
                            color: Theme.of(context).colorScheme.outline,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
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
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                isEditing ? 'Update Job' : 'Create Job',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
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
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final job = Job(
          id: widget.job?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          company: _companyController.text.trim(),
          location: _locationController.text.trim(),
          type: 'Full-time', // Default value, you might want to add a field for this
          salary: _salaryController.text.trim(),
          category: 'General', // Default value, you might want to add a field for this
          posted: 'Just now', // Default value
          logo: 'https://example.com/default-logo.png', // Default value, you might want to add a field for this
          description: _descriptionController.text.trim(),
          requirements: ['Experience required'], // Default value, you might want to add a field for this
          responsibilities: ['Job responsibilities'], // Default value, you might want to add a field for this
          createdAt: widget.job?.createdAt ?? DateTime.now(),
          isActive: _isActive,
        );

        if (widget.job == null) {
          context.read<AdminProvider>().addJob(job);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Job created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        } else {
          context.read<AdminProvider>().updateJob(job);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Job updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
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
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text('Are you sure you want to delete this job? This action cannot be undone.'),
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteJob() async {
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
  }
}

import 'package:flutter/material.dart';

class JobDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
        ),
        title: Text(
          'Job Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Logo and Basic Info
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onPrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.job['logo'],
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  widget.job['company'][0].toUpperCase(),
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.job['title'],
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.job['company'],
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Job Details Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          Icons.location_on_outlined,
                          'Location',
                          widget.job['location'],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDetailCard(
                          Icons.work_outline,
                          'Job Type',
                          widget.job['type'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard(
                          Icons.attach_money,
                          'Salary',
                          widget.job['salary'],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDetailCard(
                          Icons.category,
                          'Category',
                          widget.job['category'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildDetailCard(
                    Icons.access_time,
                    'Posted',
                    widget.job['posted'],
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 1, color: theme.colorScheme.outline),

            // Job Description Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDescriptionText(),
                  const SizedBox(height: 16),

                  Text(
                    'Requirements',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRequirementsList(),
                  const SizedBox(height: 16),

                  Text(
                    'Benefits',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBenefitsList(),
                ],
              ),
            ),

            // Apply Button
            Container(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: () => _showApplicationDialog(),
                  child: Text(
                    'Apply Now',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String label, String value) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionText() {
    final theme = Theme.of(context);

    return Text(
      'We are looking for a talented and experienced professional to join our team. '
      'This role involves working on exciting projects, collaborating with cross-functional teams, '
      'and contributing to the success of our organization. The ideal candidate will have strong '
      'technical skills, excellent communication abilities, and a passion for innovation.',
      style: TextStyle(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 13,
        height: 1.4,
      ),
    );
  }

  Widget _buildRequirementsList() {
    final theme = Theme.of(context);

    final requirements = [
      'Bachelor\'s degree in related field',
      '3+ years of relevant experience',
      'Strong problem-solving skills',
      'Excellent communication abilities',
      'Ability to work in a team environment',
      'Proficiency in required technologies',
    ];

    return Column(
      children:
          requirements
              .map(
                (req) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          req,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildBenefitsList() {
    final theme = Theme.of(context);

    final benefits = [
      'Competitive salary and benefits package',
      'Flexible working hours and remote options',
      'Professional development opportunities',
      'Health insurance and wellness programs',
      'Collaborative and inclusive work environment',
      'Career growth and advancement potential',
    ];

    return Column(
      children:
          benefits
              .map(
                (benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          benefit,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  void _showApplicationDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Apply for ${widget.job['title']}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            content: Text(
              'Are you sure you want to apply for this position? '
              'You will be redirected to the application form.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showApplicationForm();
                },
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showApplicationForm() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildApplicationForm(),
    );
  }

  Widget _buildApplicationForm() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Application Form',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Form fields would go here in a real app
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Application Submitted!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your application for ${widget.job['title']} has been submitted successfully. '
                  'We will review your application and get back to you soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to jobs list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Application submitted successfully!'),
                    backgroundColor: theme.colorScheme.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

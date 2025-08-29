import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class JobDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        backgroundColor: theme.colors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: theme.colors.foreground,
            size: 20,
          ),
        ),
        title: Text(
          'Job Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colors.foreground,
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
                          color: theme.colors.primaryForeground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            widget.job['logo'],
                            style: TextStyle(
                              color: theme.colors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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
                              style: theme.typography.lg.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colors.foreground,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.job['company'],
                              style: TextStyle(
                                color: theme.colors.mutedForeground,
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
            
            Divider(height: 1, thickness: 1, color: theme.colors.border),
            
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
                      color: theme.colors.foreground,
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
                      color: theme.colors.foreground,
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
                      color: theme.colors.foreground,
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
                child: FButton(
                  style: FButtonStyle.primary,
                  onPress: () => _showApplicationDialog(),
                  child: Text(
                    'Apply Now',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colors.primaryForeground,
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
    final theme = context.theme;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colors.mutedForeground.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colors.mutedForeground,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: theme.colors.mutedForeground,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: theme.colors.foreground,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionText() {
    final theme = context.theme;
    
    return Text(
      'We are looking for a talented and experienced professional to join our team. '
      'This role involves working on exciting projects, collaborating with cross-functional teams, '
      'and contributing to the success of our organization. The ideal candidate will have strong '
      'technical skills, excellent communication abilities, and a passion for innovation.',
      style: TextStyle(
        color: theme.colors.mutedForeground,
        fontSize: 13,
        height: 1.4,
      ),
    );
  }

  Widget _buildRequirementsList() {
    final theme = context.theme;
    
    final requirements = [
      'Bachelor\'s degree in related field',
      '3+ years of relevant experience',
      'Strong problem-solving skills',
      'Excellent communication abilities',
      'Ability to work in a team environment',
      'Proficiency in required technologies',
    ];

    return Column(
      children: requirements.map((req) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: theme.colors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                req,
                style: TextStyle(
                  color: theme.colors.mutedForeground,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildBenefitsList() {
    final theme = context.theme;
    
    final benefits = [
      'Competitive salary and benefits package',
      'Flexible working hours and remote options',
      'Professional development opportunities',
      'Health insurance and wellness programs',
      'Collaborative and inclusive work environment',
      'Career growth and advancement potential',
    ];

    return Column(
      children: benefits.map((benefit) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle,
              size: 14,
              color: theme.colors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                benefit,
                style: TextStyle(
                  color: theme.colors.mutedForeground,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  void _showApplicationDialog() {
    final theme = context.theme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Apply for ${widget.job['title']}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colors.foreground,
          ),
        ),
        content: Text(
          'Are you sure you want to apply for this position? '
          'You will be redirected to the application form.',
          style: TextStyle(
            fontSize: 13,
            color: theme.colors.mutedForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.colors.mutedForeground,
                fontSize: 13,
              ),
            ),
          ),
          FButton(
            style: FButtonStyle.primary,
            onPress: () {
              Navigator.pop(context);
              _showApplicationForm();
            },
            child: Text(
              'Continue',
              style: TextStyle(
                color: theme.colors.primaryForeground,
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
    final theme = context.theme;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildApplicationForm(),
    );
  }

  Widget _buildApplicationForm() {
    final theme = context.theme;
    
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
                  color: theme.colors.foreground,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, size: 20, color: theme.colors.mutedForeground),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Form fields would go here in a real app
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colors.mutedForeground.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 40,
                  color: theme.colors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Application Submitted!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your application for ${widget.job['title']} has been submitted successfully. '
                  'We will review your application and get back to you soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colors.mutedForeground,
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
            child: FButton(
              style: FButtonStyle.primary,
              onPress: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to jobs list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Application submitted successfully!'),
                    backgroundColor: theme.colors.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colors.primaryForeground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

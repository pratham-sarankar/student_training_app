import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_work/providers/admin_provider.dart';
import 'package:learn_work/models/job.dart';
import 'add_job_screen.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compact Header
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.work,
                            color: theme.colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Job Management',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Manage job postings and notifications',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 11,
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
                            child: FilledButton(
        onPressed: () => _navigateToAddJob(context),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.add, size: 14),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Add Job',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Compact Jobs Table
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // Store reference to AdminProvider before using it
                      final adminProvider = context.read<AdminProvider>();
                      await adminProvider.loadJobs();
                    },
                    child: _buildJobsTable(context, adminProvider),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobsTable(BuildContext context, AdminProvider adminProvider) {
    final theme = Theme.of(context);

    if (adminProvider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            const SizedBox(height: 10),
            Text(
              'Loading jobs...',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (adminProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Error loading jobs',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              adminProvider.errorMessage!,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
        onPressed: () {
                // Store reference to AdminProvider before using it
                final adminProvider = context.read<AdminProvider>();
                adminProvider.loadJobs();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (adminProvider.jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No jobs available',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add your first job to get started',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.hardEdge,
      child: DataTable(
        clipBehavior: Clip.hardEdge,
        columnSpacing: 12,
        horizontalMargin: 12,
        headingRowHeight: 32,
        columns: [
          DataColumn(
            label: Text(
              'Title',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Company',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Location',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Salary',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Posted',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Actions',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
        rows:
            adminProvider.jobs.map((job) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      job.company,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      job.location,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(
                      job.salary,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(
                    Text(job.posted, style: const TextStyle(fontSize: 12)),
                  ),
                  DataCell(
                    Center(
                      child: Text(
                        job.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color:
                              job.isActive
                                  ? Colors.green[800]
                                  : Colors.red[800],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 18),
                        tooltip: 'Actions',
                        color: theme.colorScheme.surface,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: theme.colorScheme.outline),
                        ),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            // Show brief loading indicator
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              theme.colorScheme.onPrimary,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Opening editor...'),
                                  ],
                                ),
                                duration: const Duration(seconds: 1),
                                backgroundColor: theme.colorScheme.primary,
                              ),
                            );
                            _navigateToAddJob(context, job: job);
                          } else if (value == 'delete') {
                            _deleteJob(context, job.id);
                          }
                        },
                        itemBuilder:
                            (context) => [
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: theme.colorScheme.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Edit',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: theme.colorScheme.error,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Delete',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  void _navigateToAddJob(BuildContext context, {Job? job}) async {
    // Get the AdminProvider instance from the current context
    final adminProvider = context.read<AdminProvider>();

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ChangeNotifierProvider.value(
              value: adminProvider,
              child: AddJobScreen(job: job),
            ),
      ),
    );

    // If we're returning from editing and there's a result, refresh the jobs
    if (result == true) {
      // Use the stored reference instead of context.read to avoid deactivated widget error
      await adminProvider.loadJobs();

      // Show success message - check if context is still mounted
      if (context.mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Job updated successfully!'),
            backgroundColor: theme.colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _deleteJob(BuildContext context, String jobId) {
    final theme = Theme.of(context);

    // Find the job to get its details for the confirmation
    final adminProvider = context.read<AdminProvider>();
    final job = adminProvider.jobs.firstWhere((j) => j.id == jobId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.4,
            maxChildSize: 0.7,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
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
                          color: theme.colorScheme.onSurfaceVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Compact header
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.colorScheme.outline,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onError,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: theme.colorScheme.error,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Delete Job',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'This action cannot be undone',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.close, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.1),
                                foregroundColor: theme.colorScheme.onSurfaceVariant,
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
                                'Are you sure you want to delete this job?',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Job details card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.work,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            job.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.onSurface,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.business,
                                          size: 14,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          job.company,
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurfaceVariant,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          job.location,
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurfaceVariant,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.attach_money,
                                          size: 14,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          job.salary,
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurfaceVariant,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'This will permanently delete:',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildDeleteWarningItem(
                                icon: Icons.work_outline,
                                text: 'Job posting and all associated data',
                              ),
                              const SizedBox(height: 8),
                              _buildDeleteWarningItem(
                                icon: Icons.notifications,
                                text: 'Job notifications and alerts',
                              ),
                              const SizedBox(height: 8),
                              _buildDeleteWarningItem(
                                icon: Icons.people,
                                text: 'Student applications and subscriptions',
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: theme.colorScheme.outline,
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Store reference to AdminProvider before using it
                                        final adminProvider =
                                            context.read<AdminProvider>();
                                        adminProvider.deleteJob(jobId);
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Job deleted successfully',
                                            ),
                                            backgroundColor:
                                                theme.colorScheme.primary,
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.error,
                                        foregroundColor:
                                            theme.colorScheme.onError,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'Delete Job',
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

  Widget _buildDeleteWarningItem({
    required IconData icon,
    required String text,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        return Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

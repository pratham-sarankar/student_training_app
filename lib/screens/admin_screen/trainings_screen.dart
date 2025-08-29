import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forui/forui.dart';
import 'package:learn_work/providers/admin_provider.dart';
import 'package:learn_work/models/traning.dart';
import 'package:learn_work/screens/admin_screen/add_edit_training_screen.dart';
import 'course_details_screen.dart';

class TrainingsScreen extends StatefulWidget {
  const TrainingsScreen({super.key});

  @override
  State<TrainingsScreen> createState() => _TrainingsScreenState();
}

class _TrainingsScreenState extends State<TrainingsScreen> {

  @override
  void initState() {
    super.initState();
    // Refresh data when the screen is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  void _refreshData() {
    final adminProvider = context.read<AdminProvider>();
    
    // Only refresh if we're not already loading
    if (!adminProvider.isLoading) {
      adminProvider.loadTrainings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        // Simple approach: Refresh data every time the screen is built
        // This ensures data is fresh when returning from other screens
        // The debounce mechanism prevents excessive API calls
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _refreshData();
        });
        
        return Scaffold(
          backgroundColor: theme.colors.background,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header - Made more compact
                    LayoutBuilder(
                      builder: (context, constraints) {
                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.school,
                                      color: theme.colors.primary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Training Courses',
                                            style: theme.typography.lg.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: theme.colors.foreground,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Manage training courses and schedules',
                                            style: theme.typography.sm.copyWith(
                                              color: theme.colors.mutedForeground,
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
                                      child: FButton(
                                        onPress: () => _navigateToAddEditTraining(context, adminProvider),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.add, size: 14),
                                            const SizedBox(width: 4),
                                            const Text('Add Training', style: TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Trainings List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await adminProvider.loadTrainings();
                        },
                        child: _buildTrainingsList(context, adminProvider),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrainingsList(BuildContext context, AdminProvider adminProvider) {
    final theme = context.theme;
    
    if (adminProvider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading trainings...',
              style: TextStyle(
                fontSize: 16,
                color: theme.colors.mutedForeground,
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
              color: theme.colors.destructive,
            ),
            const SizedBox(height: 12),
            Text(
              'Error loading trainings',
              style: TextStyle(
                fontSize: 16,
                color: theme.colors.destructive,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              adminProvider.errorMessage!,
              style: TextStyle(
                color: theme.colors.mutedForeground,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FButton(
              onPress: () {
                // Store reference to AdminProvider before using it
                final adminProvider = context.read<AdminProvider>();
                adminProvider.loadTrainings();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (adminProvider.trainings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colors.mutedForeground.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.school_outlined,
                size: 48,
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Training Courses Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first training course to start\nmanaging student enrollments',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colors.mutedForeground,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            FButton(
              onPress: () => _navigateToAddEditTraining(context, adminProvider),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add),
                  const SizedBox(width: 4),
                  const Text('Create First Course'),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: adminProvider.trainings.length,
      itemBuilder: (context, index) {
        final training = adminProvider.trainings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: theme.colors.background,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.colors.foreground.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _navigateToCourseDetails(context, training, adminProvider),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                training.title,
                                style: theme.typography.lg.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colors.foreground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                training.description,
                                style: TextStyle(
                                  color: theme.colors.mutedForeground,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '\$${training.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colors.primaryForeground,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${training.schedules.length} schedule${training.schedules.length != 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: theme.colors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: theme.colors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tap to view details and manage course',
                                style: TextStyle(
                                  color: theme.colors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToAddEditTraining(BuildContext context, AdminProvider adminProvider, {Training? training}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: adminProvider,
          child: AddEditTrainingScreen(training: training),
        ),
      ),
    );
  }

  void _navigateToCourseDetails(BuildContext context, Training training, AdminProvider adminProvider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: adminProvider,
          child: CourseDetailsScreen(training: training),
        ),
      ),
    );
  }
}

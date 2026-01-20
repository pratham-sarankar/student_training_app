import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_work/providers/admin_provider.dart';
import 'package:provider/provider.dart';
import 'jobs_screen.dart';
import 'trainings_screen.dart';
import 'students_screen.dart';
import 'admin_assessments_screen.dart';
import 'package:forui/forui.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return AnnotatedRegion(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: theme.colors.background,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Mobile header - compact
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.colors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.admin_panel_settings,
                                  color: theme.colors.primaryForeground,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Admin Panel',
                                  style: theme.typography.lg.copyWith(
                                    color: theme.colors.foreground,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Sign out button
                              IconButton(
                                onPressed: () async {
                                  // Show logout confirmation dialog using ForUI
                                  final shouldLogout = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => FDialog(
                                          title: const Text('Confirm Logout'),
                                          body: const Text(
                                            'Are you sure you want to logout?',
                                          ),
                                          actions: [
                                            FButton(
                                              style: FButtonStyle.outline,
                                              onPress:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            FButton(
                                              style: FButtonStyle.primary,
                                              onPress:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                              child: const Text('Logout'),
                                            ),
                                          ],
                                        ),
                                  );

                                  // If user confirms logout, proceed
                                  if (shouldLogout == true) {
                                    await adminProvider.signOutAdmin();
                                    // The AuthWrapper will automatically handle navigation
                                    // No need to manually navigate
                                  }
                                },
                                icon: Icon(
                                  Icons.logout,
                                  color: theme.colors.foreground,
                                  size: 20,
                                ),
                                tooltip: 'Sign Out',
                              ),
                            ],
                          ),
                        ),
                        // Mobile navigation tabs - scrollable
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              _buildMobileNavItem(
                                context,
                                icon: Icons.work,
                                title: 'Jobs',
                                index: 0,
                                isSelected: adminProvider.selectedIndex == 0,
                              ),
                              _buildMobileNavItem(
                                context,
                                icon: Icons.school,
                                title: 'Trainings',
                                index: 1,
                                isSelected: adminProvider.selectedIndex == 1,
                              ),
                              _buildMobileNavItem(
                                context,
                                icon: Icons.people,
                                title: 'Students',
                                index: 2,
                                isSelected: adminProvider.selectedIndex == 2,
                              ),
                              _buildMobileNavItem(
                                context,
                                icon: Icons.assignment,
                                title: 'Assessments',
                                index: 3,
                                isSelected: adminProvider.selectedIndex == 3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Main content - compact
                        Container(
                          height:
                              constraints.maxHeight -
                              100, // Reduced height for more compact layout
                          decoration: BoxDecoration(
                            color: theme.colors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _buildScreen(adminProvider.selectedIndex),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
    required bool isSelected,
  }) {
    final theme = context.theme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<AdminProvider>().setSelectedIndex(index);
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color:
                  isSelected ? theme.colors.primary : theme.colors.background,
              border: Border.all(
                color: isSelected ? theme.colors.primary : theme.colors.border,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color:
                      isSelected
                          ? theme.colors.primaryForeground
                          : theme.colors.foreground,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected
                            ? theme.colors.primaryForeground
                            : theme.colors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const JobsScreen();
      case 1:
        return const TrainingsScreen();
      case 2:
        return const StudentsScreen();
      case 3:
        return const AdminAssessmentsScreen();
      default:
        return const JobsScreen();
    }
  }
}

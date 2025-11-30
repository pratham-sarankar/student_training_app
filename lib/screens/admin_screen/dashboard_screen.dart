import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_work/providers/admin_provider.dart';
import 'package:provider/provider.dart';
import 'jobs_screen.dart';
import 'trainings_screen.dart';
import 'students_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return AnnotatedRegion(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: theme.colorScheme.surface,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Mobile header - compact
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.admin_panel_settings,
                                    color: theme.colorScheme.onPrimary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Admin Panel',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
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
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Logout'),
                                        content: const Text('Are you sure you want to logout?'),
                                        actions: [
                                          OutlinedButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          FilledButton(
                                            onPressed: () => Navigator.of(context).pop(true),
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
                                    color: theme.colorScheme.onSurface,
                                    size: 20,
                                  ),
                                  tooltip: 'Sign Out',
                                ),
                              ],
                            ),
                          ),
                          // Mobile navigation tabs - compact
                          Row(
                            children: [
                              Expanded(
                                child: _buildMobileNavItem(
                                  context,
                                  icon: Icons.work,
                                  title: 'Jobs',
                                  index: 0,
                                  isSelected: adminProvider.selectedIndex == 0,
                                ),
                              ),
                              Expanded(
                                child: _buildMobileNavItem(
                                  context,
                                  icon: Icons.school,
                                  title: 'Trainings',
                                  index: 1,
                                  isSelected: adminProvider.selectedIndex == 1,
                                ),
                              ),
                              Expanded(
                                child: _buildMobileNavItem(
                                  context,
                                  icon: Icons.people,
                                  title: 'Students',
                                  index: 2,
                                  isSelected: adminProvider.selectedIndex == 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Main content - compact
                          Container(
                            height: constraints.maxHeight - 100, // Reduced height for more compact layout
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
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
    final theme = Theme.of(context);
    
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
              border: Border.all(
                color: isSelected 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
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
                  size: 16,
                  color: isSelected 
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
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
      default:
        return const JobsScreen();
    }
  }
}

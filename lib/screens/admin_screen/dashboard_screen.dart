import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_work/providers/admin_provider.dart';
import 'package:provider/provider.dart';
import 'jobs_screen.dart';
import 'trainings_screen.dart';
import 'students_screen.dart';
import 'package:forui/forui.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return AnnotatedRegion(
          value: SystemUiOverlayStyle.dark,
          child: FScaffold(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Mobile header - compact
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.admin_panel_settings,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Admin Panel',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
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
                                      builder: (context) => FDialog(
                                        title: const Text('Confirm Logout'),
                                        body: const Text('Are you sure you want to logout?'),
                                        actions: [
                                          FButton(
                                            style: FButtonStyle.outline,
                                            onPress: () => Navigator.of(context).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          FButton(
                                            style: FButtonStyle.primary,
                                            onPress: () => Navigator.of(context).pop(true),
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
                                    color: Theme.of(context).colorScheme.primary,
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
                          SizedBox(
                            height: constraints.maxHeight - 100, // Reduced height for more compact layout
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
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
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
              border: Border.all(
                color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected 
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13, 
                    fontWeight: FontWeight.w500,
                    color: isSelected 
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.primary,
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

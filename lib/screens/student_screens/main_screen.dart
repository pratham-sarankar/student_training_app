import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'profile_screen.dart';
import 'all_jobs_screen.dart';
import 'training_courses_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AllJobsScreen(),
    const TrainingCoursesScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.work_outline, size: 24),
      activeIcon: Icon(Icons.work, size: 24),
      label: 'Careers',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.school_outlined, size: 24),
      activeIcon: Icon(Icons.school, size: 24),
      label: 'Assessments',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline, size: 24),
      activeIcon: Icon(Icons.person, size: 24),
      label: 'Upskill',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colors.background,
          boxShadow: [
            BoxShadow(
              color: theme.colors.foreground.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.colors.background,
          selectedItemColor: theme.colors.primary,
          unselectedItemColor: theme.colors.mutedForeground,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: theme.colors.primary,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: theme.colors.mutedForeground,
          ),
          elevation: 0,
          items: _bottomNavItems,
        ),
      ),
    );
  }
}

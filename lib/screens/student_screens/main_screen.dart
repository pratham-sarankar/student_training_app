import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import 'profile_screen.dart';
import 'my_courses_screen.dart';
import 'all_jobs_screen.dart';
import 'training_courses_screen.dart';
import 'notification_screen.dart';
import 'job_subscription_screen.dart';

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
      label: 'All Jobs',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.school_outlined, size: 24),
      activeIcon: Icon(Icons.school, size: 24),
      label: 'Courses',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline, size: 24),
      activeIcon: Icon(Icons.person, size: 24),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: const Color(0xFF999999),
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 0,
          items: _bottomNavItems,
        ),
      ),
    );
  }
}

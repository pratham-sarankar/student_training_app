import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_work/features/auth/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_work/widgets/auth_wrapper.dart';
import 'package:learn_work/screens/student_screens/edit_profile_screen.dart';
import 'package:learn_work/screens/student_screens/notification_screen.dart';
import 'package:learn_work/screens/student_screens/education_details_screen.dart';
import 'package:learn_work/utils/service_locator.dart';
import 'my_courses_screen.dart';
import 'job_subscription_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = getIt<AuthService>();
  int _courseCount = 0;
  bool _isLoadingCourseCount = true;

  String get _userName {
    final user = _authService.currentUser;
    return user?.displayName ?? 'User';
  }

  String get _userEmail {
    final user = _authService.currentUser;
    return user?.email ?? 'user@email.com';
  }

  @override
  void initState() {
    super.initState();
    _loadCourseCount();
  }

  Future<void> _loadCourseCount() async {
    try {
      setState(() {
        _isLoadingCourseCount = true;
      });

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        setState(() {
          _courseCount = 0;
          _isLoadingCourseCount = false;
        });
        return;
      }

      // Import FirebaseFirestore
      final firestore = FirebaseFirestore.instance;
      final userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        setState(() {
          _courseCount = 0;
          _isLoadingCourseCount = false;
        });
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final purchasedCourseIds = List<String>.from(
        userData['purchasedCourses'] ?? [],
      );

      setState(() {
        _courseCount = purchasedCourseIds.length;
        _isLoadingCourseCount = false;
      });
    } catch (e) {
      setState(() {
        _courseCount = 0;
        _isLoadingCourseCount = false;
      });
      print('Error loading course count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: theme.colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadCourseCount,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.2,
                              ),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _userName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _userEmail,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Student',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // My Courses Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.school,
                                size: 20,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'My Courses',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                  ),
                                  Text(
                                    'View all your purchased courses',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child:
                                  _isLoadingCourseCount
                                      ? SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                theme.colorScheme.primary,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        '$_courseCount',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                            ),
                                      ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const MyCoursesScreen(),
                                ),
                              );
                              // Refresh course count when returning from MyCoursesScreen
                              if (result == true) {
                                _loadCourseCount();
                              }
                            },
                            child: Text(
                              'View My Courses',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Profile Options

                  // Profile Options
                  _buildProfileOption(
                    context,
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildProfileOption(
                    context,
                    icon: Icons.school_outlined,
                    title: 'Education Details',
                    subtitle: 'Manage your educational background',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EducationDetailsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildProfileOption(
                    context,
                    icon: Icons.work_outline,
                    title: 'Job Subscriptions',
                    subtitle: 'Manage your job alerts and preferences',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const JobSubscriptionScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildProfileOption(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage your notification preferences',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildProfileOption(
                    context,
                    icon: Icons.security_outlined,
                    title: 'Privacy & Security',
                    subtitle: 'Control your account security',
                    onTap: () {
                      // TODO: Navigate to privacy settings
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildProfileOption(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildProfileOption(
                    context,
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'Learn more about Gradspark',
                    onTap: () {
                      // TODO: Navigate to about
                    },
                  ),
                  const SizedBox(height: 20),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () async {
                        try {
                          await getIt<AuthService>().signOut();
                          // Navigation will be handled by AuthWrapper
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Successfully signed out'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const AuthWrapper(),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to sign out: $e'),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        'Logout',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 20, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

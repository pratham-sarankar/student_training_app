import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../admin_screen/admin_login_screen.dart';
import '../../providers/admin_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final typography = context.theme.typography;
    return Scaffold(
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
            child: Column(
              children: [
                SizedBox(height: 60.h),

                // Professional Logo Section
                Container(
                  width: 120.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: theme.colors.primaryForeground,
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(color: theme.colors.border, width: 1.w),
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    size: 56.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 40.h),

                // Main Title
                Text(
                  'Learn Work',
                  style: typography.xl3.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),

                // Subtitle
                Text(
                  'Your gateway to professional learning. Join thousands of professionals advancing their careers',
                  style: typography.lg,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                ),
                const Spacer(),
                // Primary Action Button
                FButton(
                  onPress: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: Text('Sign In'),
                ),
                SizedBox(height: 20),
                // Secondary Action Button
                FButton(
                  style: FButtonStyle.outline,
                  onPress: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: Text('Create Account'),
                ),
                SizedBox(height: 20.h),

                // Admin Login Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: FButton(
                    style: FButtonStyle.ghost,
                    onPress: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => ChangeNotifierProvider(
                                create: (context) => AdminProvider(),
                                child: const AdminLoginScreen(),
                              ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          size: 20.sp,
                          color: const Color(0xFF666666),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Login as Admin',
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

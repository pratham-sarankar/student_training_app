import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
      
              // Professional Logo Section
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colors.primaryForeground,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: theme.colors.border, width: 1),
                ),
                child: Icon(
                  Icons.school_outlined,
                  size: 56,
                  color: theme.colors.primary,
                ),
              ),
              const SizedBox(height: 40),
      
              // Main Title
              Text(
                'Gradspark',
                style: typography.xl3.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
      
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
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
      
              // Admin Login Button
              SizedBox(
                width: double.infinity,
                height: 48,
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
                        size: 20,
                        color: const Color(0xFF666666),
                      ),
                      const SizedBox(width: 8),
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/screens/login_screen.dart';
import '../auth/screens/register_screen.dart';
import '../../screens/admin_screen/admin_login_screen.dart';
import '../../providers/admin_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Background image at bottom
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Image.asset(
              'assets/images/students.png',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.4,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Logo with shadow
                  Image.asset(
                    'assets/images/logo_and_title.jpeg',
                    width: size.width * 0.5,
                  ),

                  const SizedBox(height: 25),

                  // Features with enhanced cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _FeatureItem(
                        icon: Icons.explore_outlined,
                        label: 'Explore\ncareers',
                        theme: theme,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      _FeatureItem(
                        icon: Icons.assessment_outlined,
                        label: 'Assess\nyourself',
                        theme: theme,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      _FeatureItem(
                        icon: Icons.trending_up,
                        label: 'Upskill\ntoday',
                        theme: theme,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Primary Action Button with enhanced styling
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        const Color(0xFFFFB020),
                      ),
                      foregroundColor: WidgetStateProperty.all(Colors.black),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Secondary Action Button with better styling
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Center(
                      child: Text(
                        'Create New Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Admin Login Button
                  TextButton.icon(
                    onPressed: () {
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
                    icon: Icon(
                      Icons.admin_panel_settings,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    label: Text(
                      'Login as Admin',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;
  final Gradient gradient;

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.theme,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Icon(icon, size: 30, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

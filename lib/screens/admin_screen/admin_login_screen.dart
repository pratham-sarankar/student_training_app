import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../student_screens/forgot_password_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    // Basic validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: context.theme.colors.mutedForeground,
        ),
      );
      return;
    }

    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid email address'),
          backgroundColor: context.theme.colors.mutedForeground,
        ),
      );
      return;
    }

    try {
      print(
        '🔐 Attempting admin login with email: ${_emailController.text.trim()}',
      );

      // Use the admin provider to sign in
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final success = await adminProvider.signInAdmin(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('🔐 Admin login result: $success');

      if (success && mounted) {
        // Success! The AuthWrapper will automatically handle navigation
        // based on the user's role. Just pop back to welcome screen.
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        // Get the error message from the provider if available
        final adminProvider = Provider.of<AdminProvider>(
          context,
          listen: false,
        );
        String errorMessage = adminProvider.errorMessage ?? 'Login failed';

        // If no provider error, show the caught exception
        if (errorMessage == 'Login failed') {
          if (e.toString().contains('wrong-password') ||
              e.toString().contains('incorrect')) {
            errorMessage = 'Incorrect password. Please try again.';
          } else if (e.toString().contains('user-not-found')) {
            errorMessage = 'No admin account found with this email address.';
          } else if (e.toString().contains('invalid-email')) {
            errorMessage = 'Please enter a valid email address.';
          } else if (e.toString().contains('too-many-requests')) {
            errorMessage = 'Too many failed attempts. Please try again later.';
          } else if (e.toString().contains('network')) {
            errorMessage =
                'Network error. Please check your internet connection.';
          } else if (e.toString().contains('Access denied')) {
            errorMessage =
                'Access denied. This account is not authorized for admin access.';
          } else {
            errorMessage = 'Login failed: ${e.toString()}';
          }
        }

        print('🔐 Admin login error: $errorMessage');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: context.theme.colors.destructive,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 80),

                // Admin Icon (using app logo)
                Container(
                  width: 80,
                  height: 80,
                  decoration: ShapeDecoration(
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Image.asset(
                    'assets/images/appp_logo.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Admin Login',
                  style: theme.typography.lg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colors.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Subtitle
                Text(
                  'Access administrative controls',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Email',
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FTextField(
                      controller: _emailController,
                      hint: 'Enter admin email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password',
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Stack(
                      children: [
                        FTextField(
                          controller: _passwordController,
                          hint: 'Enter password',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                        ),
                        // Password visibility toggle positioned inside the field
                        Positioned(
                          right: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                if (mounted) {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: 20,
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Forgot Password Link positioned under password field
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FButton(
                          style: FButtonStyle.ghost,
                          onPress: () {
                            // Navigate to forgot password screen
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: theme.colors.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Login Button
                Consumer<AdminProvider>(
                  builder: (context, adminProvider, child) {
                    return FButton(
                      onPress:
                          adminProvider.isLoading ? null : _handleAdminLogin,
                      child:
                          adminProvider.isLoading
                              ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colors.primaryForeground,
                                  ),
                                ),
                              )
                              : Text(
                                'Login as Admin',
                                style: theme.typography.sm.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                  color: theme.colors.primaryForeground,
                                ),
                              ),
                    );
                  },
                ),

                // Error Message Display
                Consumer<AdminProvider>(
                  builder: (context, adminProvider, child) {
                    if (adminProvider.errorMessage != null) {
                      return Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colors.destructiveForeground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.colors.destructive),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colors.destructive,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                adminProvider.errorMessage!,
                                style: TextStyle(
                                  color: theme.colors.destructive,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: adminProvider.clearError,
                              icon: Icon(
                                Icons.close,
                                color: theme.colors.destructive,
                                size: 18,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
      return;
    }

    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid email address'),
          backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
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
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 80),

                // Admin Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Admin Login',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Subtitle
                Text(
                  'Access administrative controls',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter admin email',
                      ),
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Stack(
                      children: [
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: 'Enter password',
                          ),
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
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: 20,
                                  color: theme.colorScheme.onSurfaceVariant,
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
                        TextButton(
                          onPressed: () {
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
                              color: theme.colorScheme.primary,
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
                    return FilledButton(
                      onPressed:
                          adminProvider.isLoading ? null : _handleAdminLogin,
                      child:
                          adminProvider.isLoading
                              ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                              : Text(
                                'Login as Admin',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                  color: theme.colorScheme.onPrimary,
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
                          color: theme.colorScheme.onError,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.colorScheme.error),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                adminProvider.errorMessage!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: adminProvider.clearError,
                              icon: Icon(
                                Icons.close,
                                color: theme.colorScheme.error,
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

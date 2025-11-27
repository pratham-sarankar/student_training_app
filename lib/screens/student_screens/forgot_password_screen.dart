import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Validate email
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await authProvider.resetPassword(
      email: _emailController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent! Check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: theme.colors.background,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              top: size.height * 0.4,
              child: Stack(
                children: [
                  Image.asset(
                    "assets/images/signin_bg.jpeg",
                    fit: BoxFit.cover,
                    width: size.width,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colors.background,
                          theme.colors.background.withValues(alpha: 0.4),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Back Button
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: Row(
                      children: [
                        FButton(
                          style: FButtonStyle.ghost,
                          onPress: () => Navigator.of(context).pop(),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: theme.colors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),

                                if (!authProvider.isPasswordResetSent) ...[
                                  // Title
                                  Text(
                                    'Reset Password',
                                    style: theme.typography.xl2.copyWith(
                                      color: theme.colors.foreground,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Enter your email address and we\'ll send you a link to reset your password.',
                                    style: theme.typography.sm.copyWith(
                                      color: theme.colors.mutedForeground,
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Email Field
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Email',
                                        style: theme.typography.sm.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colors.foreground,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      FTextField(
                                        controller: _emailController,
                                        hint: 'Enter your email address',
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.done,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),

                                  // Reset Button
                                  FButton(
                                    onPress:
                                        authProvider.isLoading
                                            ? null
                                            : _resetPassword,
                                    style: FButtonStyle.primary,
                                    child:
                                        authProvider.isLoading
                                            ? SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(
                                                      theme
                                                          .colors
                                                          .primaryForeground,
                                                    ),
                                              ),
                                            )
                                            : Text(
                                              'Send Reset Link',
                                              style: theme.typography.sm
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.2,
                                                    color:
                                                        theme
                                                            .colors
                                                            .primaryForeground,
                                                  ),
                                            ),
                                  ),
                                ] else ...[
                                  // Success state
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Check Your Email',
                                        style: theme.typography.xl2.copyWith(
                                          color: theme.colors.foreground,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'We\'ve sent a password reset link to:',
                                        style: theme.typography.sm.copyWith(
                                          color: theme.colors.mutedForeground,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _emailController.text.trim(),
                                        style: theme.typography.sm.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 32),

                                      // Success Icon
                                      Center(
                                        child: Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.withValues(
                                                alpha: 0.3,
                                              ),
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green,
                                            size: 48,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 32),

                                      // Instructions
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: theme.colors.mutedForeground
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: theme.colors.border,
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'What\'s next?',
                                              style: theme.typography.sm
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        theme.colors.foreground,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '1. Check your email inbox\n2. Click the reset link\n3. Create a new password\n4. Sign in with your new password',
                                              style: theme.typography.sm
                                                  .copyWith(
                                                    color:
                                                        theme
                                                            .colors
                                                            .mutedForeground,
                                                    height: 1.5,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 32),

                                      // Back to Login Button
                                      FButton(
                                        onPress: () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const LoginScreen(),
                                            ),
                                          );
                                        },
                                        style: FButtonStyle.primary,
                                        child: Text(
                                          'Back to Login',
                                          style: theme.typography.sm.copyWith(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2,
                                            color:
                                                theme.colors.primaryForeground,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 24),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

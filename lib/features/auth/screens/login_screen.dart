import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'package:learn_work/features/auth/utils/auth_type.dart';
import 'package:learn_work/features/auth/widgets/apple_auth_button.dart';
import 'package:learn_work/features/auth/widgets/google_auth_button.dart';
import 'package:learn_work/features/auth/widgets/password_form_field.dart';
import '../providers/auth_provider.dart';
import '../../../screens/student_screens/main_screen.dart';
import 'register_screen.dart';
import '../../../screens/student_screens/forgot_password_screen.dart';
import 'dart:io' show Platform;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
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

    // Validate password
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await authProvider.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed in!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // Welcome Text
                      Text(
                        'Welcome back!',
                        style: theme.typography.xl3.copyWith(
                          color: theme.colors.foreground,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // const SizedBox(height: 8),
                      Text(
                        'A journey of a thousand miles begins with a single step...',
                        style: theme.typography.lg.copyWith(
                          color: Colors.grey.shade900,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 32),

                      // Email Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            hint: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

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
                          PasswordFormField(controller: _passwordController),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FButton(
                            style: FButtonStyle.ghost,
                            onPress: () {
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
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Sign In Button
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return FButton(
                            onPress:
                                authProvider.isLoading
                                    ? null
                                    : _signInWithEmail,
                            style: FButtonStyle.primary,
                            child:
                                authProvider.isLoading
                                    ? SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              theme.colors.primaryForeground,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      'Sign In',
                                      style: theme.typography.sm.copyWith(
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.2,
                                        color: theme.colors.primaryForeground,
                                      ),
                                    ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Divider with "or"
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade600,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or continue with',
                              style: theme.typography.sm.copyWith(
                                color: Colors.grey.shade900,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade600,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Social Sign In Buttons
                      Column(
                        children: [
                          // Google Sign In
                          GoogleAuthButton(type: AuthType.signIn),

                          // Only show Apple Sign In on iOS
                          if (Platform.isIOS) ...[
                            const SizedBox(height: 12),
                            AppleAuthButton(type: AuthType.signIn),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: theme.typography.sm.copyWith(
                              color: Colors.grey.shade900,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: theme.colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

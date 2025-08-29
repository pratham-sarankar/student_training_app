import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import '../../services/auth_service.dart';
import 'phone_verification.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _acceptedTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    // Validate full name
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: context.theme.colors.destructive,
        ),
      );
      return;
    }

    // Validate email
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email'),
          backgroundColor: context.theme.colors.destructive,
        ),
      );
      return;
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email'),
          backgroundColor: context.theme.colors.destructive,
        ),
      );
      return;
    }

    // Validate phone
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your phone number'),
          backgroundColor: context.theme.colors.destructive,
        ),
      );
      return;
    }

    // Validate password
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a password'),
          backgroundColor: context.theme.colors.destructive,
        ),
      );
      return;
    }
    
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: context.theme.colors.destructive,
        ),
      );
      return;
    }

    // Validate confirm password
    if (_confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please confirm your password'),
          backgroundColor: context.theme.colors.destructive,
        ),
      );
      return;
    }
    
    if (_confirmPasswordController.text != _passwordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: context.theme.colors.destructive,
        ),
      );
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: context.theme.colors.destructive,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user account
      final userCredential = await _authService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Update user profile with full name
      if (userCredential.user != null) {
        await _authService.updateUserProfile(
          displayName: _fullNameController.text.trim(),
        );

        // Parse first and last name
        final nameParts = _fullNameController.text.trim().split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        // Create user document in Firestore using UserService
        // final userService = UserService(); // This line was removed as per the new_code
        // await userService.createOrUpdateUserBasic( // This line was removed as per the new_code
        //   uid: userCredential.user!.uid, // This line was removed as per the new_code
        //   firstName: firstName, // This line was removed as per the new_code
        //   lastName: lastName, // This line was removed as per the new_code
        //   email: _emailController.text.trim(), // This line was removed as per the new_code
        //   phoneNumber: _phoneController.text.trim(), // This line was removed as per the new_code
        // ); // This line was removed as per the new_code

        // Save phone number locally as backup
        // final prefs = await SharedPreferences.getInstance(); // This line was removed as per the new_code
        // await prefs.setString('phoneNumber', _phoneController.text.trim()); // This line was removed as per the new_code

        // Send email verification
        print('Sending email verification to: ${_emailController.text.trim()}');
        await _authService.sendEmailVerification();
        print('Email verification sent successfully during registration');

        if (mounted) {
          // Navigate to email verification screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PhoneVerificationScreen(
                phoneNumber: _phoneController.text.trim(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: context.theme.colors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Scaffold(
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: theme.colors.background,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                
                // App Logo/Title
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colors.primaryForeground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colors.border,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    size: 40,
                    color: theme.colors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Create Account Text
                Text(
                  'Create Account',
                  style: theme.typography.lg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colors.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Join us and start your learning adventure',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Full Name Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Full Name',
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FTextField(
                      controller: _fullNameController,
                      hint: 'Enter your full name',
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
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
                
                // Phone Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone Number',
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FTextField(
                      controller: _phoneController,
                      hint: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
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
                    FTextField(
                      controller: _passwordController,
                      hint: 'Create a strong password',
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Confirm Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirm Password',
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FTextField(
                      controller: _confirmPasswordController,
                      hint: 'Confirm your password',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Terms and Conditions using Forui Checkbox
                Row(
                  children: [
                    FCheckbox(
                      value: _acceptedTerms,
                      onChange: (value) {
                        setState(() {
                          _acceptedTerms = value;
                        });
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.foreground,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: theme.colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: theme.colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Register Button
                FButton(
                  onPress: _acceptedTerms && !_isLoading ? _createAccount : null,
                  style: _acceptedTerms ? FButtonStyle.primary : FButtonStyle.primary,
                  child: _isLoading
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primaryForeground),
                          ),
                        )
                      : Text(
                          'Create Account',
                          style: theme.typography.sm.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            color: theme.colors.primaryForeground,
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.foreground,
                      ),
                    ),
                    FButton(
                      style: FButtonStyle.ghost,
                      onPress: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: theme.colors.primary,
                          fontWeight: FontWeight.w600,
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
      ),
    );
  }
}


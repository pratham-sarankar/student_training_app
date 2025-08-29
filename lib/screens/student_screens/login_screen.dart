import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import '../../services/auth_service.dart';
import 'main_screen.dart';
import 'phone_verification.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isPhoneMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
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
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
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

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      // Navigation will be handled by AuthWrapper
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed in!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
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

  Future<void> _sendPhoneVerification() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Format phone number to international format if not already
    String phoneNumber = _phoneController.text.trim();
    
    // Remove any spaces, dashes, or parentheses
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check if it starts with +91 (India)
    if (phoneNumber.startsWith('+91')) {
      phoneNumber = phoneNumber;
    } else if (phoneNumber.startsWith('91') && phoneNumber.length == 12) {
      phoneNumber = '+$phoneNumber';
    } else if (phoneNumber.startsWith('0') && phoneNumber.length == 11) {
      phoneNumber = '+91${phoneNumber.substring(1)}';
    } else if (phoneNumber.length == 10) {
      phoneNumber = '+91$phoneNumber';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Indian phone number (10 digits)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Validate final format: +91 followed by exactly 10 digits
    if (!RegExp(r'^\+91[0-9]{10}$').hasMatch(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Indian phone number (10 digits)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithPhoneNumber(phoneNumber);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to phone verification screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PhoneVerificationScreen(
              phoneNumber: phoneNumber,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
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

  void _toggleLoginMode() {
    setState(() {
      _isPhoneMode = !_isPhoneMode;
    });
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
                    _isPhoneMode ? Icons.phone_android : Icons.school_outlined,
                    size: 36,
                    color: theme.colors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Welcome Text
                Text(
                  'Welcome back!',
                  style: theme.typography.lg.copyWith(
                    color: theme.colors.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  _isPhoneMode 
                    ? 'Sign in with your Indian phone number'
                    : 'Sign in to continue your learning journey',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Login Mode Toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: FButton(
                          style: _isPhoneMode 
                            ? FButtonStyle.ghost 
                            : FButtonStyle.primary,
                          onPress: _isPhoneMode ? _toggleLoginMode : null,
                          child: Text(
                            'Email',
                            style: TextStyle(
                              color: _isPhoneMode 
                                ? theme.colors.foreground
                                : theme.colors.primaryForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FButton(
                          style: _isPhoneMode 
                            ? FButtonStyle.primary 
                            : FButtonStyle.ghost,
                          onPress: _isPhoneMode ? null : _toggleLoginMode,
                          child: Text(
                            'Phone',
                            style: TextStyle(
                              color: _isPhoneMode 
                                ? theme.colors.primaryForeground
                                : theme.colors.foreground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Email/Phone Fields
                if (!_isPhoneMode) ...[
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
                      FTextField(
                        controller: _passwordController,
                        hint: 'Enter your password',
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                      ),
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
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: theme.colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Phone Number Field
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
                        hint: 'Enter 10-digit number',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: theme.colors.foreground,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Enter your 10-digit Indian mobile number (e.g., 9876543210)',
                              style: theme.typography.sm.copyWith(
                                color: theme.colors.foreground,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Country code +91 will be automatically added',
                        style: theme.typography.sm.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colors.foreground,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                
                // Login/Verify Button
                FButton(
                  onPress: _isLoading ? null : (_isPhoneMode ? _sendPhoneVerification : _signInWithEmail),
                  style: FButtonStyle.primary,
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
                          _isPhoneMode ? 'Send Code' : 'Sign In',
                          style: theme.typography.sm.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            color: theme.colors.primaryForeground,
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.foreground,
                      ),
                    ),
                    FButton(
                      style: FButtonStyle.ghost,
                      onPress: () {
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


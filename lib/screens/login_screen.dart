import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_work/screens/main_screen.dart';
import 'package:learn_work/screens/phone_verification.dart';
import 'package:learn_work/screens/register_screen.dart';
import 'package:learn_work/screens/forgot_password_screen.dart';
import 'package:learn_work/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


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
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 24.h),
                
                // App Logo/Title
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      width: 1.w,
                    ),
                  ),
                  child: Icon(
                    _isPhoneMode ? Icons.phone_android : Icons.school_outlined,
                    size: 36.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 20.h),
                
                // Welcome Text
                Text(
                  'Welcome back!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  _isPhoneMode 
                    ? 'Sign in with your Indian phone number'
                    : 'Sign in to continue your learning journey',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF888888),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                
                // Login Mode Toggle
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12.r),
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
                                ? const Color(0xFF888888)
                                : Colors.white,
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
                                ? Colors.white
                                : const Color(0xFF888888),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Email/Phone Fields
                if (!_isPhoneMode) ...[
                  // Email Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      FTextField(
                        controller: _emailController,
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  
                  // Password Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      FTextField(
                        controller: _passwordController,
                        hint: 'Enter your password',
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  
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
                            color: Theme.of(context).colorScheme.primary,
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      FTextField(
                        controller: _phoneController,
                        hint: 'Enter 10-digit number',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16.sp,
                            color: const Color(0xFF888888),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              'Enter your 10-digit Indian mobile number (e.g., 9876543210)',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF888888),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Country code +91 will be automatically added',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 20.h),
                
                // Login/Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: FButton(
                    onPress: _isLoading ? null : (_isPhoneMode ? _sendPhoneVerification : _signInWithEmail),
                    style: FButtonStyle.primary,
                    child: _isLoading
                        ? SizedBox(
                            height: 18.h,
                            width: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _isPhoneMode ? 'Send Code' : 'Sign In',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 12.h),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF888888),
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
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}


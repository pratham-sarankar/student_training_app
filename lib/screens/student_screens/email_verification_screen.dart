import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learn_work/screens/student_screens/main_screen.dart';
import 'package:learn_work/services/user_service.dart';
import 'dart:async'; // Added for Timer

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResendEnabled = true;
  int _resendCountdown = 60;
  Timer? _verificationCheckTimer;
  bool _isVerificationInProgress = false; // Add flag to prevent duplicate verification

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _verificationCheckTimer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
            _startResendCountdown();
          } else {
            _isResendEnabled = true;
          }
        });
      }
    });
  }

  void _startVerificationCheck() {
    // Check verification status every 3 seconds
    _verificationCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerification();
    });
  }

  void _checkEmailVerification() async {
    // Prevent duplicate verification checks
    if (_isVerificationInProgress) return;
    
    try {
      _isVerificationInProgress = true;
      
      // Reload the user to get the latest verification status
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null && user.emailVerified) {
        // Email is verified, update Firestore and navigate
        try {
          final userService = UserService();
          await userService.updateVerificationStatus(isEmailVerified: true);
        } catch (e) {
          print('Error updating verification status in Firestore: $e');
          // Continue with navigation even if Firestore update fails
        }
        
        // Cancel timer and navigate
        _verificationCheckTimer?.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
          );
        }
      }
    } catch (e) {
      print('Error checking email verification: $e');
    } finally {
      _isVerificationInProgress = false;
    }
  }

  void _onResendEmail() async {
    try {
      print('Attempting to send email verification...');
      final user = FirebaseAuth.instance.currentUser;
      print('Current user: ${user?.email}');
      print('User email verified: ${user?.emailVerified}');
      
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      print('Email verification sent successfully!');
      
      setState(() {
        _isResendEnabled = false;
        _resendCountdown = 60;
      });
      _startResendCountdown();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error sending email verification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100.w,
                      height: 100.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          width: 1.w,
                        ),
                      ),
                      child: Icon(
                        Icons.email_outlined,
                        size: 48.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      'Verify your email',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'We\'ve sent a verification email to:',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF888888),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Please check your email and click the verification link to continue.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF888888),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: FButton(
                        onPress: _isResendEnabled ? _onResendEmail : null,
                        style: FButtonStyle.primary,
                        child: Text(
                          _isResendEnabled
                              ? 'Resend Email'
                              : 'Resend in $_resendCountdown seconds',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    FButton(
                      style: FButtonStyle.ghost,
                      onPress: () {
                        // Check verification status immediately
                        if (!_isVerificationInProgress) {
                          _checkEmailVerification();
                        }
                      },
                      child: Text(
                        'I\'ve verified my email',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    FButton(
                      style: FButtonStyle.ghost,
                      onPress: () {
                        // Skip email verification and proceed
                        // You can add navigation logic here to go to the main app
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email verification skipped. You can verify later in settings.'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Skip for now',
                        style: TextStyle(
                          color: const Color(0xFF888888),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

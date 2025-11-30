import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learn_work/screens/student_screens/main_screen.dart';
import 'package:learn_work/services/user_service.dart';
import 'dart:async'; // Added for Timer

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResendEnabled = true;
  int _resendCountdown = 60;
  Timer? _verificationCheckTimer;
  bool _isVerificationInProgress =
      false; // Add flag to prevent duplicate verification

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
    _verificationCheckTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) {
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
            SnackBar(
              content: Text('Email verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
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
          SnackBar(
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
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: theme.colorScheme.surface,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: theme.colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.email_outlined,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Verify your email',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'We\'ve sent a verification email to:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Please check your email and click the verification link to continue.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _isResendEnabled ? _onResendEmail : null,
                        child: Text(
                          _isResendEnabled
                              ? 'Resend Email'
                              : 'Resend in $_resendCountdown seconds',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // Check verification status immediately
                        if (!_isVerificationInProgress) {
                          _checkEmailVerification();
                        }
                      },
                      child: Text(
                        'I\'ve verified my email',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        // Skip email verification and proceed
                        // You can add navigation logic here to go to the main app
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Email verification skipped. You can verify later in settings.',
                            ),
                            backgroundColor: theme.colorScheme.error,
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
                          color: theme.colorScheme.onSurface,
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

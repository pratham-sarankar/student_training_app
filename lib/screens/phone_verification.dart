import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:learn_work/screens/main_screen.dart';
import 'package:learn_work/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class PhoneVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const PhoneVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _otpController = TextEditingController();
  final _authService = AuthService();
  final _otpFocusNode = FocusNode();
  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 60;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto-focus the OTP input field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendTimer = 60;
    
    // Cancel any existing timer
    _timer?.cancel();
    
    // Create a new timer that ticks every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyCode() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔐 Attempting to verify code: ${_otpController.text}');
      await _authService.verifyPhoneNumberWithCode(_otpController.text);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      print('❌ Verification error: $e');
      if (mounted) {
        String errorMessage = 'Verification failed. Please check your code and try again.';
        if (e.toString().contains('invalid-verification-code')) {
          errorMessage = 'Invalid verification code. Please check and try again.';
        } else if (e.toString().contains('session-expired')) {
          errorMessage = 'Verification session expired. Please request a new code.';
        } else if (e.toString().contains('too-many-requests')) {
          errorMessage = 'Too many attempts. Please wait before trying again.';
        } else if (e.toString().contains('quota-exceeded')) {
          errorMessage = 'SMS quota exceeded. Please try again later.';
        } else if (e.toString().contains('BILLING_NOT_ENABLED')) {
          errorMessage = 'Firebase billing not enabled. Phone verification requires the Blaze plan.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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

  Future<void> _resendCode() async {
    if (!_canResend || _isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      print('🔄 Attempting to resend code to: ${widget.phoneNumber}');
      await _authService.resendVerificationCode(widget.phoneNumber);
      
      if (mounted) {
        // Reset the timer after successful resend
        _startResendTimer();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code resent successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Resend error: $e');
      if (mounted) {
        String errorMessage = 'Failed to resend code. Please try again.';
        if (e.toString().contains('too-many-requests')) {
          errorMessage = 'Too many attempts. Please wait before trying again.';
        } else if (e.toString().contains('invalid-phone-number')) {
          errorMessage = 'Invalid phone number format.';
        } else if (e.toString().contains('quota-exceeded')) {
          errorMessage = 'SMS quota exceeded. Please try again later.';
        } else if (e.toString().contains('network-error')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (e.toString().contains('BILLING_NOT_ENABLED')) {
          errorMessage = 'Firebase billing not enabled. Phone verification requires the Blaze plan.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  String _formatTimer(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
            child: Column(
              children: [
                SizedBox(height: 24.h),
                
                // Back Button
                Row(
                  children: [
                    FButton(
                      style: FButtonStyle.ghost,
                      onPress: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 20.sp,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                
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
                    Icons.phone_android,
                    size: 36.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 20.h),
                
                // Title
                Text(
                  'Verify Phone Number',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'We\'ve sent a 6-digit verification code to',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF888888),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.phoneNumber,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16.sp,
                        color: Colors.green,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Code sent successfully',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                
                // OTP Input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verification Code',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    FTextField(
                      controller: _otpController,
                      hint: 'Enter 6-digit code',
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      focusNode: _otpFocusNode,
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                
                // Helpful Information
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                      width: 1.w,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18.sp,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Not receiving the code?',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '• Check if the SMS is in your spam folder\n• Ensure your phone has good network coverage\n• Wait a few minutes - SMS delivery can be delayed\n• Try resending the code after the timer expires',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Billing Error Warning
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1.w,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 18.sp,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Firebase Billing Issue',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Phone verification requires Firebase billing to be enabled. Contact your developer to fix this issue.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: FButton(
                    onPress: _isLoading ? null : _verifyCode,
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
                            'Verify',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Resend Code
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive the code? ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF888888),
                          ),
                        ),
                        if (_canResend)
                          FButton(
                            style: FButtonStyle.ghost,
                            onPress: _isResending ? null : _resendCode,
                            child: _isResending
                                ? SizedBox(
                                    height: 14.h,
                                    width: 14.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Resend',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          )
                        else
                          Text(
                            'Resend in ${_formatTimer(_resendTimer)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF888888),
                            ),
                          ),
                      ],
                    ),
                    if (!_canResend) ...[
                      SizedBox(height: 8.h),
                      Text(
                        'Please wait before requesting a new code',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFAAAAAA),
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

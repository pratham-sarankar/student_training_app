import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:gradspark/screens/student_screens/main_screen.dart';
import 'package:gradspark/features/auth/services/auth_service.dart';
import 'package:gradspark/utils/service_locator.dart';
import 'dart:async';

class PhoneVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const PhoneVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _otpController = TextEditingController();
  final _authService = getIt<AuthService>();
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
        SnackBar(
          content: Text('Please enter the complete 6-digit code'),
          backgroundColor: context.theme.colors.destructive,
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
          SnackBar(
            content: Text('Phone number verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('❌ Verification error: $e');
      if (mounted) {
        String errorMessage =
            'Verification failed. Please check your code and try again.';
        if (e.toString().contains('invalid-verification-code')) {
          errorMessage =
              'Invalid verification code. Please check and try again.';
        } else if (e.toString().contains('session-expired')) {
          errorMessage =
              'Verification session expired. Please request a new code.';
        } else if (e.toString().contains('too-many-requests')) {
          errorMessage = 'Too many attempts. Please wait before trying again.';
        } else if (e.toString().contains('quota-exceeded')) {
          errorMessage = 'SMS quota exceeded. Please try again later.';
        } else if (e.toString().contains('BILLING_NOT_ENABLED')) {
          errorMessage =
              'Firebase billing not enabled. Phone verification requires the Blaze plan.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: context.theme.colors.destructive,
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
          SnackBar(
            content: Text('Verification code resent successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
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
          errorMessage =
              'Firebase billing not enabled. Phone verification requires the Blaze plan.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: context.theme.colors.destructive,
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
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Back Button
                Row(
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
                const SizedBox(height: 20),

                // App Logo/Title
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colors.primaryForeground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colors.border, width: 1),
                  ),
                  child: Icon(
                    Icons.phone_android,
                    size: 36,
                    color: theme.colors.primary,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Verify Phone Number',
                  style: theme.typography.lg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colors.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ve sent a 6-digit verification code to',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.phoneNumber,
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colors.foreground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Code sent successfully',
                        style: theme.typography.sm.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // OTP Input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verification Code',
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Pinput(
                      controller: _otpController,
                      length: 6,
                      focusNode: _otpFocusNode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      defaultPinTheme: PinTheme(
                        width: 48,
                        height: 48,
                        textStyle: theme.typography.lg.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colors.foreground,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colors.border,
                            width: 1.5,
                          ),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 48,
                        height: 48,
                        textStyle: theme.typography.lg.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colors.primary,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colors.primary,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colors.primary.withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      submittedPinTheme: PinTheme(
                        width: 48,
                        height: 48,
                        textStyle: theme.typography.lg.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colors.primaryForeground,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.primary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      errorPinTheme: PinTheme(
                        width: 48,
                        height: 48,
                        textStyle: theme.typography.lg.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colors.primaryForeground,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.destructive,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colors.destructive,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onCompleted: (pin) {
                        // Auto-verify when all 6 digits are entered
                        _verifyCode();
                      },
                      onChanged: (pin) {
                        // Optional: Add any validation logic here
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Helpful Information
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: theme.colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Not receiving the code?',
                            style: theme.typography.sm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Check if the SMS is in your spam folder\n• Ensure your phone has good network coverage\n• Wait a few minutes - SMS delivery can be delayed\n• Try resending the code after the timer expires',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.primary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FButton(
                    onPress: _isLoading ? null : _verifyCode,
                    style: FButtonStyle.primary,
                    child:
                        _isLoading
                            ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colors.primaryForeground,
                                ),
                              ),
                            )
                            : Text(
                              'Verify',
                              style: theme.typography.sm.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                                color: theme.colors.primaryForeground,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 24),

                // Resend Code
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive the code? ',
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.foreground,
                          ),
                        ),
                        if (_canResend)
                          FButton(
                            style: FButtonStyle.ghost,
                            onPress: _isResending ? null : _resendCode,
                            child:
                                _isResending
                                    ? SizedBox(
                                      height: 14,
                                      width: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              theme.colors.foreground,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      'Resend',
                                      style: TextStyle(
                                        color: theme.colors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          )
                        else
                          Text(
                            'Resend in ${_formatTimer(_resendTimer)}',
                            style: theme.typography.sm.copyWith(
                              color: theme.colors.foreground,
                            ),
                          ),
                      ],
                    ),
                    if (!_canResend) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Please wait before requesting a new code',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.foreground,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

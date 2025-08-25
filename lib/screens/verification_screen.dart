import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'main_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String type; // 'email' or 'phone'
  final String value; // email address or phone number

  const VerificationScreen({
    super.key,
    required this.type,
    required this.value,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  bool _isResendEnabled = true;
  int _resendCountdown = 60;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
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

  void _onResendCode() {
    setState(() {
      _isResendEnabled = false;
      _resendCountdown = 60;
    });
    _startResendCountdown();
    // TODO: Implement resend code logic
  }

  void _onVerifyCode() {
    final code = _pinController.text;
    if (code.length == 6) {
      // TODO: Implement verification logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verifying code: $code'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      
      // Navigate to home screen after successful verification
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: EdgeInsets.only(left: 8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFE5E5E5),
                width: 1.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: const Color(0xFF1A1A1A),
                size: 20.sp,
              ),
              style: IconButton.styleFrom(
                padding: EdgeInsets.all(12.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
            child: Column(
              children: [
                SizedBox(height: 40.h),
                
                // Verification Icon
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
                    widget.type == 'email' ? Icons.email_outlined : Icons.phone_outlined,
                    size: 48.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 32.h),
                
                // Title
                Text(
                  'Verify ${widget.type == 'email' ? 'Email' : 'Phone'}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                
                // Description
                Text(
                  'We\'ve sent a verification code to',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF888888),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),
                
                // Verification Code Input
                Text(
                  'Enter verification code',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 20.h),
                
                // PIN Input using Pinput package
                Pinput(
                  controller: _pinController,
                  focusNode: _pinFocusNode,
                  length: 6,
                  defaultPinTheme: PinTheme(
                    width: 48.w,
                    height: 56.h,
                    textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E5E5)),
                      borderRadius: BorderRadius.circular(8.r),
                      color: Colors.white,
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 48.w,
                    height: 56.h,
                    textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5.w,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                      color: Colors.white,
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: 48.w,
                    height: 56.h,
                    textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(8.r),
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    ),
                  ),
                  onCompleted: (pin) {
                    _onVerifyCode();
                  },
                  onChanged: (pin) {
                    // Optional: Handle pin changes
                  },
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                ),
                SizedBox(height: 32.h),
                
                // Verify Button using Forui
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: FButton(
                    onPress: _onVerifyCode,
                    child: Text(
                      'Verify Code',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                
                // Resend Code Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Didn\'t receive the code? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF888888),
                      ),
                    ),
                    TextButton(
                      onPressed: _isResendEnabled ? _onResendCode : null,
                      child: Text(
                        _isResendEnabled
                            ? 'Resend Code'
                            : 'Resend in $_resendCountdown seconds',
                        style: TextStyle(
                          color: _isResendEnabled
                              ? Theme.of(context).colorScheme.primary
                              : const Color(0xFFCCCCCC),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

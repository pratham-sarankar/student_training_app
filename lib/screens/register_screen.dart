import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'verification_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
            child: Column(
              children: [
                SizedBox(height: 40.h),
                
                // App Logo/Title
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
                    Icons.school_outlined,
                    size: 48.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 32.h),
                
                // Create Account Text
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Join us and start your learning adventure',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF888888),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),
                
                // Full Name Field using Forui
                FTextField(
                  label: const Text('Full Name'),
                  hint: 'Enter your full name',
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 20.h),
                
                // Email Field using Forui
                FTextField(
                  label: const Text('Email'),
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 20.h),
                
                // Phone Field using Forui
                FTextField(
                  label: const Text('Phone Number'),
                  hint: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 20.h),
                
                // Password Field using Forui
                FTextField(
                  label: const Text('Password'),
                  hint: 'Create a strong password',
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 20.h),
                
                // Confirm Password Field using Forui
                FTextField(
                  label: const Text('Confirm Password'),
                  hint: 'Confirm your password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 12.h),
                
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _acceptedTerms ? const Color(0xFF666666) : const Color(0xFF888888),
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                
                // Register Button using Forui
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: FButton(
                    onPress: _acceptedTerms ? () {
                      // Navigate to verification screen for demo
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const VerificationScreen(
                            type: 'email',
                            value: 'user@example.com',
                          ),
                        ),
                      );
                    } : null, // Disable button if terms not accepted
                    child: Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: _acceptedTerms ? Colors.white : const Color(0xFFCCCCCC),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                

                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF888888),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
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


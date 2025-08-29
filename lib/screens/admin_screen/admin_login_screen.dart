import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../services/admin_service.dart';
import '../student_screens/forgot_password_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    // Basic validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

         try {
       print('🔐 Attempting admin login with email: ${_emailController.text.trim()}');
       
       // Use the admin provider to sign in
       final adminProvider = Provider.of<AdminProvider>(context, listen: false);
       final success = await adminProvider.signInAdmin(
         _emailController.text.trim(),
         _passwordController.text,
       );
       
       print('🔐 Admin login result: $success');
       
       if (success && mounted) {
         // Success! The AuthWrapper will automatically handle navigation
         // based on the user's role. Just pop back to welcome screen.
         Navigator.of(context).pop();
       }
     } catch (e) {
       if (mounted) {
         // Get the error message from the provider if available
         final adminProvider = Provider.of<AdminProvider>(context, listen: false);
         String errorMessage = adminProvider.errorMessage ?? 'Login failed';
         
         // If no provider error, show the caught exception
         if (errorMessage == 'Login failed') {
           if (e.toString().contains('wrong-password') || e.toString().contains('incorrect')) {
             errorMessage = 'Incorrect password. Please try again.';
           } else if (e.toString().contains('user-not-found')) {
             errorMessage = 'No admin account found with this email address.';
           } else if (e.toString().contains('invalid-email')) {
             errorMessage = 'Please enter a valid email address.';
           } else if (e.toString().contains('too-many-requests')) {
             errorMessage = 'Too many failed attempts. Please try again later.';
           } else if (e.toString().contains('network')) {
             errorMessage = 'Network error. Please check your internet connection.';
           } else if (e.toString().contains('Access denied')) {
             errorMessage = 'Access denied. This account is not authorized for admin access.';
           } else {
             errorMessage = 'Login failed: ${e.toString()}';
           }
         }
         
         print('🔐 Admin login error: $errorMessage');
         
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(errorMessage),
             backgroundColor: Colors.red,
             duration: const Duration(seconds: 4),
           ),
         );
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                SizedBox(height: 80),
                
                // Admin Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 20),
                
                // Title
                Text(
                  'Admin Login',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                
                // Subtitle
                Text(
                  'Access administrative controls',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF888888),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                
                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Email',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 6),
                    FTextField(
                      controller: _emailController,
                      hint: 'Enter admin email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
                SizedBox(height: 12),
                
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
                    SizedBox(height: 6),
                    Stack(
                      children: [
                        FTextField(
                          controller: _passwordController,
                          hint: 'Enter password',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                        ),
                        // Password visibility toggle positioned inside the field
                        Positioned(
                          right: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              child: Container(
                                    padding: EdgeInsets.all(8),
                                child: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  size: 20,
                                  color: const Color(0xFF666666),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Forgot Password Link positioned under password field
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FButton(
                          style: FButtonStyle.ghost,
                          onPress: () {
                            // Navigate to forgot password screen
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
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Login Button
                Consumer<AdminProvider>(
                  builder: (context, adminProvider, child) {
                    return FButton(
                      onPress: adminProvider.isLoading ? null : _handleAdminLogin,
                      child: adminProvider.isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Login as Admin',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                                color: Colors.white,
                              ),
                            ),
                    );
                  },
                ),
                
                // Error Message Display
                Consumer<AdminProvider>(
                  builder: (context, adminProvider, child) {
                    if (adminProvider.errorMessage != null) {
                      return Container(
                        margin: EdgeInsets.only(top: 16),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                adminProvider.errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: adminProvider.clearError,
                              icon: Icon(
                                Icons.close,
                                color: Colors.red.shade600,
                                    size: 18,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:learn_work/features/auth/utils/auth_type.dart';
import 'package:learn_work/screens/student_screens/main_screen.dart';
import 'package:learn_work/features/auth/services/auth_service.dart';
import 'package:learn_work/utils/service_locator.dart';

class AppleAuthButton extends StatefulWidget {
  const AppleAuthButton({super.key, this.type});
  final AuthType? type;
  @override
  State<AppleAuthButton> createState() => _AppleAuthButtonState();
}

class _AppleAuthButtonState extends State<AppleAuthButton> {
  bool _isLoading = false;

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final _authService = getIt<AuthService>();
      await _authService.signInWithApple();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed in with Apple!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
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
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _signInWithApple,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 0),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(Icons.apple, size: 24),
      label: Text(
        widget.type == AuthType.signIn
            ? 'Sign in with Apple'
            : 'Sign up with Apple',
        style: context.theme.typography.sm.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

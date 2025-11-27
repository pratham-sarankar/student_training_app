import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:learn_work/features/auth/utils/auth_type.dart';
import 'package:learn_work/screens/student_screens/main_screen.dart';
import 'package:learn_work/services/auth_service.dart';

class GoogleAuthButton extends StatefulWidget {
  const GoogleAuthButton({super.key, this.type});
  final AuthType? type;
  @override
  State<GoogleAuthButton> createState() => _GoogleAuthButtonState();
}

class _GoogleAuthButtonState extends State<GoogleAuthButton> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Add getit locator for AuthService.
      final _authService = AuthService();
      await _authService.signInWithGoogle();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed in with Google!'),
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
      onPressed: _isLoading ? null : _signInWithGoogle,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 0),
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Brand(Brands.google, size: 20),
      label: Text(
        widget.type == AuthType.signIn
            ? 'Sign in with Google'
            : 'Sign up with Google',
        style: context.theme.typography.sm.copyWith(
          color: context.theme.colors.foreground,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

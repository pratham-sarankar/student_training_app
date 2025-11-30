import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'package:learn_work/features/auth/utils/auth_type.dart';
import 'package:learn_work/screens/student_screens/main_screen.dart';
import 'package:learn_work/features/auth/providers/auth_provider.dart';

class AppleAuthButton extends StatelessWidget {
  const AppleAuthButton({super.key, this.type});
  final AuthType? type;

  Future<void> _signInWithApple(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithApple();

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed in with Apple!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return OutlinedButton.icon(
          onPressed:
              authProvider.isLoading ? null : () => _signInWithApple(context),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 0),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(Icons.apple, size: 24),
          label: Text(
            type == AuthType.signIn
                ? 'Sign in with Apple'
                : 'Sign up with Apple',
            style: context.theme.typography.sm.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}

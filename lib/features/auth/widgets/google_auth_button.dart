import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:learn_work/features/auth/utils/auth_type.dart';
import 'package:learn_work/screens/student_screens/main_screen.dart';
import 'package:learn_work/features/auth/providers/auth_provider.dart';

class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({super.key, this.type});
  final AuthType? type;

  Future<void> _signInWithGoogle(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithGoogle();

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed in with Google!'),
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
              authProvider.isLoading ? null : () => _signInWithGoogle(context),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 0),
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey.shade600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Brand(Brands.google, size: 20),
          label: Text(
            type == AuthType.signIn
                ? 'Sign in with Google'
                : 'Sign up with Google',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        );
      },
    );
  }
}

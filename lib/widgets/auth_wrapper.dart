import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:learn_work/screens/main_screen.dart';
import 'package:learn_work/screens/welcome_screen.dart';
import 'package:learn_work/screens/email_verification_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Firebase not initialized'),
            ],
          ),
        ),
      );
    }

    // Firebase is initialized, check auth state
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authSnapshot.hasData && authSnapshot.data != null) {
          // User is signed in
          final user = authSnapshot.data!;
          
          // Check if email is verified
          if (user.emailVerified) {
            return const MainScreen();
          } else {
            // Email not verified, show verification screen
            return const EmailVerificationScreen();
          }
        }

        // User is not signed in
        return const WelcomeScreen();
      },
    );
  }
}

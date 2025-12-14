import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_work/screens/student_screens/main_screen.dart';
import 'package:learn_work/features/onboarding/welcome_screen.dart';
import 'package:learn_work/screens/student_screens/email_verification_screen.dart';
import 'package:learn_work/screens/admin_screen/dashboard_screen.dart';
import 'package:learn_work/providers/admin_provider.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _currentUser;
  Future<DocumentSnapshot>? _userProfileFuture;

  @override
  Widget build(BuildContext context) {
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

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;

        // If user changed (logged in, logged out, or switched user), update our cache
        if (user?.uid != _currentUser?.uid) {
          _currentUser = user;
          if (user != null) {
            print(
              '🔐 AuthWrapper: User changed to ${user.uid}, fetching profile...',
            );
            _userProfileFuture =
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get();
          } else {
            _userProfileFuture = null;
          }
        }

        if (user != null && _userProfileFuture != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: _userProfileFuture,
            builder: (context, userDocSnapshot) {
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                // Only show loading if we don't have data yet?
                // Actually, for a *new* user login, we want to show loading.
                // But this FutureBuilder will preserve its state if the Future instance is the same!
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userDocSnapshot.hasError) {
                print(
                  '🔐 AuthWrapper: Error loading user data: ${userDocSnapshot.error}',
                );
                FirebaseAuth.instance.signOut();
                return const WelcomeScreen();
              }

              if (userDocSnapshot.hasData && userDocSnapshot.data!.exists) {
                final userData =
                    userDocSnapshot.data!.data() as Map<String, dynamic>;
                final userRole = userData['role'] as String?;

                if (userRole == 'Admin') {
                  return const DashboardScreen();
                } else if (userRole == 'Student') {
                  if (user.emailVerified) {
                    return const MainScreen();
                  } else {
                    return const EmailVerificationScreen();
                  }
                } else {
                  FirebaseAuth.instance.signOut();
                  return const WelcomeScreen();
                }
              } else {
                FirebaseAuth.instance.signOut();
                return const WelcomeScreen();
              }
            },
          );
        }

        return const WelcomeScreen();
      },
    );
  }
}

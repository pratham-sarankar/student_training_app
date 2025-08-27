import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_work/screens/student_screens/main_screen.dart';
import 'package:learn_work/screens/student_screens/welcome_screen.dart';
import 'package:learn_work/screens/student_screens/email_verification_screen.dart';
import 'package:learn_work/screens/admin_screen/dashboard_screen.dart';
import 'package:learn_work/providers/admin_provider.dart';
import 'package:provider/provider.dart';

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
          // User is signed in, check their role
          final user = authSnapshot.data!;
          print('🔐 AuthWrapper: User signed in with UID: ${user.uid}');
          
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, userDocSnapshot) {
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                print('🔐 AuthWrapper: Loading user data...');
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (userDocSnapshot.hasError) {
                print('🔐 AuthWrapper: Error loading user data: ${userDocSnapshot.error}');
                // If there's an error loading user data, sign out and show welcome
                FirebaseAuth.instance.signOut();
                return const WelcomeScreen();
              }

              if (userDocSnapshot.hasData && userDocSnapshot.data!.exists) {
                final userData = userDocSnapshot.data!.data() as Map<String, dynamic>;
                final userRole = userData['role'] as String?;
                
                print('🔐 AuthWrapper: User role: $userRole');

                if (userRole == 'Admin') {
                  print('🔐 AuthWrapper: Routing to admin dashboard');
                  // User is admin, show admin dashboard
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider<AdminProvider>(
                        create: (context) => AdminProvider(),
                        lazy: false, // Create immediately to avoid disposal issues
                      ),
                    ],
                    child: const DashboardScreen(),
                  );
                } else if (userRole == 'Student') {
                  print('🔐 AuthWrapper: Routing to student screen');
                  // User is student, check email verification
                  if (user.emailVerified) {
                    return const MainScreen();
                  } else {
                    return const EmailVerificationScreen();
                  }
                } else {
                  print('🔐 AuthWrapper: Unknown role, signing out');
                  // Unknown role, sign out and show welcome
                  FirebaseAuth.instance.signOut();
                  return const WelcomeScreen();
                }
              } else {
                print('🔐 AuthWrapper: User document doesn\'t exist, signing out');
                // User document doesn't exist, sign out and show welcome
                FirebaseAuth.instance.signOut();
                return const WelcomeScreen();
              }
            },
          );
        }

        // User is not signed in
        return const WelcomeScreen();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Learn Work',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            fontFamily: GoogleFonts.inter().fontFamily,
            textTheme: GoogleFonts.interTextTheme().copyWith(
              displayLarge: GoogleFonts.inter(
                fontSize: 57,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.25,
                height: 1.12,
              ),
              displayMedium: GoogleFonts.inter(
                fontSize: 45,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                height: 1.16,
              ),
              displaySmall: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                height: 1.22,
              ),
              headlineLarge: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                height: 1.25,
              ),
              headlineMedium: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                height: 1.29,
              ),
              headlineSmall: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                height: 1.33,
              ),
              titleLarge: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                height: 1.27,
              ),
              titleMedium: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.15,
                height: 1.5,
              ),
              titleSmall: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
                height: 1.43,
              ),
              bodyLarge: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
                height: 1.5,
              ),
              bodyMedium: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.25,
                height: 1.43,
              ),
              bodySmall: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.4,
                height: 1.33,
              ),
              labelLarge: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
                height: 1.43,
              ),
              labelMedium: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                height: 1.33,
              ),
              labelSmall: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                height: 1.45,
              ),
            ),
          ),
          home: const AuthWrapper(),
        );
      },
    );
  }
}

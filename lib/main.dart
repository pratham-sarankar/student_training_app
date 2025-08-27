import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui/widgets/scaffold.dart';
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
    final theme = FThemes.zinc.light;
    return FTheme(
      data: theme,
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            theme: theme.toApproximateMaterialTheme(),
            title: 'Learn Work',
            debugShowCheckedModeBanner: false,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learn_work/core/theme/theme.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'widgets/splash_screen.dart';
import 'utils/custom_theme.dart';
import 'utils/service_locator.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Setup service locator (Dependency Injection)
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MaterialTheme(GoogleFonts.poppinsTextTheme());
    return ChangeNotifierProvider(
      create: (_) => getIt<AuthProvider>(),
      child: MaterialApp(
        theme: theme.light(),
        darkTheme: theme.dark(),
        title: 'Gradspark',
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}

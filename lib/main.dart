import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'widgets/splash_screen.dart';
import 'utils/custom_theme.dart';
import 'utils/service_locator.dart';
import 'features/auth/providers/auth_provider.dart';
import 'providers/admin_provider.dart';

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

  // Setup service locator (Dependency Injection)
  await setupServiceLocator();
  print('Service locator initialized successfully');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemes.navy.light;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: FTheme(
        data: theme,
        child: MaterialApp(
          theme: theme.toApproximateMaterialTheme(),
          title: 'Gradspark',
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

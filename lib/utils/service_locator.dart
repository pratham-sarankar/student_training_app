import 'package:get_it/get_it.dart';
import '../features/auth/services/auth_service.dart';
import '../features/auth/providers/auth_provider.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register AuthService as a lazy singleton
  // This means only one instance will be created and reused throughout the app
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // Register AuthProvider as a lazy singleton
  // AuthProvider depends on AuthService
  getIt.registerLazySingleton<AuthProvider>(
    () => AuthProvider(getIt<AuthService>()),
  );

  // Add other services here as needed in the future
  // Example:
  // getIt.registerLazySingleton<UserService>(() => UserService());
  // getIt.registerLazySingleton<JobService>(() => JobService());
}

import 'package:get_it/get_it.dart';
import '../features/auth/services/auth_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register AuthService as a lazy singleton
  // This means only one instance will be created and reused throughout the app
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // Add other services here as needed in the future
  // Example:
  // getIt.registerLazySingleton<UserService>(() => UserService());
  // getIt.registerLazySingleton<JobService>(() => JobService());
}

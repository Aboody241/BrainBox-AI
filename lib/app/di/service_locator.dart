import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/viewmodels/auth_view_model.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Centralized Dependency Injection Setup
abstract final class ServiceLocator {
  static Future<void> init() async {
    await _initCore();
    await _initAuth();
    await _initConversations();
    await _initChat();
    await _initSettings();
  }

  /// Core infrastructure dependencies
  static Future<void> _initCore() async {
    // Will register Drift AppDatabase, Dio Network Client, etc.
  }

  /// Authentication feature dependencies
  static Future<void> _initAuth() async {
    // DataSources
    sl.registerLazySingleton<AuthLocalDataSource>(
      () => InMemoryAuthLocalDataSource(),
    );
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => MockAuthRemoteDataSource(),
    );

    // Repository
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
      ),
    );

    // UseCases
    sl.registerLazySingleton(() => LoginUseCase(sl()));
    sl.registerLazySingleton(() => RegisterUseCase(sl()));
    sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
    sl.registerLazySingleton(() => LogoutUseCase(sl()));

    // ViewModel
    sl.registerLazySingleton(
      () => AuthViewModel(
        loginUseCase: sl(),
        registerUseCase: sl(),
        getCurrentUserUseCase: sl(),
        logoutUseCase: sl(),
      ),
    );
  }

  /// Conversations feature dependencies
  static Future<void> _initConversations() async {}

  /// Chat feature dependencies
  static Future<void> _initChat() async {}

  /// Settings feature dependencies
  static Future<void> _initSettings() async {}

  /// Helper method to reset registrations during automated unit/widget testing
  static Future<void> reset() async {
    await sl.reset();
  }
}

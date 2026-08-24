import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/viewmodels/auth_view_model.dart';
import '../../features/chat/data/datasources/gemini_remote_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/send_chat_message_usecase.dart';
import '../../features/chat/domain/usecases/stream_chat_response_usecase.dart';
import '../../features/conversations/data/datasources/conversation_local_data_source.dart';
import '../../features/conversations/data/repositories/conversation_repository_impl.dart';
import '../../features/conversations/domain/repositories/conversation_repository.dart';
import '../../features/conversations/domain/usecases/delete_conversation_usecase.dart';
import '../../features/conversations/domain/usecases/get_chat_history_usecase.dart';
import '../../features/conversations/domain/usecases/get_conversations_usecase.dart';
import '../../features/conversations/domain/usecases/rename_conversation_usecase.dart';
import '../../features/conversations/domain/usecases/save_chat_history_usecase.dart';
import '../../features/conversations/domain/usecases/save_conversation_usecase.dart';
import '../../features/conversations/domain/usecases/toggle_pin_conversation_usecase.dart';

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
    if (!sl.isRegistered<SharedPreferences>()) {
      final prefs = await SharedPreferences.getInstance();
      sl.registerSingleton<SharedPreferences>(prefs);
    }
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

  /// Conversations feature dependencies & local caching
  static Future<void> _initConversations() async {
    // DataSource
    sl.registerLazySingleton<ConversationLocalDataSource>(
      () => ConversationLocalDataSourceImpl(sl()),
    );

    // Repository
    sl.registerLazySingleton<ConversationRepository>(
      () => ConversationRepositoryImpl(sl()),
    );

    // UseCases
    sl.registerLazySingleton(() => GetConversationsUseCase(sl()));
    sl.registerLazySingleton(() => SaveConversationUseCase(sl()));
    sl.registerLazySingleton(() => DeleteConversationUseCase(sl()));
    sl.registerLazySingleton(() => TogglePinConversationUseCase(sl()));
    sl.registerLazySingleton(() => RenameConversationUseCase(sl()));
    sl.registerLazySingleton(() => GetChatHistoryUseCase(sl()));
    sl.registerLazySingleton(() => SaveChatHistoryUseCase(sl()));
  }

  /// Chat feature dependencies
  static Future<void> _initChat() async {
    // DataSource
    sl.registerLazySingleton<GeminiRemoteDataSource>(
      () => GeminiRemoteDataSourceImpl(),
    );

    // Repository
    sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(sl()),
    );

    // UseCases
    sl.registerLazySingleton(() => StreamChatResponseUseCase(sl()));
    sl.registerLazySingleton(() => SendChatMessageUseCase(sl()));
  }

  /// Settings feature dependencies
  static Future<void> _initSettings() async {}

  /// Helper method to reset registrations during automated unit/widget testing
  static Future<void> reset() async {
    await sl.reset();
  }
}

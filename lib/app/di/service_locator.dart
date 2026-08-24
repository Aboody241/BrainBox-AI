import 'package:get_it/get_it.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Centralized Dependency Injection Setup
///
/// Initializes and registers all application dependencies organized by layer
/// and feature following Clean Architecture boundaries.
abstract final class ServiceLocator {
  static Future<void> init() async {
    await _initCore();
    await _initAuth();
    await _initConversations();
    await _initChat();
    await _initSettings();
  }

  /// Core infrastructure dependencies (Database, Network, Utilities)
  static Future<void> _initCore() async {
    // Will register Drift AppDatabase, Dio Network Client, SecureStorage, etc.
  }

  /// Authentication feature dependencies
  static Future<void> _initAuth() async {
    // Will register DataSources, AuthRepository, UseCases, AuthViewModel
  }

  /// Conversations feature dependencies
  static Future<void> _initConversations() async {
    // Will register ConversationLocalDataSource, ConversationRepository, UseCases, ConversationViewModel
  }

  /// Chat feature dependencies
  static Future<void> _initChat() async {
    // Will register GeminiRemoteDataSource, ChatRepository, SendMessage, ChatViewModel
  }

  /// Settings feature dependencies
  static Future<void> _initSettings() async {
    // Will register SettingsDataSource, SettingsRepository, UseCases, SettingsViewModel
  }

  /// Helper method to reset registrations during automated unit/widget testing
  static Future<void> reset() async {
    await sl.reset();
  }
}

abstract final class AppConstants {
  // Storage Keys
  static const String themePreferenceKey = 'app_theme_mode';
  static const String activeConversationKey = 'active_conversation_id';
  static const String userSessionKey = 'user_session_token';
  static const String selectedModelKey = 'selected_ai_model';

  // Chat UI & Streaming Constraints
  static const int maxMessageLength = 4000;
  static const int recentConversationsLimit = 50;
  static const Duration streamDebounceDuration = Duration(milliseconds: 50);

  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration quickAnimationDuration = Duration(milliseconds: 150);
}

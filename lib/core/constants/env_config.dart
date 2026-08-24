enum AppEnvironment {
  dev,
  staging,
  prod,
}

/// Centralized environment configuration and build-time variables.
///
/// In production, secrets like API keys MUST be provided at compile-time via
/// `--dart-define` or `--dart-define-from-file` to prevent committing secrets to source control.
abstract final class EnvConfig {
  static const String appName = 'BrainBox AI';
  static const String appVersion = '1.0.0';

  // Environment Mode
  static const String _envName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static AppEnvironment get environment => switch (_envName.toLowerCase()) {
        'prod' || 'production' => AppEnvironment.prod,
        'staging' => AppEnvironment.staging,
        _ => AppEnvironment.dev,
      };

  static bool get isProduction => environment == AppEnvironment.prod;
  static bool get isDevelopment => environment == AppEnvironment.dev;
  static bool get isStaging => environment == AppEnvironment.staging;

  // Gemini & Remote API Configuration
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static const String geminiBaseUrl = String.fromEnvironment(
    'GEMINI_BASE_URL',
    defaultValue: 'https://generativelanguage.googleapis.com',
  );

  static const String defaultAiModel = String.fromEnvironment(
    'GEMINI_DEFAULT_MODEL',
    defaultValue: 'gemini-1.5-flash',
  );

  // Network Timeouts (in milliseconds)
  static const int connectTimeoutMs = int.fromEnvironment(
    'CONNECT_TIMEOUT_MS',
    defaultValue: 30000,
  );

  static const int receiveTimeoutMs = int.fromEnvironment(
    'RECEIVE_TIMEOUT_MS',
    defaultValue: 60000,
  );

  // Persistence Configuration
  static const String databaseName = String.fromEnvironment(
    'DATABASE_NAME',
    defaultValue: 'brain_box_ai.sqlite',
  );
}

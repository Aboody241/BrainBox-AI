import 'package:brain_box_ai/core/constants/app_constants.dart';
import 'package:brain_box_ai/core/constants/env_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EnvConfig & AppConstants', () {
    test('EnvConfig has expected defaults', () {
      expect(EnvConfig.appName, equals('BrainBox AI'));
      expect(EnvConfig.environment, equals(AppEnvironment.dev));
      expect(EnvConfig.isDevelopment, isTrue);
      expect(EnvConfig.isProduction, isFalse);
      expect(EnvConfig.geminiBaseUrl, contains('generativelanguage.googleapis.com'));
      expect(EnvConfig.defaultAiModel, equals('gemini-1.5-flash'));
      expect(EnvConfig.databaseName, equals('brain_box_ai.sqlite'));
    });

    test('AppConstants provides valid constraints', () {
      expect(AppConstants.maxMessageLength, equals(4000));
      expect(AppConstants.recentConversationsLimit, equals(50));
      expect(AppConstants.defaultAnimationDuration.inMilliseconds, equals(300));
    });
  });
}

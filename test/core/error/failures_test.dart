import 'package:brain_box_ai/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure Models', () {
    test('NetworkFailure supports equality and default message', () {
      const failure1 = NetworkFailure();
      const failure2 = NetworkFailure();

      expect(failure1, equals(failure2));
      expect(failure1.message, contains('No internet connection'));
      expect(failure1.hashCode, equals(failure2.hashCode));
    });

    test('ServerFailure holds message and optional status code', () {
      const failure = ServerFailure(message: 'Internal Error', code: 500);

      expect(failure.message, equals('Internal Error'));
      expect(failure.code, equals(500));
    });

    test('RateLimitFailure holds optional retryAfter duration', () {
      const duration = Duration(seconds: 30);
      const failure1 = RateLimitFailure(retryAfter: duration);
      const failure2 = RateLimitFailure(retryAfter: duration);
      const failure3 = RateLimitFailure(retryAfter: Duration(seconds: 60));

      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
      expect(failure1.retryAfter, equals(duration));
    });

    test('Different failure types are not equal even with same message', () {
      const failure1 = ServerFailure(message: 'Error');
      const failure2 = UnknownFailure(message: 'Error');

      expect(failure1, isNot(equals(failure2)));
    });
  });
}

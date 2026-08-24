import 'package:brain_box_ai/core/error/failures.dart';
import 'package:brain_box_ai/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result Monad', () {
    test('Success holds data and returns true for isSuccess', () {
      const result = Result.success('Hello AI');

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, equals('Hello AI'));
      expect(result.failureOrNull, isNull);
      expect(result.getOrElse((_) => 'fallback'), equals('Hello AI'));
    });

    test('Error holds failure and returns true for isFailure', () {
      const failure = NetworkFailure();
      const result = Result<String>.failure(failure);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, equals(failure));
      expect(result.getOrElse((f) => f.message), equals(failure.message));
    });

    test('when executes success branch for Success and failure branch for Error', () {
      const successResult = Result.success(42);
      const errorResult = Result<int>.failure(ServerFailure());

      final successOutput = successResult.when(
        success: (data) => 'Value: $data',
        failure: (f) => 'Failed: ${f.message}',
      );

      final errorOutput = errorResult.when(
        success: (data) => 'Value: $data',
        failure: (f) => 'Failed: ${f.message}',
      );

      expect(successOutput, equals('Value: 42'));
      expect(errorOutput, contains('Failed:'));
    });

    test('map transforms value on Success and passes Failure on Error', () {
      const successResult = Result.success(10);
      const errorResult = Result<int>.failure(TimeoutFailure());

      final mappedSuccess = successResult.map((v) => v * 2);
      final mappedError = errorResult.map((v) => v * 2);

      expect(mappedSuccess, equals(const Result.success(20)));
      expect(mappedError.isFailure, isTrue);
    });

    test('flatMap chains another Result on Success', () {
      const successResult = Result.success('user-123');

      final chainedSuccess = successResult.flatMap((id) => Result.success('Profile: $id'));
      final chainedFailure = successResult.flatMap((_) => const Result<String>.failure(DatabaseFailure()));

      expect(chainedSuccess, equals(const Result.success('Profile: user-123')));
      expect(chainedFailure.isFailure, isTrue);
    });

    test('asyncMap transforms value asynchronously', () async {
      const successResult = Result.success('data');
      final result = await successResult.asyncMap((v) async => v.toUpperCase());

      expect(result, equals(const Result.success('DATA')));
    });

    test('asyncFlatMap chains asynchronous Result computation', () async {
      const successResult = Result.success(5);
      final result = await successResult.asyncFlatMap((v) async => Result.success(v * 10));

      expect(result, equals(const Result.success(50)));
    });
  });
}

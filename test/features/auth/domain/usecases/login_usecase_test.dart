import 'package:brain_box_ai/core/error/failures.dart';
import 'package:brain_box_ai/core/result/result.dart';
import 'package:brain_box_ai/features/auth/domain/entities/user.dart';
import 'package:brain_box_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:brain_box_ai/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    if (email == 'valid@example.com' && password == 'password123') {
      return const Result.success(
        User(
          id: 'usr_1',
          username: 'validuser',
          email: 'valid@example.com',
          password: 'password123',
          isLoggedIn: true,
        ),
      );
    }
    return const Result.failure(
      AuthenticationFailure(message: 'Invalid credentials'),
    );
  }

  @override
  Future<Result<User>> register({
    required String username,
    required String email,
    required String password,
    String? image,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> logout() async {
    throw UnimplementedError();
  }
}

void main() {
  late LoginUseCase loginUseCase;
  late FakeAuthRepository repository;

  setUp(() {
    repository = FakeAuthRepository();
    loginUseCase = LoginUseCase(repository);
  });

  group('LoginUseCase Unit Tests', () {
    test('returns User on valid credentials', () async {
      final result = await loginUseCase(
        email: 'valid@example.com',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.email, equals('valid@example.com'));
    });

    test('returns Failure on invalid credentials', () async {
      final result = await loginUseCase(
        email: 'invalid@example.com',
        password: 'wrong',
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.message, equals('Invalid credentials'));
    });
  });
}

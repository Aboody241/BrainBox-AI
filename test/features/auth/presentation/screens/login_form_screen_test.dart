import 'package:brain_box_ai/app/di/service_locator.dart';
import 'package:brain_box_ai/core/result/result.dart';
import 'package:brain_box_ai/features/auth/domain/entities/user.dart';
import 'package:brain_box_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:brain_box_ai/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:brain_box_ai/features/auth/domain/usecases/login_usecase.dart';
import 'package:brain_box_ai/features/auth/domain/usecases/logout_usecase.dart';
import 'package:brain_box_ai/features/auth/domain/usecases/register_usecase.dart';
import 'package:brain_box_ai/features/auth/presentation/screens/login_form_screen.dart';
import 'package:brain_box_ai/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockRepo implements AuthRepository {
  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    return const Result.success(
      User(
        id: '1',
        username: 'test',
        email: 'test@example.com',
        password: 'password123',
      ),
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
    return const Result.success(null);
  }

  @override
  Future<Result<void>> logout() async {
    return const Result.success(null);
  }
}

void main() {
  setUp(() async {
    await ServiceLocator.reset();
    final repo = MockRepo();
    sl.registerLazySingleton(
      () => AuthViewModel(
        loginUseCase: LoginUseCase(repo),
        registerUseCase: RegisterUseCase(repo),
        getCurrentUserUseCase: GetCurrentUserUseCase(repo),
        logoutUseCase: LogoutUseCase(repo),
      ),
    );
  });

  group('LoginFormScreen Widget Tests', () {
    testWidgets('renders welcome back title and form inputs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginFormScreen(),
        ),
      );

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });
  });
}

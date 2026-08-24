import 'package:brain_box_ai/core/result/result.dart';
import 'package:brain_box_ai/features/auth/domain/entities/user.dart';
import 'package:brain_box_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:brain_box_ai/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:brain_box_ai/features/auth/domain/usecases/login_usecase.dart';
import 'package:brain_box_ai/features/auth/domain/usecases/logout_usecase.dart';
import 'package:brain_box_ai/features/auth/domain/usecases/register_usecase.dart';
import 'package:brain_box_ai/features/auth/presentation/viewmodels/auth_state.dart';
import 'package:brain_box_ai/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthRepo implements AuthRepository {
  User? savedUser;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    savedUser = User(
      id: 'usr_123',
      username: 'test',
      email: email,
      password: password,
      isLoggedIn: true,
    );
    return Result.success(savedUser!);
  }

  @override
  Future<Result<User>> register({
    required String username,
    required String email,
    required String password,
    String? image,
  }) async {
    savedUser = User(
      id: 'usr_123',
      username: username,
      email: email,
      password: password,
      image: image,
      isLoggedIn: true,
    );
    return Result.success(savedUser!);
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    return Result.success(savedUser);
  }

  @override
  Future<Result<void>> logout() async {
    savedUser = null;
    return const Result.success(null);
  }
}

void main() {
  late AuthViewModel viewModel;
  late MockAuthRepo repo;

  setUp(() {
    repo = MockAuthRepo();
    viewModel = AuthViewModel(
      loginUseCase: LoginUseCase(repo),
      registerUseCase: RegisterUseCase(repo),
      getCurrentUserUseCase: GetCurrentUserUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
    );
  });

  group('AuthViewModel State Tests', () {
    test('initial state is AuthInitial', () {
      expect(viewModel.state, isA<AuthInitial>());
    });

    test('login updates state to AuthAuthenticated on success', () async {
      final success = await viewModel.login('test@example.com', 'password123');

      expect(success, isTrue);
      expect(viewModel.state, isA<AuthAuthenticated>());
      expect(viewModel.currentUser?.email, equals('test@example.com'));
    });

    test('logout updates state to AuthUnauthenticated', () async {
      await viewModel.login('test@example.com', 'password123');
      await viewModel.logout();

      expect(viewModel.state, isA<AuthUnauthenticated>());
      expect(viewModel.currentUser, isNull);
    });
  });
}

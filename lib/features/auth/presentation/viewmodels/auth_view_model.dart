import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;

  AuthState _state = const AuthInitial();
  AuthState get state => _state;

  User? _currentUser;
  User? get currentUser => _currentUser;

  AuthViewModel({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
  });

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _setState(const AuthLoading());
    final result = await getCurrentUserUseCase();
    result.when(
      success: (user) {
        if (user != null && user.isLoggedIn) {
          _currentUser = user;
          _setState(AuthAuthenticated(user));
        } else {
          _currentUser = null;
          _setState(const AuthUnauthenticated());
        }
      },
      failure: (failure) {
        _currentUser = null;
        _setState(AuthError(failure.message));
      },
    );
  }

  Future<bool> login(String email, String password) async {
    _setState(const AuthLoading());
    final result = await loginUseCase(email: email, password: password);
    return result.when(
      success: (user) {
        _currentUser = user;
        _setState(AuthAuthenticated(user));
        return true;
      },
      failure: (failure) {
        _setState(AuthError(failure.message));
        return false;
      },
    );
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? image,
  }) async {
    _setState(const AuthLoading());
    final result = await registerUseCase(
      username: username,
      email: email,
      password: password,
      image: image,
    );
    return result.when(
      success: (user) {
        _currentUser = user;
        _setState(AuthAuthenticated(user));
        return true;
      },
      failure: (failure) {
        _setState(AuthError(failure.message));
        return false;
      },
    );
  }

  Future<void> logout() async {
    _setState(const AuthLoading());
    final result = await logoutUseCase();
    result.when(
      success: (_) {
        _currentUser = null;
        _setState(const AuthUnauthenticated());
      },
      failure: (failure) {
        _setState(AuthError(failure.message));
      },
    );
  }
}

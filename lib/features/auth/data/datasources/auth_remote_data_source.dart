import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    String? image,
  });
}

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (password.length < 6) {
      throw const AuthException(
        message: 'Password must be at least 6 characters.',
      );
    }

    return UserModel(
      id: 'usr_${email.hashCode}',
      username: email.split('@').first,
      email: email,
      password: password,
      image: 'https://i.pravatar.cc/150?u=$email',
      createdAt: DateTime.now(),
      isLoggedIn: true,
    );
  }

  @override
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    String? image,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (password.length < 6) {
      throw const AuthException(
        message: 'Password must be at least 6 characters.',
      );
    }

    return UserModel(
      id: 'usr_${email.hashCode}',
      username: username,
      email: email,
      password: password,
      image: image ?? 'https://i.pravatar.cc/150?u=$email',
      createdAt: DateTime.now(),
      isLoggedIn: true,
    );
  }
}

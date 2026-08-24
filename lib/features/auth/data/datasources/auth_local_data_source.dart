import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getSavedUser();
  Future<void> saveUser(UserModel user);
  Future<void> clearSession();
}

class InMemoryAuthLocalDataSource implements AuthLocalDataSource {
  UserModel? _cachedUser;

  @override
  Future<UserModel?> getSavedUser() async {
    return _cachedUser;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    _cachedUser = UserModel.fromEntity(
      user.copyWith(isLoggedIn: true),
    );
  }

  @override
  Future<void> clearSession() async {
    _cachedUser = null;
  }
}

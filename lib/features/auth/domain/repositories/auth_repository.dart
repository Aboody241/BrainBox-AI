import '../../../../core/result/result.dart';
import '../entities/user.dart';

/// Contract interface for Auth operations.
abstract class AuthRepository {
  Future<Result<User>> login({
    required String email,
    required String password,
  });

  Future<Result<User>> register({
    required String username,
    required String email,
    required String password,
    String? image,
  });

  Future<Result<User?>> getCurrentUser();

  Future<Result<void>> logout();
}

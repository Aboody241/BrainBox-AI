import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      await localDataSource.saveUser(userModel);
      return Result.success(userModel.toEntity());
    } on AppException catch (e) {
      return Result.failure(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Result.failure(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> register({
    required String username,
    required String email,
    required String password,
    String? image,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        username: username,
        email: email,
        password: password,
        image: image,
      );
      await localDataSource.saveUser(userModel);
      return Result.success(userModel.toEntity());
    } on AppException catch (e) {
      return Result.failure(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Result.failure(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final savedModel = await localDataSource.getSavedUser();
      return Result.success(savedModel?.toEntity());
    } catch (e) {
      return Result.failure(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await localDataSource.clearSession();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure(message: e.toString()));
    }
  }
}

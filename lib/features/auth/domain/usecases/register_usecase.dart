import '../../../../core/result/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  Future<Result<User>> call({
    required String username,
    required String email,
    required String password,
    String? image,
  }) {
    return repository.register(
      username: username,
      email: email,
      password: password,
      image: image,
    );
  }
}

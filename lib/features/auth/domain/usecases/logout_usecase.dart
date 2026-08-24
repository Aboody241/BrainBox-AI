import '../../../../core/result/result.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  Future<Result<void>> call() {
    return repository.logout();
  }
}

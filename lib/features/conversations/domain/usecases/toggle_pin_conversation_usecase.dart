import '../../../../core/result/result.dart';
import '../repositories/conversation_repository.dart';

class TogglePinConversationUseCase {
  final ConversationRepository _repository;

  const TogglePinConversationUseCase(this._repository);

  Future<Result<bool>> call(String id) {
    return _repository.togglePin(id);
  }
}

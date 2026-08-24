import '../../../../core/result/result.dart';
import '../repositories/conversation_repository.dart';

class DeleteConversationUseCase {
  final ConversationRepository _repository;

  const DeleteConversationUseCase(this._repository);

  Future<Result<void>> call(String id) {
    return _repository.deleteConversation(id);
  }
}

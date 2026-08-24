import '../../../../core/result/result.dart';
import '../repositories/conversation_repository.dart';

class RenameConversationUseCase {
  final ConversationRepository _repository;

  const RenameConversationUseCase(this._repository);

  Future<Result<void>> call(String id, String newTitle) {
    return _repository.renameConversation(id, newTitle);
  }
}

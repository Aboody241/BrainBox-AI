import '../../../../core/result/result.dart';
import '../entities/conversation.dart';
import '../repositories/conversation_repository.dart';

class SaveConversationUseCase {
  final ConversationRepository _repository;

  const SaveConversationUseCase(this._repository);

  Future<Result<void>> call(Conversation conversation) {
    return _repository.saveConversation(conversation);
  }
}

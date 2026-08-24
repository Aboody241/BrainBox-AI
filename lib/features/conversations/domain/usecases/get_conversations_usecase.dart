import '../../../../core/result/result.dart';
import '../entities/conversation.dart';
import '../repositories/conversation_repository.dart';

class GetConversationsUseCase {
  final ConversationRepository _repository;

  const GetConversationsUseCase(this._repository);

  Future<Result<List<Conversation>>> call() {
    return _repository.getConversations();
  }
}

import '../../../../core/result/result.dart';
import '../../../chat/domain/entities/chat_message.dart';
import '../repositories/conversation_repository.dart';

class GetChatHistoryUseCase {
  final ConversationRepository _repository;

  const GetChatHistoryUseCase(this._repository);

  Future<Result<List<ChatMessage>>> call(String conversationId) {
    return _repository.getMessages(conversationId);
  }
}

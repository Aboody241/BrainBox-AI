import '../../../../core/result/result.dart';
import '../../../chat/domain/entities/chat_message.dart';
import '../repositories/conversation_repository.dart';

class SaveChatHistoryUseCase {
  final ConversationRepository _repository;

  const SaveChatHistoryUseCase(this._repository);

  Future<Result<void>> call(
    String conversationId,
    List<ChatMessage> messages,
  ) {
    return _repository.saveMessages(conversationId, messages);
  }
}

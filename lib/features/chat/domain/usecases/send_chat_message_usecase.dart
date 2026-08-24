import '../../../../core/result/result.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

/// Use case that generates a complete AI response non-streamed.
class SendChatMessageUseCase {
  final ChatRepository _repository;

  const SendChatMessageUseCase(this._repository);

  Future<Result<String>> call(
    String prompt, {
    List<ChatMessage> history = const [],
    String? model,
  }) {
    return _repository.sendMessage(
      prompt,
      history: history,
      model: model,
    );
  }
}

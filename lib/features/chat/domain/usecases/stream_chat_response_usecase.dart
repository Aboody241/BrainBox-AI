import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

/// Use case that streams live AI response chunks from the Gemini API.
class StreamChatResponseUseCase {
  final ChatRepository _repository;

  const StreamChatResponseUseCase(this._repository);

  Stream<String> call(
    String prompt, {
    List<ChatMessage> history = const [],
    String? model,
  }) {
    return _repository.streamMessage(
      prompt,
      history: history,
      model: model,
    );
  }
}

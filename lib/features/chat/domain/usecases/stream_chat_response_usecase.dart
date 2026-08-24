import 'dart:typed_data';

import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

/// Use case that streams live AI response chunks from the Gemini API with optional multimodal image input.
class StreamChatResponseUseCase {
  final ChatRepository _repository;

  const StreamChatResponseUseCase(this._repository);

  Stream<String> call(
    String prompt, {
    List<ChatMessage> history = const [],
    Uint8List? imageBytes,
    String? mimeType,
    String? model,
  }) {
    return _repository.streamMessage(
      prompt,
      history: history,
      imageBytes: imageBytes,
      mimeType: mimeType,
      model: model,
    );
  }
}

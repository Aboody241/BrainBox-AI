import 'dart:typed_data';

import '../../../../core/result/result.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

/// Use case that generates a complete AI response non-streamed with optional multimodal image input.
class SendChatMessageUseCase {
  final ChatRepository _repository;

  const SendChatMessageUseCase(this._repository);

  Future<Result<String>> call(
    String prompt, {
    List<ChatMessage> history = const [],
    Uint8List? imageBytes,
    String? mimeType,
    String? model,
  }) {
    return _repository.sendMessage(
      prompt,
      history: history,
      imageBytes: imageBytes,
      mimeType: mimeType,
      model: model,
    );
  }
}

import 'dart:typed_data';

import '../../../../core/result/result.dart';
import '../entities/chat_message.dart';

/// Contract for AI Chat operations, streaming, and multimodal vision.
abstract interface class ChatRepository {
  /// Streams Gemini AI token chunks in real-time for the given user prompt, optional image, and message history.
  Stream<String> streamMessage(
    String prompt, {
    List<ChatMessage> history = const [],
    Uint8List? imageBytes,
    String? mimeType,
    String? model,
  });

  /// Sends a one-shot prompt and optional image, returning the complete text response.
  Future<Result<String>> sendMessage(
    String prompt, {
    List<ChatMessage> history = const [],
    Uint8List? imageBytes,
    String? mimeType,
    String? model,
  });
}

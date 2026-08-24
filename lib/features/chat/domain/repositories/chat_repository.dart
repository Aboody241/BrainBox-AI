import '../../../../core/result/result.dart';
import '../entities/chat_message.dart';

/// Contract for AI Chat operations and streaming.
abstract interface class ChatRepository {
  /// Streams Gemini AI token chunks in real-time for the given user prompt and message history.
  Stream<String> streamMessage(
    String prompt, {
    List<ChatMessage> history = const [],
    String? model,
  });

  /// Sends a one-shot prompt and returns the complete text response.
  Future<Result<String>> sendMessage(
    String prompt, {
    List<ChatMessage> history = const [],
    String? model,
  });
}

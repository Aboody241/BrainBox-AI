import '../../../../core/result/result.dart';
import '../../../chat/domain/entities/chat_message.dart';
import '../entities/conversation.dart';

/// Contract for conversations and chat history persistence.
abstract interface class ConversationRepository {
  /// Fetches all stored conversations sorted by pinned first, then by updatedAt descending.
  Future<Result<List<Conversation>>> getConversations();

  /// Saves or updates a conversation metadata.
  Future<Result<void>> saveConversation(Conversation conversation);

  /// Deletes a conversation and its messages.
  Future<Result<void>> deleteConversation(String id);

  /// Toggles pinned status for a conversation.
  Future<Result<bool>> togglePin(String id);

  /// Renames a conversation title.
  Future<Result<void>> renameConversation(String id, String newTitle);

  /// Fetches the message history for a given conversation.
  Future<Result<List<ChatMessage>>> getMessages(String conversationId);

  /// Saves the message history for a given conversation.
  Future<Result<void>> saveMessages(
    String conversationId,
    List<ChatMessage> messages,
  );

  /// Clears message history for a conversation.
  Future<Result<void>> clearMessages(String conversationId);
}

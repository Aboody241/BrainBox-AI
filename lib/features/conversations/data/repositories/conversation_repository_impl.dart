import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../chat/data/models/chat_message_model.dart';
import '../../../chat/domain/entities/chat_message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../datasources/conversation_local_data_source.dart';
import '../models/conversation_model.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationLocalDataSource _localDataSource;

  const ConversationRepositoryImpl(this._localDataSource);

  @override
  Future<Result<List<Conversation>>> getConversations() async {
    try {
      final list = await _localDataSource.getConversations();
      return Result.success(list);
    } catch (e) {
      return Result.failure(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> saveConversation(Conversation conversation) async {
    try {
      await _localDataSource.saveConversation(
        ConversationModel.fromEntity(conversation),
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteConversation(String id) async {
    try {
      await _localDataSource.deleteConversation(id);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> togglePin(String id) async {
    try {
      final isPinned = await _localDataSource.togglePin(id);
      return Result.success(isPinned);
    } catch (e) {
      return Result.failure(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> renameConversation(String id, String newTitle) async {
    try {
      await _localDataSource.renameConversation(id, newTitle);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<ChatMessage>>> getMessages(String conversationId) async {
    try {
      final list = await _localDataSource.getMessages(conversationId);
      return Result.success(list);
    } catch (e) {
      return Result.failure(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> saveMessages(
    String conversationId,
    List<ChatMessage> messages,
  ) async {
    try {
      final models = messages.map(ChatMessageModel.fromEntity).toList();
      await _localDataSource.saveMessages(conversationId, models);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> clearMessages(String conversationId) async {
    try {
      await _localDataSource.clearMessages(conversationId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure(message: e.toString()));
    }
  }
}

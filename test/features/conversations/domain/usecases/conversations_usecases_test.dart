import 'package:brain_box_ai/core/result/result.dart';
import 'package:brain_box_ai/features/chat/domain/entities/chat_message.dart';
import 'package:brain_box_ai/features/conversations/domain/entities/conversation.dart';
import 'package:brain_box_ai/features/conversations/domain/repositories/conversation_repository.dart';
import 'package:brain_box_ai/features/conversations/domain/usecases/delete_conversation_usecase.dart';
import 'package:brain_box_ai/features/conversations/domain/usecases/get_chat_history_usecase.dart';
import 'package:brain_box_ai/features/conversations/domain/usecases/get_conversations_usecase.dart';
import 'package:brain_box_ai/features/conversations/domain/usecases/rename_conversation_usecase.dart';
import 'package:brain_box_ai/features/conversations/domain/usecases/save_chat_history_usecase.dart';
import 'package:brain_box_ai/features/conversations/domain/usecases/save_conversation_usecase.dart';
import 'package:brain_box_ai/features/conversations/domain/usecases/toggle_pin_conversation_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeConversationRepository implements ConversationRepository {
  final List<Conversation> conversations = [];
  final Map<String, List<ChatMessage>> messagesMap = {};

  @override
  Future<Result<List<Conversation>>> getConversations() async {
    return Result.success(conversations);
  }

  @override
  Future<Result<void>> saveConversation(Conversation conversation) async {
    final idx = conversations.indexWhere((c) => c.id == conversation.id);
    if (idx >= 0) {
      conversations[idx] = conversation;
    } else {
      conversations.add(conversation);
    }
    return const Result.success(null);
  }

  @override
  Future<Result<void>> deleteConversation(String id) async {
    conversations.removeWhere((c) => c.id == id);
    messagesMap.remove(id);
    return const Result.success(null);
  }

  @override
  Future<Result<bool>> togglePin(String id) async {
    final idx = conversations.indexWhere((c) => c.id == id);
    if (idx == -1) return const Result.success(false);
    final updated = conversations[idx].copyWith(
      isPinned: !conversations[idx].isPinned,
    );
    conversations[idx] = updated;
    return Result.success(updated.isPinned);
  }

  @override
  Future<Result<void>> renameConversation(String id, String newTitle) async {
    final idx = conversations.indexWhere((c) => c.id == id);
    if (idx >= 0) {
      conversations[idx] = conversations[idx].copyWith(title: newTitle);
    }
    return const Result.success(null);
  }

  @override
  Future<Result<List<ChatMessage>>> getMessages(String conversationId) async {
    return Result.success(messagesMap[conversationId] ?? []);
  }

  @override
  Future<Result<void>> saveMessages(
    String conversationId,
    List<ChatMessage> messages,
  ) async {
    messagesMap[conversationId] = messages;
    return const Result.success(null);
  }

  @override
  Future<Result<void>> clearMessages(String conversationId) async {
    messagesMap.remove(conversationId);
    return const Result.success(null);
  }
}

void main() {
  group('Conversations UseCases Unit Tests', () {
    late FakeConversationRepository repository;

    setUp(() {
      repository = FakeConversationRepository();
      repository.conversations.addAll([
        Conversation(
          id: '1',
          title: 'Quantum Computing',
          lastMessage: 'Summary of quantum qubits',
          updatedAt: DateTime.now(),
          isPinned: false,
        ),
      ]);
    });

    test('GetConversationsUseCase returns list', () async {
      final useCase = GetConversationsUseCase(repository);
      final result = await useCase();
      expect(result, isA<Success<List<Conversation>>>());
      expect((result as Success<List<Conversation>>).data.length, 1);
    });

    test('SaveConversationUseCase saves new conversation', () async {
      final useCase = SaveConversationUseCase(repository);
      final newConv = Conversation(
        id: '2',
        title: 'New Chat',
        lastMessage: 'Hello',
        updatedAt: DateTime.now(),
      );
      final result = await useCase(newConv);
      expect(result, isA<Success<void>>());
      expect(repository.conversations.length, 2);
    });

    test('TogglePinConversationUseCase toggles pin', () async {
      final useCase = TogglePinConversationUseCase(repository);
      final result = await useCase('1');
      expect((result as Success<bool>).data, true);
    });

    test('RenameConversationUseCase renames title', () async {
      final useCase = RenameConversationUseCase(repository);
      await useCase('1', 'New Title');
      expect(repository.conversations.first.title, 'New Title');
    });

    test('DeleteConversationUseCase removes conversation', () async {
      final useCase = DeleteConversationUseCase(repository);
      await useCase('1');
      expect(repository.conversations.isEmpty, true);
    });

    test('SaveChatHistoryUseCase and GetChatHistoryUseCase manage messages',
        () async {
      final saveUseCase = SaveChatHistoryUseCase(repository);
      final getUseCase = GetChatHistoryUseCase(repository);

      final msg = ChatMessage(
        id: 'm1',
        content: 'Hi AI',
        isUser: true,
        timestamp: DateTime.now(),
      );

      await saveUseCase('conv-1', [msg]);
      final retrieved = await getUseCase('conv-1');
      expect((retrieved as Success<List<ChatMessage>>).data.length, 1);
      expect(retrieved.data.first.content, 'Hi AI');
    });
  });
}

import 'package:brain_box_ai/features/chat/data/models/chat_message_model.dart';
import 'package:brain_box_ai/features/conversations/data/datasources/conversation_local_data_source.dart';
import 'package:brain_box_ai/features/conversations/data/models/conversation_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConversationLocalDataSource Unit Tests', () {
    late SharedPreferences prefs;
    late ConversationLocalDataSourceImpl dataSource;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      dataSource = ConversationLocalDataSourceImpl(prefs);
    });

    test('initializes with empty conversations when cache is empty', () async {
      final conversations = await dataSource.getConversations();
      expect(conversations.isEmpty, true);
    });

    test('saveConversation adds a new conversation to cache', () async {
      final newConv = ConversationModel(
        id: 'new-100',
        title: 'New AI Topic',
        lastMessage: 'How to build neural networks',
        updatedAt: DateTime.now(),
        isPinned: false,
      );

      await dataSource.saveConversation(newConv);
      final list = await dataSource.getConversations();
      expect(list.any((c) => c.id == 'new-100'), true);
      expect(list.length, 1);
    });

    test('togglePin toggles pinned status and persists', () async {
      final newConv = ConversationModel(
        id: 'new-100',
        title: 'New AI Topic',
        lastMessage: 'How to build neural networks',
        updatedAt: DateTime.now(),
        isPinned: false,
      );
      await dataSource.saveConversation(newConv);

      final newPin = await dataSource.togglePin('new-100');
      expect(newPin, true);
    });

    test('renameConversation updates title and persists', () async {
      final newConv = ConversationModel(
        id: 'new-100',
        title: 'New AI Topic',
        lastMessage: 'How to build neural networks',
        updatedAt: DateTime.now(),
        isPinned: false,
      );
      await dataSource.saveConversation(newConv);

      await dataSource.renameConversation('new-100', 'Updated Title');
      final list = await dataSource.getConversations();
      final updated = list.firstWhere((c) => c.id == 'new-100');
      expect(updated.title, 'Updated Title');
    });

    test('deleteConversation removes conversation from cache', () async {
      final newConv = ConversationModel(
        id: 'new-100',
        title: 'New AI Topic',
        lastMessage: 'How to build neural networks',
        updatedAt: DateTime.now(),
        isPinned: false,
      );
      await dataSource.saveConversation(newConv);

      await dataSource.deleteConversation('new-100');
      final list = await dataSource.getConversations();
      expect(list.any((c) => c.id == 'new-100'), false);
    });

    test('saveMessages and getMessages persist chat history', () async {
      final messages = [
        ChatMessageModel(
          id: 'msg-1',
          content: 'Hello AI',
          isUser: true,
          timestamp: DateTime.now(),
        ),
        ChatMessageModel(
          id: 'msg-2',
          content: 'Hello human! How can I assist you?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];

      await dataSource.saveMessages('chat-100', messages);
      final retrieved = await dataSource.getMessages('chat-100');
      expect(retrieved.length, 2);
      expect(retrieved.first.content, 'Hello AI');
      expect(retrieved.last.content, 'Hello human! How can I assist you?');

      await dataSource.clearMessages('chat-100');
      final afterClear = await dataSource.getMessages('chat-100');
      expect(afterClear.isEmpty, true);
    });
  });
}

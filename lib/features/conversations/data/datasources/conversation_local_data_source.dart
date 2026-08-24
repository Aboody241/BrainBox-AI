import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../chat/data/models/chat_message_model.dart';
import '../models/conversation_model.dart';

abstract interface class ConversationLocalDataSource {
  Future<List<ConversationModel>> getConversations();
  Future<void> saveConversation(ConversationModel conversation);
  Future<void> deleteConversation(String id);
  Future<bool> togglePin(String id);
  Future<void> renameConversation(String id, String newTitle);
  Future<List<ChatMessageModel>> getMessages(String conversationId);
  Future<void> saveMessages(
    String conversationId,
    List<ChatMessageModel> messages,
  );
  Future<void> clearMessages(String conversationId);
}

class ConversationLocalDataSourceImpl implements ConversationLocalDataSource {
  static const String _conversationsKey = 'brainbox_cached_conversations';
  static const String _chatPrefix = 'brainbox_chat_messages_';

  final SharedPreferences _prefs;

  ConversationLocalDataSourceImpl(this._prefs) {
    _ensureSeedData();
  }

  void _ensureSeedData() {
    final raw = _prefs.getString(_conversationsKey);
    if (raw == null || raw.isEmpty) {
      final defaultSeed = [
        ConversationModel(
          id: '1',
          title: 'Quantum Computing Concepts',
          lastMessage:
              'Quantum computing is a new type of computing that uses quantum mechanics to process information.',
          updatedAt: DateTime.now().subtract(const Duration(minutes: 25)),
          isPinned: true,
        ),
        ConversationModel(
          id: '2',
          title: 'Flutter Clean Architecture Guide',
          lastMessage:
              'Let’s organize the data, domain, and presentation layers with strong separation of concerns.',
          updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
          isPinned: true,
        ),
        ConversationModel(
          id: '3',
          title: 'Tokyo 5-Day Travel Plan',
          lastMessage:
              'Here is your complete itinerary for exploring Shibuya, Asakusa, Akihabara, and Mount Fuji.',
          updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          isPinned: false,
        ),
        ConversationModel(
          id: '4',
          title: 'Creative Story Ideas for Sci-Fi Novel',
          lastMessage:
              'In a world where memories can be transferred through neural synchronization...',
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          isPinned: false,
        ),
        ConversationModel(
          id: '5',
          title: 'Weekly Workout & Nutrition Routine',
          lastMessage:
              'High protein meal plan combined with 4-day hypertrophy split focus.',
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
          isPinned: false,
        ),
      ];

      final encoded = jsonEncode(defaultSeed.map((e) => e.toJson()).toList());
      _prefs.setString(_conversationsKey, encoded);
    }
  }

  @override
  Future<List<ConversationModel>> getConversations() async {
    final raw = _prefs.getString(_conversationsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      final models = list
          .map((item) =>
              ConversationModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // Sort: Pinned first, then by updatedAt descending
      models.sort((a, b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });

      return models;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveConversation(ConversationModel conversation) async {
    final current = await getConversations();
    final index = current.indexWhere((c) => c.id == conversation.id);

    if (index >= 0) {
      current[index] = conversation;
    } else {
      current.insert(0, conversation);
    }

    final encoded = jsonEncode(current.map((e) => e.toJson()).toList());
    await _prefs.setString(_conversationsKey, encoded);
  }

  @override
  Future<void> deleteConversation(String id) async {
    final current = await getConversations();
    current.removeWhere((c) => c.id == id);

    final encoded = jsonEncode(current.map((e) => e.toJson()).toList());
    await _prefs.setString(_conversationsKey, encoded);
    await clearMessages(id);
  }

  @override
  Future<bool> togglePin(String id) async {
    final current = await getConversations();
    final index = current.indexWhere((c) => c.id == id);
    if (index == -1) return false;

    final updated = current[index].copyWith(
      isPinned: !current[index].isPinned,
    );
    current[index] = ConversationModel.fromEntity(updated);

    final encoded = jsonEncode(current.map((e) => e.toJson()).toList());
    await _prefs.setString(_conversationsKey, encoded);
    return updated.isPinned;
  }

  @override
  Future<void> renameConversation(String id, String newTitle) async {
    final current = await getConversations();
    final index = current.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final updated = current[index].copyWith(
      title: newTitle.trim(),
      updatedAt: DateTime.now(),
    );
    current[index] = ConversationModel.fromEntity(updated);

    final encoded = jsonEncode(current.map((e) => e.toJson()).toList());
    await _prefs.setString(_conversationsKey, encoded);
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String conversationId) async {
    final key = '$_chatPrefix$conversationId';
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) =>
              ChatMessageModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveMessages(
    String conversationId,
    List<ChatMessageModel> messages,
  ) async {
    final key = '$_chatPrefix$conversationId';
    final encoded = jsonEncode(messages.map((e) => e.toJson()).toList());
    await _prefs.setString(key, encoded);
  }

  @override
  Future<void> clearMessages(String conversationId) async {
    final key = '$_chatPrefix$conversationId';
    await _prefs.remove(key);
  }
}

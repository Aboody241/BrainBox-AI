import '../../domain/entities/conversation.dart';

class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.title,
    required super.lastMessage,
    required super.updatedAt,
    super.isPinned = false,
  });

  factory ConversationModel.fromEntity(Conversation entity) {
    return ConversationModel(
      id: entity.id,
      title: entity.title,
      lastMessage: entity.lastMessage,
      updatedAt: entity.updatedAt,
      isPinned: entity.isPinned,
    );
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled Chat',
      lastMessage: json['lastMessage'] as String? ?? '',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lastMessage': lastMessage,
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
    };
  }
}

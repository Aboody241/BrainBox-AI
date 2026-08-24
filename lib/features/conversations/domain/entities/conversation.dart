/// Domain entity representing a conversation in BrainBox AI.
class Conversation {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime updatedAt;
  final bool isPinned;

  const Conversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
    this.isPinned = false,
  });

  Conversation copyWith({
    String? id,
    String? title,
    String? lastMessage,
    DateTime? updatedAt,
    bool? isPinned,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation &&
        other.id == id &&
        other.title == title &&
        other.lastMessage == lastMessage &&
        other.updatedAt == updatedAt &&
        other.isPinned == isPinned;
  }

  @override
  int get hashCode =>
      Object.hash(id, title, lastMessage, updatedAt, isPinned);
}

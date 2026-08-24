import 'dart:convert';
import 'dart:typed_data';

import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.isUser,
    required super.timestamp,
    super.isStreaming = false,
    super.imageBytes,
    super.imagePath,
  });

  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id,
      content: entity.content,
      isUser: entity.isUser,
      timestamp: entity.timestamp,
      isStreaming: entity.isStreaming,
      imageBytes: entity.imageBytes,
      imagePath: entity.imagePath,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    Uint8List? imageBytes;
    if (json['imageBase64'] != null) {
      try {
        imageBytes = base64Decode(json['imageBase64'] as String);
      } catch (_) {}
    }

    return ChatMessageModel(
      id: json['id'] as String,
      content: json['content'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      isStreaming: json['isStreaming'] as bool? ?? false,
      imageBytes: imageBytes,
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isStreaming': false,
      'imageBase64': imageBytes != null ? base64Encode(imageBytes!) : null,
      'imagePath': imagePath,
    };
  }
}

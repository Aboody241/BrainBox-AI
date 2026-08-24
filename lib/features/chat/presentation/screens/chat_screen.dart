import 'package:flutter/material.dart';

import '../../../../core/presentation/theme/app_typography.dart';

class ChatScreen extends StatelessWidget {
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.conversationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat: $conversationId'),
      ),
      body: Center(
        child: Text(
          'Conversation: $conversationId',
          style: AppTypography.titleMedium,
        ),
      ),
    );
  }
}

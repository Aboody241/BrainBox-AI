import 'package:brain_box_ai/core/presentation/widgets/app_chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppChatBubble Widget Tests', () {
    testWidgets('renders user message bubble correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppChatBubble(
              message: 'Hello AI',
              isUser: true,
              timestamp: '10:30 AM',
            ),
          ),
        ),
      );

      expect(find.text('Hello AI'), findsOneWidget);
      expect(find.text('10:30 AM'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('renders AI message bubble correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppChatBubble(
              message: 'Hello human! How can I assist you?',
              isUser: false,
              timestamp: '10:31 AM',
            ),
          ),
        ),
      );

      expect(find.text('Hello human! How can I assist you?'), findsOneWidget);
      expect(find.text('10:31 AM'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });
  });
}

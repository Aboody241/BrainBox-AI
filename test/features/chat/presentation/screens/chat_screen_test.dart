import 'package:brain_box_ai/features/chat/presentation/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatScreen Widget Tests', () {
    testWidgets(
        'renders top bar, BrainBox title, 5 capability cards, and send message input',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChatScreen(conversationId: 'test-1'),
        ),
      );

      expect(find.text('BrainBox'), findsOneWidget);
      expect(
        find.text('Remembers what user said earlier in the conversation'),
        findsOneWidget,
      );
      expect(
        find.text('Allows user to provide. follow-up corrections With Ai'),
        findsOneWidget,
      );
      expect(
        find.text('Limited knowledge of world and events after 2021'),
        findsOneWidget,
      );
      expect(
        find.text('May occasionally generate incorrect information'),
        findsOneWidget,
      );
      expect(
        find.text(
            'May occasionally produce harmful instructions or biased content'),
        findsOneWidget,
      );
      expect(find.text('Send a message.'), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    });

    testWidgets('typing and sending a message displays chat bubble',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChatScreen(conversationId: 'test-2'),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello AI');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(find.text('Hello AI'), findsOneWidget);

      // Settle AI response
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();

      expect(
        find.text(
            'I am BrainBox AI, your smart conversational assistant. How can I help you achieve your goals today?'),
        findsOneWidget,
      );
    });
  });
}

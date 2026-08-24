import 'package:brain_box_ai/features/chat/presentation/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      expect(find.byType(SvgPicture), findsWidgets);
    });

    testWidgets(
        'sending message displays user bubble, AI bubble with avatar, and stop generating button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChatScreen(conversationId: 'test-2'),
        ),
      );

      await tester.enterText(
          find.byType(TextField), 'Explain quantum computing in simple terms');
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();

      expect(find.text('Explain quantum computing in simple terms'),
          findsOneWidget);

      // Advance clock slightly for AI streaming initiation
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Stop generating...'), findsOneWidget);
      expect(find.byIcon(Icons.content_copy_outlined), findsOneWidget);
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);

      // Tap stop generating
      await tester.tap(find.text('Stop generating...'));
      await tester.pump();

      expect(find.text('Stop generating...'), findsNothing);
      expect(find.text('Regenerate Respond'), findsOneWidget);
    });

    testWidgets('floating top bar is present and responsive',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChatScreen(conversationId: 'test-3'),
        ),
      );

      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
      expect(find.byType(ChatScreen), findsOneWidget);
    });
  });
}

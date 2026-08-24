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
        find.text('Explain quantum computing in simple terms'),
        findsOneWidget,
      );
      expect(
        find.text('Write a Python script to automate daily tasks'),
        findsOneWidget,
      );
      expect(
        find.text('Give me 5 creative ideas for a sci-fi short story'),
        findsOneWidget,
      );
      expect(
        find.text('Draft a professional email requesting a project update'),
        findsOneWidget,
      );
      expect(
        find.text('Create a 3-day travel itinerary for visiting Tokyo'),
        findsOneWidget,
      );
      expect(find.text('Send a message.'), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
      expect(find.byType(SvgPicture), findsWidgets);
    });

    testWidgets(
        'tapping image upload button opens image source bottom sheet',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChatScreen(conversationId: 'test-image-upload'),
        ),
      );

      // Tap image upload icon button
      final imageUploadFinder = find.byWidgetPredicate((widget) =>
          widget is SvgPicture &&
          widget.bytesLoader.toString().contains('image_upload'));
      expect(imageUploadFinder, findsOneWidget);

      await tester.tap(imageUploadFinder);
      await tester.pumpAndSettle();

      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
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
      expect(find.text('Stop Generating'), findsOneWidget);
      expect(find.byIcon(Icons.content_copy_outlined), findsOneWidget);
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);

      // Tap stop generating
      await tester.tap(find.text('Stop Generating'));
      await tester.pump();

      expect(find.text('Stop Generating'), findsNothing);
      expect(find.textContaining('Regenerate'), findsOneWidget);
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

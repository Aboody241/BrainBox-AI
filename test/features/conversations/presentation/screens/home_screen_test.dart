import 'package:brain_box_ai/features/conversations/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets(
        'renders top back button, logo, welcome text, Get Started button, and bottom navigation bar',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.text('Welcome to'), findsOneWidget);
      expect(find.text('BrainBox'), findsOneWidget);
      expect(
        find.text('Start chatting with ChattyAI now.\nYou can ask me anything.'),
        findsOneWidget,
      );
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    });

    testWidgets('switching bottom navigation item updates selection dot',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Tap access time icon
      await tester.tap(find.byIcon(Icons.access_time_rounded));
      await tester.pump();

      // Tap home icon
      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pump();
    });
  });
}

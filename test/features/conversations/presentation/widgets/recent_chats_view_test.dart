import 'package:brain_box_ai/features/conversations/presentation/widgets/recent_chats_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecentChatsView Widget Tests', () {
    testWidgets('renders recent chats title, search button, new chat button, and conversations',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RecentChatsView(),
        ),
      );

      expect(find.text('Recent Chats'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);
      expect(find.text('Quantum Computing Concepts'), findsOneWidget);
      expect(find.text('Flutter Clean Architecture Guide'), findsOneWidget);
      expect(find.text('Tokyo 5-Day Travel Plan'), findsOneWidget);
      expect(find.text('New Chat'), findsOneWidget);
    });

    testWidgets('filter chips toggle between All and Pinned',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RecentChatsView(),
        ),
      );

      // Tap Pinned filter chip
      await tester.tap(find.text('Pinned'));
      await tester.pumpAndSettle();

      expect(find.text('Quantum Computing Concepts'), findsOneWidget);
      expect(find.text('Flutter Clean Architecture Guide'), findsOneWidget);
      expect(find.text('Tokyo 5-Day Travel Plan'), findsNothing);

      // Tap All filter chip
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.text('Tokyo 5-Day Travel Plan'), findsOneWidget);
    });

    testWidgets('searching filters conversations in real time',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RecentChatsView(),
        ),
      );

      // Open search bar
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Tokyo');
      await tester.pumpAndSettle();

      expect(find.text('Tokyo 5-Day Travel Plan'), findsOneWidget);
      expect(find.text('Quantum Computing Concepts'), findsNothing);
    });
  });
}

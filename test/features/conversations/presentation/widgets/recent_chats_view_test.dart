import 'package:brain_box_ai/app/di/service_locator.dart';
import 'package:brain_box_ai/features/conversations/domain/entities/conversation.dart';
import 'package:brain_box_ai/features/conversations/domain/usecases/save_conversation_usecase.dart';
import 'package:brain_box_ai/features/conversations/presentation/widgets/recent_chats_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await ServiceLocator.reset();
    await ServiceLocator.init();
  });

  tearDown(() async {
    await ServiceLocator.reset();
  });

  group('RecentChatsView Widget Tests', () {
    testWidgets(
        'renders empty state when there are no cached conversations',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: RecentChatsView(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recent chats'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.text('No conversations yet'), findsOneWidget);
    });

    testWidgets('renders saved conversations, filters, and search', (tester) async {
      // Save 2 test conversations to repository
      final saveUseCase = sl<SaveConversationUseCase>();
      await saveUseCase(
        Conversation(
          id: '1',
          title: 'Quantum Computing Concepts',
          lastMessage: 'Summary of quantum qubits',
          updatedAt: DateTime.now(),
          isPinned: true,
        ),
      );
      await saveUseCase(
        Conversation(
          id: '2',
          title: 'Tokyo 5-Day Travel Plan',
          lastMessage: 'Explore Shibuya and Shinjuku',
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          isPinned: false,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: RecentChatsView(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Quantum Computing Concepts'), findsOneWidget);
      expect(find.text('Tokyo 5-Day Travel Plan'), findsOneWidget);

      // Filter by Pinned
      await tester.tap(find.textContaining('Pinned'));
      await tester.pumpAndSettle();

      expect(find.text('Quantum Computing Concepts'), findsOneWidget);
      expect(find.text('Tokyo 5-Day Travel Plan'), findsNothing);

      // Filter by All
      await tester.tap(find.textContaining('All'));
      await tester.pumpAndSettle();

      expect(find.text('Tokyo 5-Day Travel Plan'), findsOneWidget);

      // Search
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Tokyo');
      await tester.pumpAndSettle();

      expect(find.text('Tokyo 5-Day Travel Plan'), findsOneWidget);
      expect(find.text('Quantum Computing Concepts'), findsNothing);
    });
  });
}

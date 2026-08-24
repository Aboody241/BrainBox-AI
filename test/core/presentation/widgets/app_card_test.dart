import 'package:brain_box_ai/core/presentation/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppCard Widget Tests', () {
    testWidgets('renders child content and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              onTap: () => tapped = true,
              child: const Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      await tester.tap(find.text('Card Content'));
      expect(tapped, isTrue);
    });
  });
}

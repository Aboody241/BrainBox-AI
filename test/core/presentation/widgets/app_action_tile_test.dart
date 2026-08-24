import 'package:brain_box_ai/core/presentation/widgets/app_action_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppActionTile Widget Tests', () {
    testWidgets('renders title, subtitle and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppActionTile(
              title: 'Email',
              subtitle: 'Code Send to your email',
              icon: const Icon(Icons.mail_outline),
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Code Send to your email'), findsOneWidget);
      expect(find.byIcon(Icons.mail_outline), findsOneWidget);

      await tester.tap(find.text('Email'));
      expect(tapped, isTrue);
    });
  });
}

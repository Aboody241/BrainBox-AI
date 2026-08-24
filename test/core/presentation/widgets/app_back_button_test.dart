import 'package:brain_box_ai/core/presentation/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppBackButton Widget Tests', () {
    testWidgets('renders back button container and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppBackButton(),
          ),
        ),
      );

      expect(find.byType(AppBackButton), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('triggers custom onPressed callback', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppBackButton(
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppBackButton));
      expect(pressed, isTrue);
    });
  });
}

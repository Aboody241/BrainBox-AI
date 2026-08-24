import 'package:brain_box_ai/core/presentation/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppButton Widget Tests', () {
    testWidgets('renders primary button and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              text: 'Log in',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Log in'), findsOneWidget);
      await tester.tap(find.text('Log in'));
      expect(tapped, isTrue);
    });

    testWidgets('renders secondary button with text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton.secondary(
              text: 'Sign up',
            ),
          ),
        ),
      );

      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('displays CircularProgressIndicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              text: 'Log in',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Log in'), findsNothing);
    });
  });
}

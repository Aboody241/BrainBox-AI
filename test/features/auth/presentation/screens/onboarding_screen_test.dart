import 'package:brain_box_ai/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingScreen Widget Tests', () {
    testWidgets('renders first onboarding page content and skip button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );

      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Unlock the Power\nOf Future AI'), findsOneWidget);
    });
  });
}

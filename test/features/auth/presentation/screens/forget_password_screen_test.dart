import 'package:brain_box_ai/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ForgetPasswordScreen Widget Tests', () {
    testWidgets('renders heading, contact options, and next button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ForgetPasswordScreen(),
        ),
      );

      expect(find.text('Forget Password'), findsOneWidget);
      expect(
        find.text(
            'Select which contact details should we use to reset your password'),
        findsOneWidget,
      );
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });
  });
}

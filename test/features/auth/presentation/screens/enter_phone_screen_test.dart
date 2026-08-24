import 'package:brain_box_ai/features/auth/presentation/screens/enter_phone_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EnterPhoneScreen Widget Tests', () {
    testWidgets('renders heading, phone text field, and verification buttons',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EnterPhoneScreen(),
        ),
      );

      expect(find.text('Enter Your Phone'), findsOneWidget);
      expect(find.text('Number'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Verification'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);
    });
  });
}

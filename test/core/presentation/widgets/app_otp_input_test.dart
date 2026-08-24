import 'package:brain_box_ai/core/presentation/widgets/app_otp_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppOtpInput Widget Tests', () {
    testWidgets('renders 4 input boxes and triggers onCompleted callback', (tester) async {
      String? completedCode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppOtpInput(
              length: 4,
              onCompleted: (code) => completedCode = code,
            ),
          ),
        ),
      );

      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(4));

      await tester.enterText(textFields.at(0), '1');
      await tester.enterText(textFields.at(1), '2');
      await tester.enterText(textFields.at(2), '3');
      await tester.enterText(textFields.at(3), '4');

      expect(completedCode, equals('1234'));
    });
  });
}

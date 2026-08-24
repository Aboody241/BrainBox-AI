import 'package:brain_box_ai/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsScreen (Profile) Widget Tests', () {
    testWidgets('renders profile heading, user details, and setting tiles',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Tom Hillson'), findsOneWidget);
      expect(find.text('Tomhill@mail.com'), findsOneWidget);

      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Account Security'), findsOneWidget);
      expect(find.text('Excellent'), findsOneWidget);
      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Customer Support'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('tapping Account Security opens security bottom sheet with score',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.tap(find.text('Account Security'));
      await tester.pumpAndSettle();

      expect(find.text('Score: 95%'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Two-Factor Authentication'), findsOneWidget);
      expect(find.text('Biometric Login'), findsOneWidget);
    });

    testWidgets('tapping Logout opens confirm logout dialog',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      await tester.ensureVisible(find.text('Logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Logout'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}

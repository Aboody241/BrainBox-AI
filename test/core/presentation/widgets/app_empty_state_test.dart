import 'package:brain_box_ai/core/presentation/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEmptyState Widget Tests', () {
    testWidgets('renders default title, subtitle, and icon for noNetwork type',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppEmptyState(type: AppEmptyStateType.noNetwork),
          ),
        ),
      );

      expect(find.text('No Connection'), findsOneWidget);
      expect(
        find.text('Please check your internet connection and try again.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('renders custom title, subtitle, and action button tap',
        (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'Custom Title',
              subtitle: 'Custom Subtitle',
              actionButtonText: 'Retry',
              onActionTap: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.text('Custom Subtitle'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(actionTapped, isTrue);
    });
  });
}

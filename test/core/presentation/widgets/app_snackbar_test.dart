import 'package:brain_box_ai/core/presentation/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSnackBar Widget Tests', () {
    testWidgets('shows snackbar with title and message when triggered',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AppSnackBar.showError(
                      context,
                      title: 'Network Error',
                      message: 'Failed to connect to server',
                    );
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pump();

      expect(find.text('Network Error'), findsOneWidget);
      expect(find.text('Failed to connect to server'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}

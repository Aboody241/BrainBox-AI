import 'package:brain_box_ai/core/presentation/widgets/app_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppBanner Widget Tests', () {
    testWidgets('renders title, message and responds to close button tap',
        (tester) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppBanner(
              title: 'Error Occurred',
              message: 'Something went wrong',
              variant: AppBannerVariant.error,
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      expect(find.text('Error Occurred'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      expect(closed, isTrue);
    });
  });
}

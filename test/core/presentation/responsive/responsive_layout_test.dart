import 'package:brain_box_ai/core/presentation/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Responsive Layout Tests', () {
    testWidgets('AppResponsiveLayout renders mobile layout when screen width < 600',
        (tester) async {
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppResponsiveLayout(
              mobile: Text('Mobile Layout'),
              tablet: Text('Tablet Layout'),
              desktop: Text('Desktop Layout'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsOneWidget);
      expect(find.text('Tablet Layout'), findsNothing);
      expect(find.text('Desktop Layout'), findsNothing);
    });

    testWidgets('AppResponsiveLayout renders tablet layout when width between 600 and 1023',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppResponsiveLayout(
              mobile: Text('Mobile Layout'),
              tablet: Text('Tablet Layout'),
              desktop: Text('Desktop Layout'),
            ),
          ),
        ),
      );

      expect(find.text('Tablet Layout'), findsOneWidget);
    });

    testWidgets('AppResponsiveLayout renders desktop layout when width >= 1024',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppResponsiveLayout(
              mobile: Text('Mobile Layout'),
              tablet: Text('Tablet Layout'),
              desktop: Text('Desktop Layout'),
            ),
          ),
        ),
      );

      expect(find.text('Desktop Layout'), findsOneWidget);
    });

    testWidgets('AppCenteredContent applies maxWidth constraint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCenteredContent(
              maxWidth: 400,
              child: Text('Centered Box'),
            ),
          ),
        ),
      );

      expect(find.text('Centered Box'), findsOneWidget);
      final constrainedBox = tester.widget<ConstrainedBox>(
        find.byType(ConstrainedBox).last,
      );
      expect(constrainedBox.constraints.maxWidth, equals(400));
    });
  });
}

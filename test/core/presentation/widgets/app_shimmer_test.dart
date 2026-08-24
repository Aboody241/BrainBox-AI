import 'package:brain_box_ai/core/presentation/widgets/app_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppShimmer Widget Tests', () {
    testWidgets('renders shimmer effect and animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppShimmer(
              width: 100,
              height: 20,
            ),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
      
      // Fast-forward animation a bit
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}

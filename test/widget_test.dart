import 'package:brain_box_ai/app/app.dart';
import 'package:brain_box_ai/app/di/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await ServiceLocator.reset();
    await ServiceLocator.init();
  });

  tearDown(() async {
    await ServiceLocator.reset();
  });

  testWidgets(
      'App renders 2-step splash animation and navigates to onboarding screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BrainBoxApp());

    // Step 1: Central Logo + BrainBox
    expect(find.text('BrainBox'), findsOneWidget);
    expect(find.text('Version 1.0'), findsOneWidget);

    // Step 2: Transition to textSlogan after 1200ms
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump(const Duration(milliseconds: 600));

    // Step 3: Complete animation and navigate to OnboardingScreen
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(find.text('Unlock the Power\nOf Future AI'), findsOneWidget);
  });
}

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

  testWidgets('App renders splash route smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BrainBoxApp());
    await tester.pumpAndSettle();
    expect(find.text('BrainBox AI'), findsOneWidget);
  });
}

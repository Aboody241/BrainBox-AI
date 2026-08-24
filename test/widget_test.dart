import 'package:brain_box_ai/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BrainBoxApp());
    expect(find.text('BrainBox AI'), findsOneWidget);
  });
}

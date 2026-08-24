import 'package:brain_box_ai/features/chat/presentation/widgets/chat_markdown_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMarkdownView Widget Tests', () {
    testWidgets('renders markdown bold text and paragraphs correctly',
        (tester) async {
      const markdownText =
          '**SwiftUI** is Apple’s modern declarative UI framework.\n\n* **Declarative Syntax:** You simply state what your UI should do.';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatMarkdownView(
              text: markdownText,
              isStreaming: false,
            ),
          ),
        ),
      );

      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(find.textContaining('SwiftUI'), findsOneWidget);
      expect(find.textContaining('Declarative Syntax:'), findsOneWidget);
    });

    testWidgets('renders code block with language label and copy button',
        (tester) async {
      const markdownWithCode = '''
Here is the code:
```swift
struct ContentView: View {
    var body: some View {
        Text("Hello BrainBox")
    }
}
```
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChatMarkdownView(
              text: markdownWithCode,
              isStreaming: false,
            ),
          ),
        ),
      );

      expect(find.text('SWIFT'), findsOneWidget);
      expect(find.text('Copy code'), findsOneWidget);
      expect(find.textContaining('struct ContentView: View'), findsOneWidget);

      // Tap copy code button
      await tester.tap(find.text('Copy code'));
      await tester.pump();

      expect(find.text('Copied!'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
    });
  });
}

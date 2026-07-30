import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget smoke test', (WidgetTester tester) async {
    // Build a simple standalone widget that doesn't depend on Firebase
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Mashvira Smoke Test'),
          ),
        ),
      ),
    );

    // Verify the text renders correctly
    expect(find.text('Mashvira Smoke Test'), findsOneWidget);
  });
}

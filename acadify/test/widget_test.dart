// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:acadify/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build the app with an initial route.
    await tester.pumpWidget(const MyApp(
      initialRoute: '/splash',
    ));

    // Verify that the app starts at the splash screen (assuming it contains a widget with 'Splash Screen').
    expect(find.text('Splash Screen'), findsOneWidget);

    // Tap the '+' icon and trigger a frame (replace with a testable button in your app).
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify some state change if applicable (adjust for your app's UI).
    expect(find.text('1'), findsOneWidget);
  });
}

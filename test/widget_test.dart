// This is a basic test file for the doorphone viewer app.
// In a real application, you would write comprehensive tests for your widgets and logic.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doorphone_viewer/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DoorphoneViewerApp());

    // Verify that the app starts without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
  
  test('Basic unit test example', () {
    // Simple unit test to ensure test framework is working
    expect(2 + 2, equals(4));
  });
}
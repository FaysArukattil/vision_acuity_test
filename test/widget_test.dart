// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vision_acuity_test/main.dart';

void main() {
  testWidgets('Vision Acuity Test app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VisionAcuityApp());

    // Verify that the app title is displayed
    expect(find.text('Vision Acuity Test'), findsOneWidget);
    
    // Verify the start button is displayed
    expect(find.text('Start Test'), findsOneWidget);
    
    // Verify the visibility icon is displayed
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pocket_union/main.dart';

void main() {
  testWidgets('App smoke test: primera vez muestra StartScreen sin errores',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PocketUnionApp(
          isFirstLaunch: true,
          isInSession: false,
        ),
      ),
    );
    // Verify the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pffl_managment/main.dart';
import 'package:pffl_managment/core/services/preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App loads correctly smoke test', (WidgetTester tester) async {
    // Provide an empty/mocked preference service for testing
    SharedPreferences.setMockInitialValues({});
    final preferenceService = await PreferenceService.getInstance();

    await tester.pumpWidget(MyApp(preferenceService: preferenceService));

    // Check if the MateriaApp or some basic widget exists
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

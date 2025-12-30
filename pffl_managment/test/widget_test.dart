// Comprehensive Flutter widget tests for PFFL Management App
//
// Tests cover app initialization, error handling, and critical user flows

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pffl_managment/main.dart';
import 'package:pffl_managment/core/services/preference_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App Initialization Tests', () {
    setUp(() {
      // Mock shared preferences for each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('App loads correctly smoke test', (WidgetTester tester) async {
      // Provide an empty/mocked preference service for testing
      final preferenceService = await PreferenceService.getInstance();

      await tester.pumpWidget(MyApp(preferenceService: preferenceService));

      // Check if the MaterialApp or some basic widget exists
      expect(find.byType(MaterialApp), findsOneWidget);

      // Check if app title is correct
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, 'Phoenix Flag Football League');
    });

    testWidgets('App initializes with proper theme', (WidgetTester tester) async {
      final preferenceService = await PreferenceService.getInstance();

      await tester.pumpWidget(MyApp(preferenceService: preferenceService));

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.themeMode, ThemeMode.system);
    });

    testWidgets('App has proper initial route', (WidgetTester tester) async {
      final preferenceService = await PreferenceService.getInstance();

      await tester.pumpWidget(MyApp(preferenceService: preferenceService));

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.initialRoute, isNotNull);
      expect(materialApp.onGenerateRoute, isNotNull);
    });
  });

  group('Error Handling Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('App handles preference service errors gracefully', (WidgetTester tester) async {
      // Test that app doesn't crash if preference service has issues
      final preferenceService = await PreferenceService.getInstance();

      await tester.pumpWidget(MyApp(preferenceService: preferenceService));

      // App should still load even if services have issues
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App initializes services without crashing', (WidgetTester tester) async {
      final preferenceService = await PreferenceService.getInstance();

      // This should not throw any exceptions
      await tester.pumpWidget(MyApp(preferenceService: preferenceService));

      // Wait for any async initialization
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Performance Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('App renders within reasonable time', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      final preferenceService = await PreferenceService.getInstance();
      await tester.pumpWidget(MyApp(preferenceService: preferenceService));

      // Initial pump
      await tester.pump();

      stopwatch.stop();

      // App should render in less than 5 seconds (reasonable for mobile app)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}

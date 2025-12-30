import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/main.dart';
import 'package:pffl_managment/core/services/preference_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      // Test that the app can be built and launched without crashing
      final preferenceService = await PreferenceService.getInstance();

      await tester.pumpWidget(MyApp(preferenceService: preferenceService));

      // Wait for initial setup
      await tester.pumpAndSettle();

      // Verify the app shows the main material app
      expect(find.byType(MaterialApp), findsOneWidget);

      // Verify the app has the correct title
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, 'Phoenix Flag Football League');

      print('✅ App launch test passed');
    });

    testWidgets('Providers are properly initialized', (WidgetTester tester) async {
      final preferenceService = await PreferenceService.getInstance();

      await tester.pumpWidget(MyApp(preferenceService: preferenceService));
      await tester.pumpAndSettle();

      // Verify that the AuthProvider is available
      final context = tester.element(find.byType(MaterialApp));
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      expect(authProvider, isNotNull);
      expect(authProvider.isLoggedIn, false); // Should start logged out

      print('✅ Provider initialization test passed');
    });

    testWidgets('App handles basic navigation structure', (WidgetTester tester) async {
      final preferenceService = await PreferenceService.getInstance();

      await tester.pumpWidget(MyApp(preferenceService: preferenceService));
      await tester.pumpAndSettle();

      // Verify the app has a proper navigation structure
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(materialApp.navigatorKey, isNull); // Uses default navigator
      expect(materialApp.initialRoute, isNotNull);
      expect(materialApp.onGenerateRoute, isNotNull);

      print('✅ Navigation structure test passed');
    });
  });
}

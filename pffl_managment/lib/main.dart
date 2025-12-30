import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_theme.dart' as app_theme;
import 'package:pffl_managment/core/providers/app_providers.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/services/device_service.dart';
import 'package:pffl_managment/core/services/error_reporting_service.dart';
import 'package:pffl_managment/routes/route_generator.dart';
import 'package:pffl_managment/routes/app_routes.dart';

import 'package:pffl_managment/core/services/preference_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error reporting first (backend-based)
  await ErrorReportingService.initialize();

  // Initialize services
  AuthService.configureDio();
  await DeviceService.initialize();

  final preferenceService = await PreferenceService.getInstance();
  runApp(MyApp(preferenceService: preferenceService));
}

class MyApp extends StatelessWidget {
  final PreferenceService preferenceService;
  const MyApp({super.key, required this.preferenceService});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      preferenceService: preferenceService,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Phoenix Flag Football League',
        theme: app_theme.AppTheme.lightTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.getStarted,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}

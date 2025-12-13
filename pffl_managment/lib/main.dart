import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_theme.dart' as app_theme;
import 'package:pffl_managment/core/providers/app_providers.dart';
import 'package:pffl_managment/routes/route_generator.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

void main() {
  // Configure Dio with interceptors
  AuthService.configureDio();
  
  // Set the base URL to your machine's IP address
  AuthService.setBaseUrl('http://192.168.1.13:3000/api');
  
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Phoenix Flag Football League',
        theme: app_theme.AppTheme.lightTheme,
        darkTheme: app_theme.AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.getStarted,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}

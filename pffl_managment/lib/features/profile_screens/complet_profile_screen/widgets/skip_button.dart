import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';

/// Skip button widget for navigating to dashboard based on user role
class SkipButton extends StatelessWidget {
  const SkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          final userRole =
              prefs.getString('userRole') ??
              prefs.getString('role') ??
              authProvider.userRole;

          // Determine route based on user role
          String route;
          switch (userRole.toLowerCase()) {
            case 'captain':
              route = AppRoutes.captainDashboard;
              break;
            case 'player':
              route = AppRoutes.playerDashboard;
              break;
            case 'freeagent':
              route = AppRoutes.freeAgentDashboard;
              break;
            case 'referee':
              route = AppRoutes.refereeDashboard;
              break;
            case 'statkeeper':
              route = AppRoutes.statKeeperDashboard;
              break;
            default:
              route = AppRoutes.playerDashboard; // Default fallback
          }

          Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Skip for now',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward, size: 16, color: Colors.grey[700]),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/captain_navigation_provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class CaptainHeaderWidget extends StatelessWidget {
  const CaptainHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final navigationProvider = Provider.of<CaptainNavigationProvider>(context);
    final textTheme = Theme.of(context).textTheme;
    final brightness = Theme.of(context).brightness;

    String title, subtitle;

    // Extract user's first name
    String firstName = 'Captain';
    if (authProvider.userEmail.isNotEmpty) {
      List<String> parts = authProvider.userEmail.split('@');
      if (parts.isNotEmpty) {
        firstName = parts[0];
        if (firstName.length > 1) {
          firstName = firstName[0].toUpperCase() + firstName.substring(1);
        }
      }
    }

    // Set title and subtitle based on the current screen
    switch (navigationProvider.selectedIndex) {
      case 0: // Home
        title = 'Welcome $firstName';
        subtitle = 'Phoenix Flag Football League';
        break;
      case 1: // My Team
        title = 'Leagues';
        subtitle = 'Manage your account and app.';
        break;
      case 2: // Games
        title = 'Games';
        subtitle = 'Phoenix Flag Football League';
        break;
      case 3: // Leagues
        title = 'My Team';
        subtitle = 'All the leagues are listed below';
        break;
      case 4: // Settings
        title = 'Settings';
        subtitle = 'Manage your account and app.';
        break;
      default:
        title = 'Welcome $firstName';
        subtitle = 'Phoenix Flag Football League';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.headlineLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: textTheme.titleSmall?.copyWith(
                          color: brightness == Brightness.light
                              ? Colors.grey[600]
                              : Colors.grey[400],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Notification icon
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: brightness == Brightness.light
                        ? Colors.grey[300]!
                        : Colors.grey[700]!,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
              if (navigationProvider.selectedIndex == 3) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.captainInvite);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text(
                    'Invite',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

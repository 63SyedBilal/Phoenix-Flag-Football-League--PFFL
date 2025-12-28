import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/referee_navigation_provider.dart';
import 'package:pffl_managment/core/providers/notification_provider.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class RafereeHeaderWidget extends StatelessWidget {
  const RafereeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final navigationProvider = Provider.of<RefereeNavigationProvider>(context);
    final textTheme = Theme.of(context).textTheme;
    final brightness = Theme.of(context).brightness;

    String title, subtitle;

    // Extract user's first name
    String firstName = 'Referee';
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
      case 1: // Games
        title = 'Games';
        subtitle = 'View all Games are listed below.';
        break;
      case 2: // Leagues
        title = 'Leagues';
        subtitle = 'View all Leagues are listed below.';
        break;
      case 3: // Settings
        title = 'Settings';
        subtitle = 'Manage your account and app preferences.';
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
              // Enhanced notification icon with badge
              RefereeNotificationButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class RefereeNotificationButton extends StatelessWidget {
  const RefereeNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final brightness = Theme.of(context).brightness;
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.refereeNotification);
      },
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: brightness == Brightness.light
                ? AppColors.borderDefault
                : AppColors.borderLight,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.notifications_outlined,
                size: 20,
                color: brightness == Brightness.light
                    ? AppColors.textPrimary
                    : AppColors.textPrimary,
              ),
            ),
            if (notificationProvider.hasNotifications)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

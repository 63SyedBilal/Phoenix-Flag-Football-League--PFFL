import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/admin_navigation_provider.dart';
import 'package:pffl_managment/features/admin/provider/dashboard_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/core/providers/notification_provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class AdminHeaderWidget extends StatelessWidget {
  const AdminHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DashboardViewModel>(context);
    final navigationProvider = Provider.of<AdminNavigationProvider>(context);
    final textTheme = Theme.of(context).textTheme;
    final brightness = Theme.of(context).brightness;

    String title, subtitle;
    bool showInviteButton = false;

    switch (navigationProvider.selectedIndex) {
      case 0:
        title = 'Welcome ${viewModel.userName},';
        subtitle = viewModel.leagueName;
        break;
      case 1:
        title = 'Leagues';
        subtitle = 'All the leagues are listed below.';
        break;
      case 2: // Games
        title = 'Games';
        subtitle = 'All the Games are listed below.';
        break;
      case 3: // Users
        title = 'Users';
        subtitle = 'Manage all platform users';
        showInviteButton = true;
        break;
      case 4: // Settings
        title = 'Settings';
        subtitle = 'Manage your app settings.';
        break;
      default:
        title = 'Welcome ${viewModel.userName},';
        subtitle = viewModel.leagueName;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                    Text(title, style: textTheme.headlineLarge),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.titleSmall?.copyWith(
                        color: brightness == Brightness.light
                            ? AppColors.textSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NotificationButton(),
                  if (showInviteButton) ...[
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to invite screen
                        Navigator.pushNamed(context, '/admin/invite');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
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
        ],
      ),
    );
  }
}

class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final brightness = Theme.of(context).brightness;
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.adminNotification);
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

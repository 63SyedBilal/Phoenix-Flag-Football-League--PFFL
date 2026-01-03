import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/screens/notification/provider/player_notification_provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/features/player/providers/player_team_provider.dart';
import 'package:pffl_managment/screens/notification/widgets/player_notification_card.dart';
import 'package:pffl_managment/screens/notification/widgets/notification_empty_state.dart';
import 'package:pffl_managment/core/widgets/custom_flushbar.dart';

class PlayerNotification extends StatelessWidget {
  const PlayerNotification({super.key});

  @override
  Widget build(BuildContext context) {
    // Using global provider from app_providers.dart
    final provider = Provider.of<PlayerNotificationProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar with back button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF000000),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Stay updated with important alerts and reminders.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: provider.isLoading
                        ? null
                        : () => provider.refresh(),
                  ),
                ],
              ),
            ),
            // Notifications list
            Expanded(child: _buildBody(context, provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PlayerNotificationProvider provider) {
    if (provider.isLoading && provider.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.notifications.isEmpty) {
      return const NotificationEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.notifications.length,
        itemBuilder: (context, index) {
          final notification = provider.notifications[index];
          return PlayerNotificationCard(
            notification: notification,
            isLoading: provider.isLoading,
            onAccept:
                notification.isPending && notification.type == 'TEAM_INVITE'
                ? () => _handleAccept(context, notification.id, provider)
                : null,
            onDecline:
                notification.isPending && notification.type == 'TEAM_INVITE'
                ? () => _handleDecline(context, notification.id, provider)
                : null,
            onPayNow:
                notification.displayMessage.toLowerCase().contains('payment') ||
                    notification.displayMessage.toLowerCase().contains('fee')
                ? () => _handlePayNow(context, notification)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _handleAccept(
    BuildContext context,
    String notificationId,
    PlayerNotificationProvider provider,
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final result = await provider.acceptNotification(notificationId);
    final success = result['success'] == true;
    final roleChanged = result['roleChanged'] == true;
    final newRole = result['newRole'];

    if (success && context.mounted) {
      if (roleChanged) {
        CustomFlushbar.showInfo(
          context,
          message:
              'Your role has been updated to $newRole. Please log in again.',
        );
        await Future.delayed(const Duration(seconds: 1));
        await authProvider.logout(context);
        if (context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
        return;
      }

      try {
        final playerTeamProvider = Provider.of<PlayerTeamProvider>(
          context,
          listen: false,
        );
        if (authProvider.userId.isNotEmpty) {
          await playerTeamProvider.refresh(userId: authProvider.userId);
        }
      } catch (e) {
        // Provider might not be in scope
      }

      await provider.refresh();
      if (context.mounted) {
        CustomFlushbar.showTopSuccess(context, message: 'Invitation accepted!');
      }
    } else if (context.mounted) {
      CustomFlushbar.showError(
        context,
        message: provider.errorMessage ?? 'Failed to accept',
      );
    }
  }

  Future<void> _handleDecline(
    BuildContext context,
    String notificationId,
    PlayerNotificationProvider provider,
  ) async {
    CustomFlushbar.showWarning(
      context,
      message: 'Decline functionality coming soon',
    );
  }

  void _handlePayNow(BuildContext context, notification) {
    CustomFlushbar.showWarning(
      context,
      message: 'Payment functionality coming soon',
    );
  }
}

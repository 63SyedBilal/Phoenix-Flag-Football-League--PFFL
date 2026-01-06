import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/screens/notification/provider/player_notification_provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/features/player/providers/player_team_provider.dart';
import 'package:pffl_managment/screens/notification/widgets/player_notification_card.dart';
import 'package:pffl_managment/screens/notification/widgets/notification_empty_state.dart';
import 'package:pffl_managment/core/widgets/custom_flushbar.dart';
import 'package:pffl_managment/core/services/notification_trigger_service.dart';
import 'package:pffl_managment/screens/notification/models/notification_model.dart';

class PlayerNotification extends StatelessWidget {
  const PlayerNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerNotificationProvider>(context);

    // Fetch notifications on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.notifications.isEmpty &&
          !provider.isLoading &&
          provider.errorMessage == null) {
        provider.fetchNotifications();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
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
                notification.isPending &&
                    (notification.type == 'TEAM_INVITE' ||
                        notification.type == 'LEAGUE_REFEREE_INVITE' ||
                        notification.type == 'LEAGUE_STATKEEPER_INVITE')
                ? () => _handleAccept(context, notification, provider)
                : null,
            onDecline:
                notification.isPending &&
                    (notification.type == 'TEAM_INVITE' ||
                        notification.type == 'LEAGUE_REFEREE_INVITE' ||
                        notification.type == 'LEAGUE_STATKEEPER_INVITE')
                ? () => _handleDecline(context, notification, provider)
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
    NotificationModel notification,
    PlayerNotificationProvider provider,
  ) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final result = await provider.acceptNotification(notification.id);
    final success = result['success'] == true;
    final roleChanged = result['roleChanged'] == true;
    final newRole = result['newRole'];

    if (success && context.mounted) {
      // Trigger notification for the sender (Captain/Admin)
      if (notification.senderId != null) {
        if (notification.type == 'TEAM_INVITE' ||
            notification.type == 'TEAM_INVITATION') {
          NotificationTriggerService.triggerPlayerJoinedTeam(
            captainId: notification.senderId!,
            playerName: authProvider.userName.isNotEmpty
                ? authProvider.userName
                : 'A player',
            teamName: notification.team ?? 'Team',
            teamId: notification.teamId ?? '',
            playerId: authProvider.userId,
          ).catchError((e) => debugPrint('Error triggering notification: $e'));
        } else if (notification.type == 'LEAGUE_REFEREE_INVITE') {
          NotificationTriggerService.triggerRefereeAcceptedInvite(
            senderId: notification.senderId!,
            refereeName: authProvider.userName,
            leagueName: notification.league ?? 'League',
          ).catchError((e) => debugPrint('Error triggering notification: $e'));
        } else if (notification.type == 'LEAGUE_STATKEEPER_INVITE') {
          NotificationTriggerService.triggerStatKeeperAcceptedInvite(
            senderId: notification.senderId!,
            statKeeperName: authProvider.userName,
            leagueName: notification.league ?? 'League',
          ).catchError((e) => debugPrint('Error triggering notification: $e'));
        }
      }

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
    NotificationModel notification,
    PlayerNotificationProvider provider,
  ) async {
    final result = await provider.rejectNotification(notification.id);
    if (result && context.mounted) {
      // Trigger notification for the sender
      if (notification.senderId != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (notification.type == 'TEAM_INVITE' ||
            notification.type == 'TEAM_INVITATION') {
          NotificationTriggerService.triggerPlayerDeclinedTeamInvite(
            captainId: notification.senderId!,
            playerName: authProvider.userName.isNotEmpty
                ? authProvider.userName
                : 'A player',
            teamName: notification.team ?? 'Team',
            teamId: notification.teamId ?? '',
          ).catchError((e) => debugPrint('Error triggering notification: $e'));
        }
      }

      await provider.refresh();
      if (context.mounted) {
        CustomFlushbar.showWarning(context, message: 'Invitation rejected.');
      }
    } else if (context.mounted) {
      CustomFlushbar.showError(
        context,
        message: provider.errorMessage ?? 'Failed to reject',
      );
    }
  }

  void _handlePayNow(BuildContext context, notification) {
    CustomFlushbar.showWarning(
      context,
      message: 'Payment functionality coming soon',
    );
  }
}

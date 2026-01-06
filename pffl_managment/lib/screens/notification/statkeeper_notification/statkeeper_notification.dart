import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/screens/notification/provider/statkeeper_notification_provider.dart';
import 'package:pffl_managment/screens/notification/widgets/notification_card.dart';
import 'package:pffl_managment/screens/notification/widgets/invitation_notification_card.dart';
import 'package:pffl_managment/screens/notification/widgets/notification_empty_state.dart';
import 'package:pffl_managment/core/widgets/custom_flushbar.dart';
import 'package:pffl_managment/core/services/notification_trigger_service.dart';
import 'package:pffl_managment/screens/notification/models/notification_model.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';

class StatKeeperNotification extends StatelessWidget {
  const StatKeeperNotification({super.key});

  @override
  Widget build(BuildContext context) {
    // Using global provider from app_providers.dart
    final provider = Provider.of<StatKeeperNotificationProvider>(context);

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
                          'Stat keeper invitations and league updates.',
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

  Widget _buildBody(
    BuildContext context,
    StatKeeperNotificationProvider provider,
  ) {
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

          if (notification.type == 'LEAGUE_STATKEEPER_INVITE') {
            return InvitationNotificationCard(
              notification: notification,
              isLoading: provider.isLoading,
              isExpanded: provider.isExpanded(notification.id),
              onToggleExpansion: () =>
                  provider.toggleExpansion(notification.id),
              onAccept: () => _handleAccept(context, notification, provider),
              onReject: () => _handleReject(context, notification, provider),
            );
          }

          return NotificationCard(
            notification: notification,
            isLoading: provider.isLoading,
            onAccept:
                notification.isPending &&
                    (notification.type == 'LEAGUE_STATKEEPER_INVITE' ||
                        notification.type == 'TEAM_INVITE')
                ? () => _handleAccept(context, notification, provider)
                : null,
            onReject:
                notification.isPending &&
                    (notification.type == 'LEAGUE_STATKEEPER_INVITE' ||
                        notification.type == 'TEAM_INVITE')
                ? () => _handleReject(context, notification, provider)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _handleAccept(
    BuildContext context,
    NotificationModel notification,
    StatKeeperNotificationProvider provider,
  ) async {
    final result = await provider.acceptNotification(notification.id);
    final success = result['success'] == true;

    if (success && context.mounted) {
      // Trigger notification for the sender (Captain/Admin)
      if (notification.senderId != null) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        NotificationTriggerService.triggerStatKeeperAcceptedInvite(
          senderId: notification.senderId!,
          statKeeperName: auth.userName.isNotEmpty
              ? auth.userName
              : 'A stat keeper',
          leagueName: notification.league ?? 'League',
        ).catchError((e) => debugPrint('Error triggering notification: $e'));
      }

      await provider.refresh();
      if (context.mounted) {
        CustomFlushbar.showTopSuccess(
          context,
          message: 'Invitation accepted successfully!',
        );
      }
    } else if (context.mounted) {
      CustomFlushbar.showError(
        context,
        message: provider.errorMessage ?? 'Failed to accept invitation',
      );
    }
  }

  Future<void> _handleReject(
    BuildContext context,
    NotificationModel notification,
    StatKeeperNotificationProvider provider,
  ) async {
    final success = await provider.rejectNotification(notification.id);

    if (success && context.mounted) {
      // Trigger notification for the sender (Captain/Admin)
      if (notification.senderId != null) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        NotificationTriggerService.triggerStatKeeperRejectedInvite(
          senderId: notification.senderId!,
          statKeeperName: auth.userName.isNotEmpty
              ? auth.userName
              : 'A stat keeper',
          leagueName: notification.league ?? 'League',
        ).catchError((e) => debugPrint('Error triggering notification: $e'));
      }

      CustomFlushbar.showWarning(context, message: 'Invitation rejected.');
    } else if (context.mounted) {
      CustomFlushbar.showError(
        context,
        message: provider.errorMessage ?? 'Failed to reject invitation',
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/screens/notification/provider/statkeeper_notification_provider.dart';
import 'package:pffl_managment/screens/notification/widgets/notification_card.dart';
import 'package:pffl_managment/screens/notification/widgets/notification_empty_state.dart';
import 'package:pffl_managment/core/widgets/custom_flushbar.dart';

class StatKeeperNotification extends StatelessWidget {
  const StatKeeperNotification({super.key});

  @override
  Widget build(BuildContext context) {
    // Using global provider from app_providers.dart
    final provider = Provider.of<StatKeeperNotificationProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.isLoading ? null : () => provider.refresh(),
          ),
        ],
      ),
      body: _buildBody(context, provider),
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
          return NotificationCard(
            notification: notification,
            isLoading: provider.isLoading,
            onAccept:
                notification.isPending &&
                    (notification.type == 'LEAGUE_STATKEEPER_INVITE' ||
                        notification.type == 'TEAM_INVITE')
                ? () => _handleAccept(context, notification.id, provider)
                : null,
            onReject:
                notification.isPending &&
                    (notification.type == 'LEAGUE_STATKEEPER_INVITE' ||
                        notification.type == 'TEAM_INVITE')
                ? () => _handleReject(context, notification.id, provider)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _handleAccept(
    BuildContext context,
    String notificationId,
    StatKeeperNotificationProvider provider,
  ) async {
    final result = await provider.acceptNotification(notificationId);
    final success = result['success'] == true;

    if (success && context.mounted) {
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
    String notificationId,
    StatKeeperNotificationProvider provider,
  ) async {
    final success = await provider.rejectNotification(notificationId);

    if (success && context.mounted) {
      CustomFlushbar.showWarning(context, message: 'Invitation rejected.');
    } else if (context.mounted) {
      CustomFlushbar.showError(
        context,
        message: provider.errorMessage ?? 'Failed to reject invitation',
      );
    }
  }
}

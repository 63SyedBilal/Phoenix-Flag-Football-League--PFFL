import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/screens/notification/provider/captain_notification_provider.dart';
import 'package:pffl_managment/screens/notification/models/notification_model.dart';
import 'package:pffl_managment/features/captain/providers/captain_team_provider.dart';
import 'package:pffl_managment/screens/notification/widgets/notification_empty_state.dart';
import 'package:pffl_managment/core/widgets/custom_flushbar.dart';

class CaptainNotification extends StatelessWidget {
  const CaptainNotification({super.key});

  @override
  Widget build(BuildContext context) {
    // Using global provider from app_providers.dart
    final provider = Provider.of<CaptainNotificationProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
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
                          'Manage your team and league invitations',
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

  Widget _buildBody(
    BuildContext context,
    CaptainNotificationProvider provider,
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
          final isPending = notification.isPending;
          final isInviteType =
              notification.type == 'LEAGUE_TEAM_INVITE' ||
              notification.type == 'TEAM_INVITE';
          final shouldShowButtons = isPending && isInviteType;

          return _NotificationCard(
            notification: notification,
            isProcessing: provider.isLoading,
            showButtons: shouldShowButtons,
            onAccept: shouldShowButtons
                ? () => _handleAccept(context, notification.id, provider)
                : null,
            onReject: shouldShowButtons
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
    CaptainNotificationProvider provider,
  ) async {
    try {
      final result = await provider.acceptNotification(notificationId);
      final success = result['success'] == true;

      if (success && context.mounted) {
        await provider.refresh();

        try {
          final captainTeamProvider = Provider.of<CaptainTeamProvider>(
            context,
            listen: false,
          );
          await captainTeamProvider.refresh();
        } catch (e) {}

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
    } catch (e) {
      if (context.mounted) {
        CustomFlushbar.showError(
          context,
          message: 'Error: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    }
  }

  Future<void> _handleReject(
    BuildContext context,
    String notificationId,
    CaptainNotificationProvider provider,
  ) async {
    try {
      final success = await provider.rejectNotification(notificationId);

      if (success && context.mounted) {
        CustomFlushbar.showWarning(context, message: 'Invitation rejected.');
      } else if (context.mounted) {
        CustomFlushbar.showError(
          context,
          message: provider.errorMessage ?? 'Failed to reject invitation',
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomFlushbar.showError(
          context,
          message: 'Error: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isProcessing;
  final bool showButtons;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _NotificationCard({
    required this.notification,
    required this.isProcessing,
    required this.showButtons,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isPending
              ? Colors.blue.shade200
              : (notification.isAccepted
                    ? Colors.green.shade200
                    : Colors.grey.shade300),
          width: notification.isPending ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  image: notification.teamImage != null
                      ? DecorationImage(
                          image: NetworkImage(notification.teamImage!),
                          fit: BoxFit.cover,
                        )
                      : notification.leagueLogo != null
                      ? DecorationImage(
                          image: NetworkImage(notification.leagueLogo!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    notification.teamImage == null &&
                        notification.leagueLogo == null
                    ? Icon(
                        notification.type == 'TEAM_INVITE'
                            ? Icons.group
                            : Icons.emoji_events,
                        color: Colors.grey[600],
                        size: 28,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.displayMessage,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeAgo(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (notification.format != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          notification.format!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: notification.isPending
                      ? Colors.blue.shade50
                      : (notification.isAccepted
                            ? Colors.green.shade50
                            : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  notification.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: notification.isPending
                        ? Colors.blue.shade700
                        : (notification.isAccepted
                              ? Colors.green.shade700
                              : Colors.grey.shade700),
                  ),
                ),
              ),
            ],
          ),
          if (onAccept != null || onReject != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (onReject != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isProcessing ? null : onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(
                          color: Colors.red.shade700,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (onAccept != null && onReject != null)
                  const SizedBox(width: 12),
                if (onAccept != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Accept',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7} weeks ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}

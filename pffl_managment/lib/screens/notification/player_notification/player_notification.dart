import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/notification_provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/features/player/providers/player_team_provider.dart';
import 'package:pffl_managment/screens/notification/widgets/player_notification_card.dart';
import 'package:pffl_managment/screens/notification/widgets/notification_empty_state.dart';

class PlayerNotification extends StatefulWidget {
  const PlayerNotification({super.key});

  @override
  State<PlayerNotification> createState() => _PlayerNotificationState();
}

class _PlayerNotificationState extends State<PlayerNotification> {
  String? _processingNotificationId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationProvider(),
      child: Scaffold(
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
                    Consumer<NotificationProvider>(
                      builder: (context, provider, _) {
                        return IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: provider.isLoading
                              ? null
                              : () => provider.refresh(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Notifications list
              Expanded(
                child: Consumer<NotificationProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.errorMessage != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
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
                          final isProcessing =
                              _processingNotificationId == notification.id;

                          return PlayerNotificationCard(
                            notification: notification,
                            isLoading: isProcessing,
                            onAccept:
                                notification.isPending &&
                                    notification.type == 'TEAM_INVITE'
                                ? () => _handleAccept(context, notification.id)
                                : null,
                            onDecline:
                                notification.isPending &&
                                    notification.type == 'TEAM_INVITE'
                                ? () => _handleDecline(context, notification.id)
                                : null,
                            onPayNow:
                                notification.displayMessage
                                        .toLowerCase()
                                        .contains('payment') ||
                                    notification.displayMessage
                                        .toLowerCase()
                                        .contains('fee')
                                ? () => _handlePayNow(context, notification)
                                : null,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAccept(
    BuildContext context,
    String notificationId,
  ) async {
    setState(() {
      _processingNotificationId = notificationId;
    });

    try {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final result = await notificationProvider.acceptNotification(
        notificationId,
      );
      final success = result['success'] == true;
      final roleChanged = result['roleChanged'] == true;
      final newRole = result['newRole'];

      if (success && context.mounted) {
        // If role was changed (free-agent to player), logout user
        if (roleChanged) {
          print(
            '🔄 Role changed from free-agent to $newRole. Logging out user...',
          );

          // Show message to user
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Your role has been updated to $newRole. Please log in again to continue.',
                ),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 3),
              ),
            );
          }

          // Wait a bit for user to see the message
          await Future.delayed(const Duration(seconds: 1));

          // Logout user
          await authProvider.logout(context);

          // Navigate to login screen
          if (context.mounted) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          }

          return; // Exit early since we've logged out
        }
        // Get PlayerTeamProvider from context if available
        try {
          final playerTeamProvider = Provider.of<PlayerTeamProvider>(
            context,
            listen: false,
          );

          // Refresh player team data after accepting invitation
          if (authProvider.userId.isNotEmpty) {
            await playerTeamProvider.refresh(userId: authProvider.userId);
          }
        } catch (e) {
          // Provider not available in context, that's okay
        }

        // Refresh notifications to update status
        await notificationProvider.refresh();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invitation accepted successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else if (context.mounted) {
        final errorMsg =
            notificationProvider.errorMessage ??
            'Failed to accept invitation. Please try again.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {

      if (context.mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMsg'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingNotificationId = null;
        });
      }
    }
  }

  Future<void> _handleDecline(
    BuildContext context,
    String notificationId,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Decline functionality coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _handlePayNow(BuildContext context, notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment functionality coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}


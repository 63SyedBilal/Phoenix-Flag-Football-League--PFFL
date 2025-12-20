import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/notification_provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/screens/notification/widgets/notification_card.dart';
import 'package:pffl_managment/screens/notification/widgets/notification_empty_state.dart';

class FreeAgentNotification extends StatefulWidget {
  const FreeAgentNotification({super.key});

  @override
  State<FreeAgentNotification> createState() => _FreeAgentNotificationState();
}

class _FreeAgentNotificationState extends State<FreeAgentNotification> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationProvider(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            Consumer<NotificationProvider>(
              builder: (context, provider, _) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: provider.isLoading ? null : () => provider.refresh(),
                );
              },
            ),
          ],
        ),
        body: Consumer<NotificationProvider>(
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
                    onAccept: notification.isPending &&
                            (notification.type == 'LEAGUE_REFEREE_INVITE' ||
                             notification.type == 'TEAM_INVITE')
                        ? () => _handleAccept(context, notification.id)
                        : null,
                    onReject: notification.isPending &&
                            (notification.type == 'LEAGUE_REFEREE_INVITE' ||
                             notification.type == 'TEAM_INVITE')
                        ? () => _handleReject(context, notification.id)
                        : null,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleAccept(BuildContext context, String notificationId) async {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    final result = await provider.acceptNotification(notificationId);
    final success = result['success'] == true;
    final roleChanged = result['roleChanged'] == true;
    final newRole = result['newRole'];

    if (success && context.mounted) {
      // If role was changed (free-agent to player), logout user
      if (roleChanged) {
        print('🔄 Role changed from free-agent to $newRole. Logging out user...');
        
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
        
        // Get auth provider and logout
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout(context);
        
        // Navigate to login screen
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
        
        return; // Exit early since we've logged out
      }
      
      // Refresh notifications to update status
      await provider.refresh();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation accepted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to accept invitation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleReject(BuildContext context, String notificationId) async {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    final success = await provider.rejectNotification(notificationId);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation rejected successfully!'),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to reject invitation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/models/notification_model.dart';
import 'package:pffl_managment/core/providers/notification_provider.dart';
import 'package:pffl_managment/features/free_agent/widgets/free_agent_notification_card.dart';
import 'package:pffl_managment/screens/notification/widgets/notification_empty_state.dart';

class FreeAgentNotificationsScreen extends StatelessWidget {
  const FreeAgentNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the global NotificationProvider
    final provider = Provider.of<NotificationProvider>(context);

    // Filter notifications for free agents - focus on team invitations
    final freeAgentNotificationTypes = [
      'TEAM_INVITE',
      'LEAGUE_INVITE',
      'TEAM_INVITATION_AS_PLAYER',
      'LEAGUE_REGISTRATION_APPROVED',
      'LEAGUE_REGISTRATION_REJECTED',
      'PAYMENT_REMINDER',
      'PAYMENT_CONFIRMATION',
    ];

    final notifications = provider.notifications
        .where((n) => freeAgentNotificationTypes.contains(n.type))
        .toList();

    // Mark as read when opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.markAllAsRead();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: ArrowBackButton(onPressed: () => Navigator.pop(context)),
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.isLoading ? null : () => provider.refresh(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "Stay updated with important alerts and reminders.",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),

              /// NOTIFICATIONS LIST
              Expanded(child: _buildList(context, provider, notifications)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    NotificationProvider provider,
    List<NotificationModel> notifications,
  ) {
    if (provider.isLoading && notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (notifications.isEmpty) {
      return const NotificationEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return FreeAgentNotificationCard(notification: notification);
        },
      ),
    );
  }
}

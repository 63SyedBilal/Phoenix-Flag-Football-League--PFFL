import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/models/notification_model.dart';
import 'package:pffl_managment/core/providers/notification_provider.dart';

/// Widget for displaying free agent specific notification cards with team invitation details
class FreeAgentNotificationCard extends StatefulWidget {
  final NotificationModel notification;

  const FreeAgentNotificationCard({super.key, required this.notification});

  @override
  State<FreeAgentNotificationCard> createState() =>
      _FreeAgentNotificationCardState();
}

class _FreeAgentNotificationCardState extends State<FreeAgentNotificationCard> {
  bool _isLoading = false;
  bool _showLeagueDetails = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NotificationProvider>();
    final notification = widget.notification;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isPending
              ? Colors.blue.shade200
              : Colors.grey.shade300,
          width: notification.isPending ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _getNotificationTitle(notification),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  _formatDate(notification.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Helper text
            if (notification.type == 'TEAM_INVITE' ||
                notification.type == 'TEAM_INVITATION_AS_PLAYER')
              Text(
                "Helper text",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),

            const SizedBox(height: 12),

            // Main message
            Text(
              notification.displayMessage,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // View League Details button (if applicable)
            if (notification.league != null &&
                (notification.type == 'TEAM_INVITE' ||
                    notification.type == 'TEAM_INVITATION_AS_PLAYER'))
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showLeagueDetails = !_showLeagueDetails;
                  });
                },
                child: Text(
                  "View League Details",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

            // League details (expandable)
            if (_showLeagueDetails && notification.league != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.leagueName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Active",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildLeagueDetailRow(
                      "Format:",
                      notification.format ?? "5v5",
                    ),
                    _buildLeagueDetailRow("League Fee:", "\$250"),
                    _buildLeagueDetailRow("Start Date:", "10 December 2025"),
                    _buildLeagueDetailRow("End Date:", "25 February 2026"),
                  ],
                ),
              ),
            ],

            // Action buttons for pending invitations
            if (notification.isPending &&
                (notification.type == 'TEAM_INVITE' ||
                    notification.type == 'TEAM_INVITATION_AS_PLAYER')) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _handleDecline(provider),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade700),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Decline',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _handleAccept(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Accept Invite',
                              style: TextStyle(
                                fontSize: 14,
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
      ),
    );
  }

  Widget _buildLeagueDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getNotificationTitle(NotificationModel notification) {
    switch (notification.type) {
      case 'TEAM_INVITE':
      case 'TEAM_INVITATION_AS_PLAYER':
        return 'Team Invitation — As Player';
      case 'LEAGUE_INVITE':
        return 'League Invitation';
      case 'PAYMENT_REMINDER':
        return 'Payment Reminder';
      case 'PAYMENT_CONFIRMATION':
        return 'Payment Confirmed';
      default:
        return 'Notification';
    }
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${dateTime.day.toString().padLeft(2, '0')} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  Future<void> _handleAccept(NotificationProvider provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Call the provider's accept method
      final result = await provider.acceptNotification(widget.notification.id);

      if (result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept invitation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDecline(NotificationProvider provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Call the provider's decline method
      final success = await provider.rejectNotification(widget.notification.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation declined.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to decline invitation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

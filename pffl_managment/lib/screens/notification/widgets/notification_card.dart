import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/models/notification_model.dart';
import 'package:pffl_managment/core/providers/notification_provider.dart';

/// Widget for displaying a single notification card
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool isLoading;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onAccept,
    this.onReject,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final provider = context.read<NotificationProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: brightness == Brightness.light ? Colors.white : Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isPending
              ? Colors.blue.shade200
              : (notification.isAccepted
                    ? Colors.green.shade200
                    : Colors.grey.shade300),
          width: notification.isPending ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team/League image or default icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
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
                            : (notification.type == 'STATS_APPROVAL_REQUEST'
                                  ? Icons.analytics
                                  : (notification.type == 'GAME_ASSIGNED'
                                        ? Icons.sports_soccer
                                        : Icons.emoji_events)),
                        color: Colors.grey[600],
                        size: 24,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Use rich text formatting for GAME_ASSIGNED notifications
                    notification.type == 'GAME_ASSIGNED'
                        ? _buildGameAssignmentMessage(
                            context,
                            notification.displayMessage,
                          )
                        : Text(
                            notification.displayMessage,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    const SizedBox(height: 4),
                    Text(
                      _getTimeAgo(notification.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    if (notification.format != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          notification.format!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    fontWeight: FontWeight.w600,
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

          // Action buttons for pending notifications
          if (notification.isPending) ...[
            const SizedBox(height: 12),
            if (notification.type == 'STATS_APPROVAL_REQUEST') ...[
              // Special Action for Stats Approval
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final success = await provider.approveStats(
                            notification.id,
                          );
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Stats approved and published successfully!',
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
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
                          'Approve & Publish',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ] else if (onAccept != null || onReject != null) ...[
              // Standard Invite buttons
              Row(
                children: [
                  if (onReject != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading ? null : onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade700),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
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
                        onPressed: isLoading ? null : onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
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
                                'Accept',
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

  /// Build formatted message for game assignment notifications with colored text
  Widget _buildGameAssignmentMessage(BuildContext context, String message) {
    final theme = Theme.of(context);

    // Parse the message to extract different parts
    // Expected format: "You're the [Role] for [Game]. Match starts [Date] at [Time]. Venue: [Venue]."

    // Use regex to find date, time, and venue patterns
    final dateTimeRegex = RegExp(r'Match starts (.+?) at (.+?)\.');
    final venueRegex = RegExp(r'Venue: (.+?)\.');
    final roleRegex = RegExp(r"You're the (.+?) for (.+?)\.");

    final dateTimeMatch = dateTimeRegex.firstMatch(message);
    final venueMatch = venueRegex.firstMatch(message);
    final roleMatch = roleRegex.firstMatch(message);

    if (dateTimeMatch != null && venueMatch != null && roleMatch != null) {
      final role = roleMatch.group(1) ?? '';
      final game = roleMatch.group(2) ?? '';
      final date = dateTimeMatch.group(1) ?? '';
      final time = dateTimeMatch.group(2) ?? '';
      final venue = venueMatch.group(1) ?? '';

      return RichText(
        text: TextSpan(
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
          children: [
            TextSpan(text: "You're the "),
            TextSpan(
              text: role,
              style: TextStyle(
                color: role.contains('Referee')
                    ? Colors.orange.shade700
                    : Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: " for "),
            TextSpan(
              text: game,
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: ". Match starts "),
            TextSpan(
              text: date,
              style: TextStyle(
                color: Colors.purple.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: " at "),
            TextSpan(
              text: time,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: ". Venue: "),
            TextSpan(
              text: venue,
              style: TextStyle(
                color: Colors.teal.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: "."),
          ],
        ),
      );
    }

    // Fallback to regular text if parsing fails
    return Text(
      message,
      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

import 'package:pffl_managment/core/models/notification_model.dart';

/// Helper class for notification-related logic like filtering
class NotificationHelper {
  /// Filter notifications based on user role
  static List<NotificationModel> filterNotificationsByRole(
    List<NotificationModel> allNotifications,
    String userRole,
  ) {
    final normalizedRole = userRole.toLowerCase().replaceAll('-', '');

    return allNotifications.where((notification) {
      final type = notification.type.toLowerCase();
      final message = (notification.message ?? '').toLowerCase();

      switch (normalizedRole) {
        case 'player':
          return _isPlayerNotification(type, message);
        case 'captain':
          return _isCaptainNotification(type, message);
        case 'admin':
        case 'superadmin':
          return _isAdminNotification(type, message);
        case 'referee':
          return _isRefereeNotification(type, message);
        case 'statkeeper':
          return _isStatKeeperNotification(type, message);
        case 'freeagent':
          return _isFreeAgentNotification(type, message);
        default:
          return type.contains('general') || type.contains('system');
      }
    }).toList();
  }

  static bool _isPlayerNotification(String type, String message) {
    return type.contains('team_invite') ||
        type.contains('payment') ||
        type.contains('league') ||
        type.contains('match') ||
        message.contains('team') ||
        message.contains('match');
  }

  static bool _isCaptainNotification(String type, String message) {
    return type.contains('team') ||
        type.contains('league') ||
        type.contains('payment') ||
        type.contains('captain') ||
        message.contains('invitation') ||
        message.contains('registered');
  }

  static bool _isAdminNotification(String type, String message) {
    return type.contains('admin') ||
        type.contains('system') ||
        type.contains('payment') ||
        type.contains('registration') ||
        type.contains('stats_approval') ||
        message.contains('refund') ||
        message.contains('report');
  }

  static bool _isRefereeNotification(String type, String message) {
    return type.contains('match') ||
        type.contains('referee') ||
        type.contains('game_assigned') ||
        message.contains('scheduled');
  }

  static bool _isStatKeeperNotification(String type, String message) {
    return type.contains('stats') ||
        type.contains('match') ||
        type.contains('game_assigned') ||
        message.contains('scheduled');
  }

  static bool _isFreeAgentNotification(String type, String message) {
    return type.contains('league_invite') ||
        type.contains('team_invite') ||
        type.contains('free_agent') ||
        message.contains('verified') ||
        message.contains('viewed');
  }
}

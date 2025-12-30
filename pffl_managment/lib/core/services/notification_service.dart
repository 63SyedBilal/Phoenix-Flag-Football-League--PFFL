import 'package:pffl_managment/core/models/notification_model.dart';
import 'notification_api_service.dart';
import 'notification_sender_service.dart';
import 'notification_helper.dart';

/// Legacy Service facade for notification-related logic.
/// Delegating to split services to adhere to 300-line limit.
class NotificationService {
  // --- Core API ---
  static Future<List<NotificationModel>> getAllNotifications() =>
      NotificationApiService.getAllNotifications();

  static Future<Map<String, dynamic>> acceptNotification(String id) =>
      NotificationApiService.acceptNotification(id);

  static Future<bool> rejectNotification(String id) =>
      NotificationApiService.rejectNotification(id);

  // --- Role Specific Getters ---
  static Future<List<NotificationModel>> getPlayerNotifications() =>
      NotificationApiService.getNotificationsByRole('player');

  static Future<List<NotificationModel>> getCaptainNotifications() =>
      NotificationApiService.getNotificationsByRole('captain');

  static Future<List<NotificationModel>> getAdminNotifications() =>
      NotificationApiService.getNotificationsByRole('admin');

  static Future<List<NotificationModel>> getRefereeNotifications() =>
      NotificationApiService.getNotificationsByRole('referee');

  static Future<List<NotificationModel>> getStatKeeperNotifications() =>
      NotificationApiService.getNotificationsByRole('statkeeper');

  static Future<List<NotificationModel>> getFreeAgentNotifications() =>
      NotificationApiService.getNotificationsByRole('freeagent');

  static Future<List<NotificationModel>> getNotificationsByRole(String role) =>
      NotificationApiService.getNotificationsByRole(role);

  // --- Sending ---
  static Future<bool> sendPaymentReminder({
    required String playerId,
    required String leagueId,
    required String message,
  }) async {
    return await NotificationSenderService.sendNotification(
      receiverId: playerId,
      type: 'PAYMENT_REMINDER',
      message: message,
      leagueId: leagueId,
    );
  }

  static Future<bool> sendNotification({
    required String receiverId,
    required String type,
    required String message,
    String? leagueId,
    String? teamId,
    String? matchId,
    String? senderId,
  }) => NotificationSenderService.sendNotification(
    receiverId: receiverId,
    type: type,
    message: message,
    leagueId: leagueId,
    teamId: teamId,
    matchId: matchId,
    senderId: senderId,
  );

  static Future<bool> sendAdminNotification({required String message}) =>
      NotificationSenderService.sendAdminNotification(message: message);

  // --- Filtering ---
  static List<NotificationModel> filterNotificationsByRole(
    List<NotificationModel> all,
    String role,
  ) => NotificationHelper.filterNotificationsByRole(all, role);
}

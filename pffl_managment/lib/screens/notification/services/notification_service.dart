import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/config/app_config.dart';
import '../models/notification_model.dart';

class NotificationService {
  /// Fetch all notifications for the current user
  static Future<List<NotificationModel>> getUserNotifications({
    String? role,
  }) async {
    try {
      final dio = await AuthService.getWorkingDio();
      // Use AppConfig endpoint
      final endpoint = role != null
          ? '${AppConfig.notificationAllEndpoint}?role=$role'
          : AppConfig.notificationAllEndpoint;

      final response = await dio.get(endpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      // Return dummy data for testing purposes if API fails
      return _getDummyNotifications();
    }
  }

  /// Mark a notification as read
  static Future<bool> markAsRead(String notificationId) async {
    try {
      final dio = await AuthService.getWorkingDio();
      final response = await dio.put('/notification/$notificationId/read');
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  /// Delete a notification
  static Future<bool> deleteNotification(String notificationId) async {
    try {
      final dio = await AuthService.getWorkingDio();
      final response = await dio.delete('/notification/$notificationId');
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  /// Respond to an invitation (accept/decline)
  static Future<Map<String, dynamic>> respondToInvitation(
    String notificationId,
    bool accept,
  ) async {
    try {
      final dio = await AuthService.getWorkingDio();
      // Backend expects PUT /notification/accept/:id or /notification/reject/:id
      final action = accept ? 'accept' : 'reject';
      final endpoint = '/notification/$action/$notificationId';

      final response = await dio.put(endpoint);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'roleChanged': response.data['roleChanged'] ?? false,
          'newRole': response.data['newRole'],
        };
      }
      return {
        'success': false,
        'error': response.data?['error'] ?? 'Failed to respond',
      };
    } catch (e) {
      print('Error responding to invitation: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Helper for dummy data during dev
  static List<NotificationModel> _getDummyNotifications() {
    return [
      NotificationModel(
        id: '1',
        title: 'Welcome to PFFL',
        body: 'Your account has been successfully created.',
        type: 'success',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'read',
      ),
      NotificationModel(
        id: '2',
        title: 'Team Invite',
        body: 'You have been invited to join "Phoenix Flames".',
        type: 'TEAM_INVITE',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'pending',
        team: 'Phoenix Flames',
        league: 'Summer League 2024',
      ),
      NotificationModel(
        id: '3',
        title: 'Game Assignment',
        body:
            "You're the Referee for Eagles vs Hawks. Match starts 2024-05-20 at 18:00. Venue: Central Park.",
        type: 'GAME_ASSIGNED',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: 'unread',
      ),
    ];
  }
}

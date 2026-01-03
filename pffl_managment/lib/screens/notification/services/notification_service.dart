import 'package:pffl_managment/core/services/auth_service.dart';
import '../models/notification_model.dart';

class NotificationService {
  /// Fetch all notifications for the current user
  static Future<List<NotificationModel>> getUserNotifications() async {
    try {
      final dio = await AuthService.getWorkingDio();
      // Assuming endpoint is /notifications/user or similar based on role
      // For now using /notifications as a generic endpoint
      final response = await dio.get('/notifications');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // Fallback to empty list or throw depending on requirements
      // For development, we might want to return some dummy data if API fails
      // return _getDummyNotifications();
      print('Error fetching notifications: $e');
      // Return dummy data for testing purposes if API fails
      return _getDummyNotifications();
    }
  }

  /// Mark a notification as read
  static Future<bool> markAsRead(String notificationId) async {
    try {
      final dio = await AuthService.getWorkingDio();
      final response = await dio.put('/notifications/$notificationId/read');
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
      final response = await dio.delete('/notifications/$notificationId');
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
      final response = await dio.post(
        '/notifications/$notificationId/respond',
        data: {'accept': accept},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'roleChanged': response.data['roleChanged'],
          'newRole': response.data['newRole'],
        };
      }
      return {'success': false, 'error': 'Failed to respond'};
    } catch (e) {
      // Mock success for testing if API fails
      // return {'success': true, 'roleChanged': false};
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

import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/config/app_config.dart';
import '../models/notification_model.dart';

class NotificationService {
  /// Fetch all notifications for the current user
  static Future<List<NotificationModel>> getUserNotifications({
    String? role,
    String? userId, // Added for filtering
  }) async {
    try {
      final dio = await AuthService.getWorkingDio();

      // We are fetching all notifications but will filter them by userId in the frontend
      // to ensure only targeted notifications are shown to the correct user.
      final endpoint = AppConfig.notificationAllEndpoint;

      print('📬 [NOTIFICATION SERVICE] Fetching notifications for user...');
      final response = await dio.get(endpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> rawData = [];

        if (data is Map && data['data'] != null) {
          rawData = data['data'] as List;
        } else if (data is List) {
          rawData = data;
        } else if (data is Map) {
          data.forEach((key, value) {
            if (value is List) rawData = value;
          });
        }

        final notifications = rawData
            .map((json) {
              try {
                return NotificationModel.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                return null;
              }
            })
            .whereType<NotificationModel>()
            .where((notification) {
              // Targeted Filtering Logic:
              // 1. If notification has a receiverId, it must match the current userId
              // 2. If no receiverId, we treat it as a general notification for that role (optional)

              if (userId != null &&
                  notification.receiverId != null &&
                  notification.receiverId!.isNotEmpty &&
                  notification.receiverId != userId) {
                return false;
              }

              return true;
            })
            .toList();

        return notifications;
      }
      return [];
    } catch (e) {
      print('❌ [NOTIFICATION SERVICE] Exception during fetch: $e');
      return [];
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

  /// Approve match stats
  static Future<bool> approveStats(
    String notificationId, {
    String? matchId,
  }) async {
    try {
      final dio = await AuthService.getWorkingDio();
      final response = await dio.post(
        '/stats/approve',
        data: {'notificationId': notificationId, 'matchId': matchId},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error approving stats: $e');
      return false;
    }
  }

  /// Reject/Send back match stats
  static Future<bool> rejectStats(
    String notificationId, {
    String? reason,
    String? matchId,
  }) async {
    try {
      final dio = await AuthService.getWorkingDio();
      final response = await dio.post(
        '/stats/reject',
        data: {
          'notificationId': notificationId,
          'reason': reason,
          'matchId': matchId,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error rejecting stats: $e');
      return false;
    }
  }
}

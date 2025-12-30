import 'package:dio/dio.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/models/notification_model.dart';
import 'notification_helper.dart';

/// Service for core notification API calls (GET and PUT)
class NotificationApiService {
  /// Get Dio instance with authentication token
  static Future<Dio> _getAuthenticatedDio() async {
    return await AuthService.getWorkingDio();
  }

  /// Get all notifications for logged-in user
  static Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/notification/all');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> rawList = [];

        if (data is Map && data.containsKey('data')) {
          rawList = data['data'] as List? ?? [];
        } else if (data is List) {
          rawList = data;
        }

        return rawList
            .map((json) {
              try {
                return NotificationModel.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                return null;
              }
            })
            .whereType<NotificationModel>()
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Accept a notification/invitation
  static Future<Map<String, dynamic>> acceptNotification(
    String notificationId,
  ) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.put('/notification/accept/$notificationId');

      if (response.statusCode == 200) {
        final responseData = response.data;
        return {
          'success': true,
          'roleChanged': responseData['roleChanged'] ?? false,
          'newRole': responseData['newRole'],
          'message':
              responseData['message'] ?? 'Invitation accepted successfully!',
        };
      } else {
        throw Exception(
          response.data?['error'] ?? 'Failed to accept notification',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ??
            e.response?.data?['message'] ??
            'Network error',
      );
    } catch (e) {
      throw Exception('Failed to accept notification: $e');
    }
  }

  /// Reject a notification/invitation
  static Future<bool> rejectNotification(String notificationId) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.put('/notification/reject/$notificationId');
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ??
            e.response?.data?['message'] ??
            'Network error',
      );
    } catch (e) {
      throw Exception('Failed to reject notification: $e');
    }
  }

  /// Get notifications for a specific role
  static Future<List<NotificationModel>> getNotificationsByRole(
    String role,
  ) async {
    final all = await getAllNotifications();
    return NotificationHelper.filterNotificationsByRole(all, role);
  }
}

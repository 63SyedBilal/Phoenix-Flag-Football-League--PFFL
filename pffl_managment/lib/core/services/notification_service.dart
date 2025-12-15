import 'package:dio/dio.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

/// Service for notification-related API calls
class NotificationService {
  /// Get Dio instance with authentication token and working URL
  static Future<Dio> _getAuthenticatedDio() async {
    // Use AuthService's working Dio instance which has the correct URL
    return await AuthService.getWorkingDio();
  }

  /// Get all notifications for logged-in user
  /// GET /api/notification/all
  static Future<List<Map<String, dynamic>>> getAllNotifications() async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/notification/all');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        } else if (data['data'] != null) {
          // Handle case where success field might not be present
          return (data['data'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        print('Failed to fetch notifications: ${response.statusMessage}');
        return [];
      }
    } on DioException catch (e) {
      print('Error fetching notifications: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      return [];
    } catch (e) {
      print('General error fetching notifications: $e');
      return [];
    }
  }

  /// Accept a notification/invitation
  /// PUT /api/notification/accept/:notificationId
  /// Returns true on success, throws exception on error
  static Future<bool> acceptNotification(String notificationId) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.put(
        AppConfig.getNotificationAcceptEndpoint(notificationId),
      );

      if (response.statusCode == 200) {
        print('✅ Notification accepted successfully');
        return true;
      } else {
        throw Exception(
          'Failed to accept notification: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['error'] ?? 
          'Failed to accept notification: ${e.message}';
      print('❌ Error accepting notification: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('❌ General error accepting notification: $e');
      throw Exception('Failed to accept notification: ${e.toString()}');
    }
  }
}

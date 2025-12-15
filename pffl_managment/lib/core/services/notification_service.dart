import 'package:dio/dio.dart';
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
}

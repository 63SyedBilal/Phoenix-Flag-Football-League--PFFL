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
      print('📡 [NotificationService] Fetching all notifications...');
      final dio = await _getAuthenticatedDio();
      print('📡 [NotificationService] Calling endpoint: /notification/all');
      final response = await dio.get('/notification/all');

      print('📡 [NotificationService] Response status: ${response.statusCode}');
      print('📡 [NotificationService] Response data keys: ${response.data?.keys}');

      if (response.statusCode == 200) {
        final data = response.data;
        print('📡 [NotificationService] Response success: ${data['success']}');
        print('📡 [NotificationService] Response data type: ${data['data']?.runtimeType}');
        print('📡 [NotificationService] Response data length: ${(data['data'] as List?)?.length ?? 0}');
        
        if (data['success'] == true && data['data'] != null) {
          final notifications = (data['data'] as List).cast<Map<String, dynamic>>();
          print('✅ [NotificationService] Returning ${notifications.length} notifications');
          notifications.forEach((n) {
            print('  📋 Notification: ${n['type']} - ${n['_id']}');
          });
          return notifications;
        } else if (data['data'] != null) {
          // Handle case where success field might not be present
          final notifications = (data['data'] as List).cast<Map<String, dynamic>>();
          print('✅ [NotificationService] Returning ${notifications.length} notifications (no success field)');
          return notifications;
        }
        print('⚠️ [NotificationService] No notifications found in response');
        return [];
      } else {
        print('❌ [NotificationService] Failed to fetch notifications: ${response.statusMessage}');
        return [];
      }
    } on DioException catch (e) {
      print('❌ [NotificationService] DioException: ${e.message}');
      if (e.response != null) {
        print('❌ [NotificationService] Error response status: ${e.response?.statusCode}');
        print('❌ [NotificationService] Error response data: ${e.response?.data}');
      }
      return [];
    } catch (e) {
      print('❌ [NotificationService] General error: $e');
      return [];
    }
  }

  /// Accept a notification/invitation
  /// PUT /api/notification/accept/:notificationId
  /// Returns Map with success status and roleChanged flag, throws exception on error
  static Future<Map<String, dynamic>> acceptNotification(String notificationId) async {
    try {
      print('📡 Accepting notification: $notificationId');
      final dio = await _getAuthenticatedDio();
      
      // Use the endpoint format: /notification/accept/:notificationId
      final endpoint = '/notification/accept/$notificationId';
      print('📡 Endpoint: $endpoint');
      print('📡 Full URL: ${dio.options.baseUrl}$endpoint');
      
      final response = await dio.put(endpoint);

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response data: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ Notification accepted successfully');
        final responseData = response.data;
        return {
          'success': true,
          'roleChanged': responseData['roleChanged'] ?? false,
          'newRole': responseData['newRole'],
          'message': responseData['message'] ?? 'Invitation accepted successfully!'
        };
      } else {
        final errorMsg = response.data?['error'] ?? response.statusMessage ?? 'Unknown error';
        print('❌ Failed to accept notification: $errorMsg');
        throw Exception('Failed to accept notification: $errorMsg');
      }
    } on DioException catch (e) {
      print('❌ DioException type: ${e.type}');
      print('❌ DioException message: ${e.message}');
      
      if (e.response != null) {
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
        
        final errorMessage = e.response?.data?['error'] ?? 
            e.response?.data?['message'] ??
            'Failed to accept notification: ${e.message}';
        print('❌ Error message: $errorMessage');
        throw Exception(errorMessage);
      } else {
        final errorMessage = 'Network error: ${e.message}';
        print('❌ Network error: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ General error accepting notification: $e');
      throw Exception('Failed to accept notification: ${e.toString()}');
    }
  }

  /// Reject a notification/invitation
  /// PUT /api/notification/reject/:notificationId
  /// Returns true on success, throws exception on error
  static Future<bool> rejectNotification(String notificationId) async {
    try {
      print('📡 Rejecting notification: $notificationId');
      final dio = await _getAuthenticatedDio();
      
      // Use the endpoint format: /notification/reject/:notificationId
      final endpoint = '/notification/reject/$notificationId';
      print('📡 Endpoint: $endpoint');
      print('📡 Full URL: ${dio.options.baseUrl}$endpoint');
      
      final response = await dio.put(endpoint);

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response data: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ Notification rejected successfully');
        return true;
      } else {
        final errorMsg = response.data?['error'] ?? response.statusMessage ?? 'Unknown error';
        print('❌ Failed to reject notification: $errorMsg');
        throw Exception('Failed to reject notification: $errorMsg');
      }
    } on DioException catch (e) {
      print('❌ DioException type: ${e.type}');
      print('❌ DioException message: ${e.message}');
      
      if (e.response != null) {
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
        
        final errorMessage = e.response?.data?['error'] ?? 
            e.response?.data?['message'] ??
            'Failed to reject notification: ${e.message}';
        print('❌ Error message: $errorMessage');
        throw Exception(errorMessage);
      } else {
        final errorMessage = 'Network error: ${e.message}';
        print('❌ Network error: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ General error rejecting notification: $e');
      throw Exception('Failed to reject notification: ${e.toString()}');
    }
  }
}

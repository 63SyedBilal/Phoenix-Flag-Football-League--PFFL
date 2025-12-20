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

  /// Accept a notification/invitation
  /// PUT /api/notification/accept/:notificationId
  /// Returns true on success, throws exception on error
  static Future<bool> acceptNotification(String notificationId) async {
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
        return true;
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

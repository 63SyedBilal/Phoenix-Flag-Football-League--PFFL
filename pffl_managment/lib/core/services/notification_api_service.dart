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
      final authToken =
          dio.options.headers['Authorization']?.toString().replaceAll(
            'Bearer ',
            '',
          ) ??
          'No token';
      print(
        '📬 [NOTIFICATION API] Fetching notifications from: ${dio.options.baseUrl}/notification/all',
      );
      print(
        '📬 [NOTIFICATION API] Auth token present: ${authToken.isNotEmpty && authToken != 'No token'}',
      );
      print(
        '📬 [NOTIFICATION API] Token preview: ${authToken.length > 20 ? authToken.substring(0, 20) + "..." : authToken}',
      );

      final response = await dio.get('/notification/all');
      print('📬 [NOTIFICATION API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        // Log the full response for debugging
        print('📬 [NOTIFICATION API] Full response data: $data');

        List<dynamic> rawList = [];

        if (data is Map && data.containsKey('data')) {
          rawList = data['data'] as List? ?? [];
          print(
            '📬 [NOTIFICATION API] Found ${rawList.length} notifications in data field',
          );

          // Log all keys in the response map
          print(
            '📬 [NOTIFICATION API] Response map keys: ${data.keys.toList()}',
          );
        } else if (data is List) {
          rawList = data;
          print(
            '📬 [NOTIFICATION API] Found ${rawList.length} notifications in list',
          );
        } else {
          print(
            '⚠️ [NOTIFICATION API] Unexpected response format: ${data.runtimeType}',
          );
          print('⚠️ [NOTIFICATION API] Response content: $data');
        }

        // If rawList is empty, log this for debugging
        if (rawList.isEmpty) {
          print(
            '⚠️ [NOTIFICATION API] No notifications found in response. This could mean:',
          );
          print('   1. User has no notifications in the database');
          print('   2. Backend is filtering notifications incorrectly');
          print('   3. User ID/email mapping issue on backend');
        }

        final notifications = rawList
            .map((json) {
              try {
                return NotificationModel.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                print('❌ [NOTIFICATION API] Error parsing notification: $e');
                return null;
              }
            })
            .whereType<NotificationModel>()
            .toList();

        print(
          '✅ [NOTIFICATION API] Successfully parsed ${notifications.length} notifications',
        );
        return notifications;
      }

      print(
        '⚠️ [NOTIFICATION API] Unexpected status code: ${response.statusCode}',
      );
      return [];
    } on DioException catch (e) {
      print('❌ [NOTIFICATION API] DioException: ${e.message}');
      if (e.response != null) {
        print('❌ [NOTIFICATION API] Response data: ${e.response?.data}');
        print(
          '❌ [NOTIFICATION API] Response status: ${e.response?.statusCode}',
        );
      }
      rethrow;
    } catch (e) {
      print('❌ [NOTIFICATION API] Error: $e');
      rethrow;
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
    String userId,
  ) async {
    final all = await getAllNotifications();
    return NotificationHelper.filterNotificationsByRole(all, role, userId);
  }
}

import 'package:dio/dio.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/models/notification_model.dart';

/// Service for notification-related API calls
class NotificationService {
  /// Get Dio instance with authentication token and working URL
  static Future<Dio> _getAuthenticatedDio() async {
    // Use AuthService's working Dio instance which has the correct URL
    return await AuthService.getWorkingDio();
  }

  /// Get all notifications for logged-in user
  /// GET /api/notification/all
  static Future<List<NotificationModel>> getAllNotifications() async {
    try {
      print('📡 [NotificationService] Fetching all notifications...');
      final dio = await _getAuthenticatedDio();
      print('📡 [NotificationService] Calling endpoint: /notification/all');
      final response = await dio.get('/notification/all');

      print('📡 [NotificationService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        List<dynamic> rawList = [];
        if (data is Map && data.containsKey('data')) {
          rawList = data['data'] as List? ?? [];
        } else if (data is List) {
          rawList = data;
        }

        print(
          '📡 [NotificationService] Found ${rawList.length} raw notifications',
        );

        final notifications = rawList
            .map((json) {
              try {
                return NotificationModel.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                print('⚠️ Error parsing notification: $e');
                return null;
              }
            })
            .whereType<NotificationModel>()
            .toList();

        print(
          '✅ [NotificationService] Returning ${notifications.length} valid notifications',
        );
        return notifications;
      } else {
        print(
          '❌ [NotificationService] Failed to fetch notifications: ${response.statusMessage}',
        );
        return [];
      }
    } on DioException catch (e) {
      print('❌ [NotificationService] DioException: ${e.message}');
      if (e.response != null) {
        print(
          '❌ [NotificationService] Error response status: ${e.response?.statusCode}',
        );
        print(
          '❌ [NotificationService] Error response data: ${e.response?.data}',
        );
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
  static Future<Map<String, dynamic>> acceptNotification(
    String notificationId,
  ) async {
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
          'message':
              responseData['message'] ?? 'Invitation accepted successfully!',
        };
      } else {
        final errorMsg =
            response.data?['error'] ??
            response.statusMessage ??
            'Unknown error';
        print('❌ Failed to accept notification: $errorMsg');
        throw Exception('Failed to accept notification: $errorMsg');
      }
    } on DioException catch (e) {
      print('❌ DioException type: ${e.type}');
      print('❌ DioException message: ${e.message}');

      if (e.response != null) {
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');

        final errorMessage =
            e.response?.data?['error'] ??
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
        final errorMsg =
            response.data?['error'] ??
            response.statusMessage ??
            'Unknown error';
        print('❌ Failed to reject notification: $errorMsg');
        throw Exception('Failed to reject notification: $errorMsg');
      }
    } on DioException catch (e) {
      print('❌ DioException type: ${e.type}');
      print('❌ DioException message: ${e.message}');

      if (e.response != null) {
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');

        final errorMessage =
            e.response?.data?['error'] ??
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

  /// Send payment reminder notification
  /// POST /api/notification/send
  static Future<bool> sendPaymentReminder({
    required String playerId,
    required String leagueId,
    required String message,
  }) async {
    try {
      print('📡 Sending payment reminder to: $playerId');
      final dio = await _getAuthenticatedDio();

      final data = {
        'receiverId': playerId,
        'leagueId': leagueId,
        'type': 'PAYMENT_REMINDER',
        'message': message,
      };

      // Trying standard endpoint convention
      // If "Notification collection" exists as requested by user, there should be a way to create one.
      final endpoint = '/notification/send';
      print('📡 Endpoint: $endpoint');

      final response = await dio.post(endpoint, data: data);

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Payment reminder sent successfully');
        return true;
      }
      return false;
    } on DioException catch (e) {
      print(
        '⚠️ Failed to send payment reminder (API might be missing): ${e.message}',
      );
      if (e.response != null) {
        print('⚠️ Response: ${e.response?.statusCode} - ${e.response?.data}');
      }
      // We return false but don't crash app, as this might be a missing backend feature
      return false;
    } catch (e) {
      print('❌ Error sending payment reminder: $e');
      return false;
    }
  }

  /// Send notification to Admin
  /// POST /api/notification/send
  static Future<bool> sendAdminNotification({required String message}) async {
    try {
      print('📡 Sending notification to Admin...');
      final dio = await _getAuthenticatedDio();

      final data = {
        'type': 'ADMIN_NOTIFICATION',
        'message': message,
        'isAdmin':
            true, // Assuming backend handles this flag to notify superadmin
      };

      final response = await dio.post('/notification/send', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Admin notification sent successfully');
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('⚠️ Failed to send admin notification: ${e.message}');
      return false;
    } catch (e) {
      print('❌ Error sending admin notification: $e');
      return false;
    }
  }
}

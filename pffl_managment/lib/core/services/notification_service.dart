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
      print('📡 [NOTIFICATION SERVICE DEBUG] Fetching all notifications...');
      final dio = await _getAuthenticatedDio();
      print('📡 [NOTIFICATION SERVICE DEBUG] Base URL: ${dio.options.baseUrl}');
      print(
        '📡 [NOTIFICATION SERVICE DEBUG] Calling endpoint: /notification/all',
      );
      print(
        '📡 [NOTIFICATION SERVICE DEBUG] Full URL: ${dio.options.baseUrl}/notification/all',
      );

      final response = await dio.get('/notification/all');

      print(
        '📡 [NOTIFICATION SERVICE DEBUG] Response status: ${response.statusCode}',
      );
      print(
        '📡 [NOTIFICATION SERVICE DEBUG] Response data type: ${response.data.runtimeType}',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('📡 [NOTIFICATION SERVICE DEBUG] Raw response data: $data');

        List<dynamic> rawList = [];
        if (data is Map && data.containsKey('data')) {
          rawList = data['data'] as List? ?? [];
          print(
            '📡 [NOTIFICATION SERVICE DEBUG] Extracted data array from response.data.data',
          );
        } else if (data is List) {
          rawList = data;
          print(
            '📡 [NOTIFICATION SERVICE DEBUG] Response data is already a list',
          );
        }

        print(
          '📡 [NOTIFICATION SERVICE DEBUG] Found ${rawList.length} raw notifications',
        );

        // Log each notification for debugging
        for (int i = 0; i < rawList.length; i++) {
          final notif = rawList[i];
          print('📡 [NOTIFICATION SERVICE DEBUG] Notification $i:');
          print('   - ID: ${notif['_id'] ?? notif['id']}');
          print('   - Type: ${notif['type']}');
          print('   - Message: ${notif['message']}');
          print('   - Status: ${notif['status']}');
          print('   - Created: ${notif['createdAt']}');
        }

        final notifications = rawList
            .map((json) {
              try {
                final notification = NotificationModel.fromJson(
                  json as Map<String, dynamic>,
                );
                print(
                  '✅ [NOTIFICATION SERVICE DEBUG] Successfully parsed notification: ${notification.id}',
                );
                return notification;
              } catch (e) {
                print(
                  '⚠️ [NOTIFICATION SERVICE DEBUG] Error parsing notification: $e',
                );
                print('⚠️ [NOTIFICATION SERVICE DEBUG] Raw data: $json');
                return null;
              }
            })
            .whereType<NotificationModel>()
            .toList();

        print(
          '✅ [NOTIFICATION SERVICE DEBUG] Returning ${notifications.length} valid notifications',
        );

        // Log team invite notifications specifically
        final teamInvites = notifications
            .where((n) => n.type.contains('TEAM') || n.type.contains('INVITE'))
            .toList();
        print(
          '🎯 [NOTIFICATION SERVICE DEBUG] Found ${teamInvites.length} team/invite notifications',
        );

        return notifications;
      } else {
        print(
          '❌ [NOTIFICATION SERVICE DEBUG] Failed to fetch notifications: ${response.statusMessage}',
        );
        return [];
      }
    } on DioException catch (e) {
      print('❌ [NOTIFICATION SERVICE DEBUG] DioException: ${e.message}');
      if (e.response != null) {
        print(
          '❌ [NOTIFICATION SERVICE DEBUG] Error response status: ${e.response?.statusCode}',
        );
        print(
          '❌ [NOTIFICATION SERVICE DEBUG] Error response data: ${e.response?.data}',
        );
      }
      return [];
    } catch (e) {
      print('❌ [NOTIFICATION SERVICE DEBUG] General error: $e');
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
    return await sendNotification(
      receiverId: playerId,
      type: 'PAYMENT_REMINDER',
      message: message,
      leagueId: leagueId,
    );
  }

  /// Send generic notification
  /// POST /api/notification/send
  static Future<bool> sendNotification({
    required String receiverId,
    required String type,
    required String message,
    String? leagueId,
    String? teamId,
  }) async {
    try {
      print('📡 Sending $type notification to: $receiverId');
      final dio = await _getAuthenticatedDio();

      final data = <String, dynamic>{
        'receiverId': receiverId,
        'type': type,
        'message': message,
      };

      if (leagueId != null && leagueId.isNotEmpty) {
        data['leagueId'] = leagueId;
      }

      if (teamId != null && teamId.isNotEmpty) {
        data['teamId'] = teamId;
      }

      final endpoint = '/notification/send';
      print('📡 Endpoint: $endpoint');
      print('📡 Data: $data');

      final response = await dio.post(endpoint, data: data);

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ $type notification sent successfully');
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('⚠️ Failed to send $type notification: ${e.message}');
      if (e.response != null) {
        print('⚠️ Response: ${e.response?.statusCode} - ${e.response?.data}');
      }
      return false;
    } catch (e) {
      print('❌ Error sending $type notification: $e');
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

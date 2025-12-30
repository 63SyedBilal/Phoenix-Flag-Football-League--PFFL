import 'package:dio/dio.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

/// Service for sending notifications (In-app, Email, Push)
class NotificationSenderService {
  /// Get Dio instance with authentication token
  static Future<Dio> _getAuthenticatedDio() async {
    return await AuthService.getWorkingDio();
  }

  /// Send generic in-app notification
  static Future<bool> sendNotification({
    required String receiverId,
    required String type,
    required String message,
    String? leagueId,
    String? teamId,
    String? matchId,
    String? senderId,
  }) async {
    try {
      final dio = await _getAuthenticatedDio();
      final data = <String, dynamic>{
        'receiverId': receiverId,
        'type': type,
        'message': message,
      };

      if (senderId != null) data['senderId'] = senderId;
      if (leagueId != null) data['leagueId'] = leagueId;
      if (teamId != null) data['teamId'] = teamId;
      if (matchId != null) data['matchId'] = matchId;

      final response = await dio.post('/notification/send', data: data);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Send notification specifically to Admin
  static Future<bool> sendAdminNotification({
    required String message,
    String type = 'SYSTEM_ALERT',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final dio = await _getAuthenticatedDio();
      final data = {
        'type': type,
        'message': message,
        'isAdmin': true,
        ...?additionalData,
      };

      final response = await dio.post('/notification/send', data: data);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Send email notification through backend
  static Future<bool> sendEmailNotification({
    required String type,
    required String recipientEmail,
    required String subject,
    String? body,
    Map<String, dynamic>? templateData,
    String? leagueId,
    String? teamId,
    String? paymentId,
  }) async {
    try {
      final dio = await _getAuthenticatedDio();
      final emailData = {
        'type': type,
        'recipientEmail': recipientEmail,
        'subject': subject,
        if (body != null) 'body': body,
        if (templateData != null) 'templateData': templateData,
        if (leagueId != null) 'leagueId': leagueId,
        if (teamId != null) 'teamId': teamId,
        if (paymentId != null) 'paymentId': paymentId,
      };

      final response = await dio.post(
        '/email/send-notification',
        data: emailData,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Send push notification through backend
  static Future<bool> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
    String? leagueId,
    String? teamId,
    String? matchId,
  }) async {
    try {
      final dio = await _getAuthenticatedDio();
      final pushData = {
        'userId': userId,
        'title': title,
        'body': body,
        if (type != null) 'type': type,
        if (data != null) 'data': data,
        if (leagueId != null) 'leagueId': leagueId,
        if (teamId != null) 'teamId': teamId,
        if (matchId != null) 'matchId': matchId,
      };

      final response = await dio.post(
        '/notifications/send-push',
        data: pushData,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}

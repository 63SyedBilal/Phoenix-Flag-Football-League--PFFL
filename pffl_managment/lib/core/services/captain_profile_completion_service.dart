import 'package:dio/dio.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

class CaptainProfileCompletionResult {
  final bool success;
  final int? statusCode;
  final String? message;
  final dynamic data;

  const CaptainProfileCompletionResult({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });
}

class CaptainProfileCompletionService {
  static Future<CaptainProfileCompletionResult> submitCaptainProfile({
    required Map<String, dynamic> profileData,
  }) async {
    final dio = await AuthService.getWorkingDio();

    try {
      final response = await dio.post(
        AppConfig.profileEndpoint,
        data: profileData,
        options: Options(
          // We want to read 400/405 bodies instead of throwing.
          validateStatus: (_) => true,
        ),
      );

      final status = response.statusCode;
      final body = response.data;

      String? message;
      if (body is Map) {
        message = body['message']?.toString() ?? body['error']?.toString();
      } else if (body is String) {
        message = body;
      }

      if (status == 200 || status == 201) {
        return CaptainProfileCompletionResult(
          success: true,
          statusCode: status,
          message: message,
          data: body,
        );
      }

      return CaptainProfileCompletionResult(
        success: false,
        statusCode: status,
        message: message ?? 'Failed to complete profile',
        data: body,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;

      String? message;
      if (body is Map) {
        message = body['message']?.toString() ?? body['error']?.toString();
      } else if (body is String) {
        message = body;
      }

      return CaptainProfileCompletionResult(
        success: false,
        statusCode: status,
        message: message ?? e.message ?? 'Request failed',
        data: body,
      );
    }
  }
}

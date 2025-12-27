import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

class UploadService {
  static Future<String?> uploadImage(
    File imageFile, {
    required String folder,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist: ${imageFile.path}');
      }

      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Image file is too large. Maximum size is 10MB');
      }

      final fileName = imageFile.path.split(Platform.pathSeparator).last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      if (!allowedExtensions.contains(fileExtension)) {
        throw Exception(
          'Invalid file format. Allowed formats: ${allowedExtensions.join(", ")}',
        );
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'folder': folder,
      });

      final dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          sendTimeout: AppConfig.sendTimeout,
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      try {
        final response = await dio.post(
          AppConfig.uploadEndpoint,
          data: formData,
        );

        if (response.statusCode == 200) {
          final data = response.data;

          if (data is Map) {
            final inner = data['data'];
            if (inner is Map && inner['url'] != null) {
              return inner['url'] as String;
            }
            if (inner is List && inner.isNotEmpty) {
              final first = inner.first;
              if (first is Map && first['url'] != null) {
                return first['url'] as String;
              }
            }

            if (data['url'] != null) {
              return data['url'] as String;
            }
            if (data['secure_url'] != null) {
              return data['secure_url'] as String;
            }
          }

          if (data is List && data.isNotEmpty) {
            final first = data.first;
            if (first is Map && first['url'] != null) {
              return first['url'] as String;
            }
          }

          throw Exception('Invalid response format from server');
        }

        throw Exception('Upload failed with status: ${response.statusCode}');
      } on DioException catch (e) {
        if (e.response?.statusCode == 500) {
          await Future.delayed(const Duration(seconds: 2));
          final response = await dio.post(
            AppConfig.uploadEndpoint,
            data: formData,
          );
          if (response.statusCode == 200) {
            final data = response.data;
            if (data is Map) {
              final inner = data['data'];
              if (inner is Map && inner['url'] != null) {
                return inner['url'] as String;
              }
              if (data['url'] != null) {
                return data['url'] as String;
              }
              if (data['secure_url'] != null) {
                return data['secure_url'] as String;
              }
            }
            throw Exception('Invalid response format from server');
          }
          throw Exception('Upload failed with status: ${response.statusCode}');
        }
        rethrow;
      }
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'Failed to upload image';
      final data = e.response?.data;
      if (data is Map) {
        errorMessage =
            data['error']?.toString() ??
            data['message']?.toString() ??
            errorMessage;
      }

      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }
}

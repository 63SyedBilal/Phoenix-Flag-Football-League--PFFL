import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pffl_managment/core/services/upload_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

/// Service for admin-related API calls
class AdminService {
  /// Get Dio instance with authentication token and working URL
  static Future<Dio> _getAuthenticatedDio() async {
    // Use AuthService's working Dio instance which has the correct URL
    final dio = await AuthService.getWorkingDio();
    // Increase timeout for file uploads
    dio.options.receiveTimeout = const Duration(seconds: 60);
    return dio;
  }

  /// Upload image to server
  /// POST /api/upload
  /// Returns the uploaded image URL
  static Future<String?> uploadImage(File imageFile) async {
    return UploadService.uploadImage(
      imageFile,
      folder: 'pffl/profiles',
    );
  }

  /// Update admin profile
  /// PUT /api/superadmin/:id
  static Future<Map<String, dynamic>?> updateAdminProfile(
    String adminId,
    Map<String, dynamic> profileData,
  ) async {
    try {

      final dio = await _getAuthenticatedDio();
      final url = '/superadmin/${adminId.trim()}';

      final response = await dio.put(url, data: profileData);

      if (response.statusCode == 200 || response.statusCode == 204) {
        final data = response.data;
        if (data is Map && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        if (data is Map) {
          return data as Map<String, dynamic>;
        }
        return {};
      } else {
        return null;
      }
    } on DioException catch (e) {
      if (e.response != null) {

        String errorMessage = 'Failed to update profile';
        final data = e.response?.data;
        if (data is Map) {
          errorMessage =
              data['error']?.toString() ??
              data['message']?.toString() ??
              errorMessage;
        } else if (data is String && data.isNotEmpty) {
          errorMessage = data;
        }
        throw Exception(errorMessage);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  /// Update admin profile using PATCH
  /// PATCH /api/superadmin/:id
  static Future<Map<String, dynamic>?> patchAdminProfile(
    String adminId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final dio = await _getAuthenticatedDio();
      final url = '/superadmin/${adminId.trim()}';

      final response = await dio.patch(url, data: profileData);

      if (response.statusCode == 200 || response.statusCode == 204) {
        final data = response.data;
        if (data is Map && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        if (data is Map) {
          return data as Map<String, dynamic>;
        }
        return {};
      } else {
        return null;
      }
    } on DioException catch (e) {
      if (e.response != null) {

        String errorMessage = 'Failed to update profile';
        final data = e.response?.data;
        if (data is Map) {
          errorMessage =
              data['error']?.toString() ??
              data['message']?.toString() ??
              errorMessage;
        } else if (data is String && data.isNotEmpty) {
          errorMessage = data;
        }
        throw Exception(errorMessage);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  /// Update admin profile without ID in URL (fallback)
  /// PUT /api/superadmin
  static Future<Map<String, dynamic>?> updateAdminProfileWithoutIdInUrl(
    Map<String, dynamic> profileData,
  ) async {
    try {

      final dio = await _getAuthenticatedDio();
      const url = '/superadmin';
      print(
        '🔄 AdminService (No ID in URL): API URL: ${dio.options.baseUrl}$url',
      );

      final response = await dio.put(url, data: profileData);

      if (response.statusCode == 200 || response.statusCode == 204) {
        final data = response.data;
        if (data is Map && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        if (data is Map) {
          return data as Map<String, dynamic>;
        }
        return {};
      } else {
        return null;
      }
    } on DioException catch (e) {
      print(
        '❌ AdminService (No ID in URL): DioException [${e.type}]: ${e.message}',
      );
      if (e.response != null) {
        print(
          '❌ AdminService (No ID in URL): Status: ${e.response?.statusCode}',
        );

        String errorMessage = 'Failed to update profile';
        final data = e.response?.data;
        if (data is Map) {
          errorMessage =
              data['error']?.toString() ??
              data['message']?.toString() ??
              errorMessage;
        } else if (data is String && data.isNotEmpty) {
          errorMessage = data;
        }
        throw Exception(errorMessage);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  /// Get current admin from token
  /// The admin ID is extracted from the JWT token
  static Future<String?> getCurrentAdminId() async {
    try {
      // Get user data from SharedPreferences (stored during login)
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      if (userJson != null) {
        // Parse and return ID
        // Note: This assumes user data is stored during login
        // If not available, we'll need to decode the JWT token
        return null; // Will be handled by provider
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}


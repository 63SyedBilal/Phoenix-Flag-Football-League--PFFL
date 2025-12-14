import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

/// Service for admin-related API calls
class AdminService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: Duration(seconds: 60), // Increase for file uploads
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Get Dio instance with authentication token
  static Future<Dio> _getAuthenticatedDio() async {
    final token = await AuthService.getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
    return _dio;
  }

  /// Upload image to server
  /// POST /api/upload
  /// Returns the uploaded image URL
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Validate file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist: ${imageFile.path}');
      }

      // Validate file size (max 10MB)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Image file is too large. Maximum size is 10MB');
      }

      // Get file extension for validation
      final fileName = imageFile.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      if (!allowedExtensions.contains(fileExtension)) {
        throw Exception('Invalid file format. Allowed formats: ${allowedExtensions.join(", ")}');
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'folder': 'pffl/profiles',
      });

      final dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: Duration(seconds: 60),
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final response = await dio.post(
        '/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null && data['data']['url'] != null) {
          return data['data']['url'] as String;
        }
        throw Exception('Invalid response format from server');
      }
      throw Exception('Upload failed with status: ${response.statusCode}');
    } on DioException catch (e) {
      print('Error uploading image: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        if (e.response?.statusCode == 401) {
          throw Exception('Authentication failed. Please login again.');
        } else if (e.response?.statusCode == 400) {
          throw Exception('Invalid file format or missing file data.');
        }
      }
      throw Exception('Failed to upload image: ${e.message}');
    } catch (e) {
      print('General error uploading image: $e');
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  /// Update admin profile
  /// PUT /api/superadmin/:id
  static Future<Map<String, dynamic>?> updateAdminProfile(
    String adminId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.put(
        '/superadmin/$adminId',
        data: profileData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        return null;
      } else {
        print('Failed to update admin profile: ${response.statusMessage}');
        return null;
      }
    } on DioException catch (e) {
      print('Error updating admin profile: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        final errorData = e.response?.data;
        if (errorData != null && errorData['error'] != null) {
          throw Exception(errorData['error']);
        }
      }
      throw Exception('Failed to update profile: ${e.message}');
    } catch (e) {
      print('General error updating admin profile: $e');
      throw Exception('Failed to update profile: ${e.toString()}');
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
      print('Error getting current admin ID: $e');
      return null;
    }
  }
}

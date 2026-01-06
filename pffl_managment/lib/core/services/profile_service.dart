import 'package:dio/dio.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/config/app_config.dart';

/// Service for profile-related API calls
class ProfileService {
  /// Get Dio instance with authentication token and working URL
  static Future<Dio> _getAuthenticatedDio() async {
    // Use AuthService's working Dio instance which has the correct URL
    return await AuthService.getWorkingDio();
  }

  /// Create or update player profile
  /// POST /api/profile
  /// Returns profile data on success
  static Future<Map<String, dynamic>> createProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final dio = await _getAuthenticatedDio();

      // Use PUT as create/complete profile is idempotent update
      final response = await dio.put(
        AppConfig.completeProfileEndpoint,
        data: profileData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        throw Exception('Invalid response format: missing data field');
      } else {
        final errorMessage =
            response.data['error'] ?? 'Failed to create profile';
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['error'] != null) {
          throw Exception(errorData['error']);
        }
      }
      throw Exception('Failed to create profile: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create profile: ${e.toString()}');
    }
  }

  /// Get profile by user ID
  /// First tries to get user data (which has profileImage, jerseyNumber, position)
  /// Falls back to profile collection if user data not available
  /// Returns combined profile data or null if not found
  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final dio = await _getAuthenticatedDio();

      // First try to get user data which contains profileImage, jerseyNumber, position
      try {
        final userResponse = await dio.get(
          '/user/$userId',
          options: Options(validateStatus: (_) => true),
        );

        if (userResponse.statusCode == 200) {
          final userData = userResponse.data;

          if (userData is Map) {
            final user = ((userData['data'] ?? userData) as Map)
                .cast<String, dynamic>();

            final profileImg = user['profileImage']?.toString();
            final jersey = user['jerseyNumber']?.toString();
            final pos = user['position']?.toString();

            // Return user data as profile data
            // Even if profile fields are missing, return what we have
            return {
              'profileImage': profileImg ?? '',
              'image': profileImg ?? '',
              'jerseyNumber': jersey ?? '',
              'position': pos ?? '',
              'firstName': user['firstName'] ?? '',
              'lastName': user['lastName'] ?? '',
              'email': user['email'] ?? '',
              'phone': user['phone'] ?? '',
              'role': user['role'] ?? '',
              'emergencyContactName': user['emergencyContactName'] ?? '',
              'emergencyPhone': user['emergencyPhone'] ?? '',
              'profileCompleted': user['profileCompleted'] ?? false,
            };
          }
        }

        // If 404, user truly doesn't exist
        return null;
      } catch (e) {
        return null;
      }
    } on DioException {
      return null;
    } catch (e) {
      return null;
    }
  }
}

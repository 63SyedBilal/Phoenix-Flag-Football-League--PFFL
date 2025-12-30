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

      final response = await dio.post(
        AppConfig.profileEndpoint,
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
          '/api/user/$userId',
          options: Options(validateStatus: (_) => true),
        );

        if (userResponse.statusCode == 200) {
          final userData = userResponse.data;

          if (userData is Map && userData['data'] is Map) {
            final user = (userData['data'] as Map).cast<String, dynamic>();
            print(
              '📡 ✅ Got user data with profileImage: ${user['profileImage']}',
            );

            // Return user data which includes profileImage, jerseyNumber, position
            return {
              'profileImage': user['profileImage'] ?? '',
              'image':
                  user['profileImage'] ??
                  '', // Also set as 'image' for compatibility
              'jerseyNumber': user['jerseyNumber'] ?? '',
              'position': user['position'] ?? '',
              'firstName': user['firstName'] ?? '',
              'lastName': user['lastName'] ?? '',
              'email': user['email'] ?? '',
              'phone': user['phone'] ?? '',
              'role': user['role'] ?? '',
            };
          }
        }
      } catch (e) {
      }

      // Fallback to profile collection
      final response = await dio.get(
        '${AppConfig.profileEndpoint}/$userId',
        options: Options(validateStatus: (_) => true),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is Map) {
          final profileData = (data['data'] as Map).cast<String, dynamic>();
          return profileData;
        }
        if (data is Map && data['user'] is Map) {
          return (data['user'] as Map).cast<String, dynamic>();
        }
        if (data is Map) {
          return data.cast<String, dynamic>();
        }
        return null;
      }

      if (response.statusCode == 404 || response.statusCode == 405) {
        final fallback = await dio.get(
          AppConfig.profileEndpoint,
          queryParameters: {'userId': userId},
          options: Options(validateStatus: (_) => true),
        );

        if (fallback.statusCode == 200) {
          final body = fallback.data;
          if (body is Map) {
            final d = body['data'] ?? body['user'] ?? body;
            if (d is Map) return d.cast<String, dynamic>();
            if (d is List && d.isNotEmpty) {
              final first = d.first;
              if (first is Map) return first.cast<String, dynamic>();
            }
          }
        }

        // Profile not available for this user.
        return null;
      }
      return null;
    } on DioException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }
}


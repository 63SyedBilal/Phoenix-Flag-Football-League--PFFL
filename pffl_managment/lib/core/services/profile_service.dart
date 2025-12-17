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
      print('📡 Creating profile...');
      final dio = await _getAuthenticatedDio();
      print('📡 API URL: ${dio.options.baseUrl}${AppConfig.profileEndpoint}');

      final response = await dio.post(
        AppConfig.profileEndpoint,
        data: profileData,
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['data'] != null) {
          print('✅ Profile created successfully');
          return data['data'] as Map<String, dynamic>;
        }
        throw Exception('Invalid response format: missing data field');
      } else {
        final errorMessage = response.data['error'] ?? 'Failed to create profile';
        print('❌ Failed to create profile: $errorMessage');
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      print('❌ Error creating profile: ${e.message}');
      print('❌ Error type: ${e.type}');
      if (e.response != null) {
        print('❌ Error status: ${e.response?.statusCode}');
        print('❌ Error response: ${e.response?.data}');
        final errorData = e.response?.data;
        if (errorData != null && errorData['error'] != null) {
          throw Exception(errorData['error']);
        }
      }
      throw Exception('Failed to create profile: ${e.message}');
    } catch (e) {
      print('❌ General error creating profile: $e');
      throw Exception('Failed to create profile: ${e.toString()}');
    }
  }

  /// Get profile by user ID
  /// GET /api/profile/:userId
  /// Returns profile data or null if not found
  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      print('📡 Fetching profile for user: $userId');
      final dio = await _getAuthenticatedDio();
      print('📡 API URL: ${dio.options.baseUrl}${AppConfig.profileEndpoint}/$userId');

      final response = await dio.get('${AppConfig.profileEndpoint}/$userId');

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          print('✅ Profile found');
          return data['data'] as Map<String, dynamic>;
        }
        print('⚠️ Profile data not found in response');
        return null;
      } else if (response.statusCode == 404) {
        print('ℹ️ Profile not found for user: $userId');
        return null;
      } else {
        print('❌ Failed to fetch profile: ${response.statusMessage}');
        return null;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        print('ℹ️ Profile not found (404)');
        return null;
      }
      print('❌ Error fetching profile: ${e.message}');
      print('❌ Error type: ${e.type}');
      if (e.response != null) {
        print('❌ Error status: ${e.response?.statusCode}');
        print('❌ Error response: ${e.response?.data}');
      }
      // Return null instead of throwing to allow graceful handling
      return null;
    } catch (e) {
      print('❌ General error fetching profile: $e');
      return null;
    }
  }
}


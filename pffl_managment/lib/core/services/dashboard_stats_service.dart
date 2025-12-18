import 'package:dio/dio.dart';
import 'package:pffl_managment/core/models/dashboard_stats_model.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/config/app_config.dart';

/// Service for fetching dashboard statistics from the API
/// Used by DashboardViewModel to get real-time stats for Admin Overview
class DashboardStatsService {
  /// Get Dio instance with authentication token and working URL
  static Future<Dio> _getAuthenticatedDio() async {
    return await AuthService.getWorkingDio();
  }

  /// Fetch dashboard statistics from superadmin/stats endpoint
  /// GET /api/superadmin/stats
  /// Returns DashboardStatsModel on success, null on failure
  static Future<DashboardStatsModel?> getDashboardStats() async {
    try {
      print('📡 Fetching dashboard stats...');
      final dio = await _getAuthenticatedDio();
      print('📡 API URL: ${dio.options.baseUrl}${AppConfig.superadminStatsEndpoint}');

      final response = await dio.get(AppConfig.superadminStatsEndpoint);

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          print('✅ Dashboard stats fetched successfully');
          return DashboardStatsModel.fromJson(data['data']);
        } else if (data['data'] != null) {
          print('✅ Dashboard stats fetched (no success flag)');
          return DashboardStatsModel.fromJson(data['data']);
        }
        print('⚠️ No data field in response');
        return null;
      } else {
        print('❌ Failed to fetch dashboard stats: ${response.statusMessage}');
        return null;
      }
    } on DioException catch (e) {
      print('❌ DioException fetching dashboard stats: ${e.message}');
      print('❌ Error type: ${e.type}');
      if (e.response != null) {
        print('❌ Error status: ${e.response?.statusCode}');
        print('❌ Error response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('❌ General error fetching dashboard stats: $e');
      return null;
    }
  }
}


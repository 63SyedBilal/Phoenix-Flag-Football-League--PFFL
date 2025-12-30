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
      final dio = await _getAuthenticatedDio();

      final response = await dio.get(AppConfig.superadminStatsEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return DashboardStatsModel.fromJson(data['data']);
        } else if (data['data'] != null) {
          return DashboardStatsModel.fromJson(data['data']);
        }
        return null;
      } else {
        return null;
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}



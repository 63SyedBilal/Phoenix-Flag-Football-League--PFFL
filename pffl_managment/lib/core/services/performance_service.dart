import 'package:pffl_managment/core/providers/performance_provider.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:dio/dio.dart';

/// Service for fetching player performance data from the API
class PerformanceService {
  /// Get Dio instance with authentication token and working URL
  static Future<Dio> _getAuthenticatedDio() async {
    return await AuthService.getWorkingDio();
  }

  /// Fetch player performance statistics
  /// GET /api/performance/my
  static Future<PlayerPerformance?> getMyPerformance() async {
    try {
      final dio = await _getAuthenticatedDio();

      final response = await dio.get('/performance/my');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return PlayerPerformance.fromJson(data['data']);
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetch performance leaderboard
  /// GET /api/performance/leaderboard?limit=10
  static Future<List<PlayerPerformance>?> getLeaderboard({int limit = 10}) async {
    try {
      final dio = await _getAuthenticatedDio();

      final response = await dio.get('/performance/leaderboard', queryParameters: {'limit': limit});

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] is List) {
          final leaderboard = (data['data'] as List)
              .map((item) => PlayerPerformance.fromJson(item))
              .toList();
          return leaderboard;
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}


import 'package:flutter/foundation.dart';
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
      debugPrint('📊 Fetching player performance data...');
      final dio = await _getAuthenticatedDio();

      final response = await dio.get('/performance/my');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          debugPrint('✅ Performance data fetched successfully');
          return PlayerPerformance.fromJson(data['data']);
        }
      }

      debugPrint('❌ Failed to fetch performance data: ${response.statusMessage}');
      return null;
    } on DioException catch (e) {
      debugPrint('❌ Error fetching performance data: ${e.message}');
      if (e.response != null) {
        debugPrint('Error response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      debugPrint('❌ General error fetching performance data: $e');
      return null;
    }
  }

  /// Fetch performance leaderboard
  /// GET /api/performance/leaderboard?limit=10
  static Future<List<PlayerPerformance>?> getLeaderboard({int limit = 10}) async {
    try {
      debugPrint('🏆 Fetching performance leaderboard...');
      final dio = await _getAuthenticatedDio();

      final response = await dio.get('/performance/leaderboard', queryParameters: {'limit': limit});

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] is List) {
          debugPrint('✅ Leaderboard data fetched successfully');
          final leaderboard = (data['data'] as List)
              .map((item) => PlayerPerformance.fromJson(item))
              .toList();
          return leaderboard;
        }
      }

      debugPrint('❌ Failed to fetch leaderboard: ${response.statusMessage}');
      return null;
    } on DioException catch (e) {
      debugPrint('❌ Error fetching leaderboard: ${e.message}');
      if (e.response != null) {
        debugPrint('Error response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      debugPrint('❌ General error fetching leaderboard: $e');
      return null;
    }
  }
}

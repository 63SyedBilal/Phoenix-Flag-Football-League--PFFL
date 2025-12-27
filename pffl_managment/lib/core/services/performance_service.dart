import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pffl_managment/core/providers/performance_provider.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

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

      // TODO: Replace with actual API endpoint when available
      // For now, simulate API call with mock data
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - replace with actual API response
      final mockData = {
        'playerId': 'player123',
        'playerName': 'Current User',
        'gamesPlayed': 15,
        'wins': 11,
        'losses': 4,
        'touchdowns': 8,
        'catches': 24,
        'rushes': 45,
        'flagPulls': 12,
        'yardsGained': 320.5,
        'yardsLost': 45.2,
        'completions': 18,
        'passAttempts': 32,
        'completionPercentage': 56.3,
        'safety': 2,
        'conversionPoints': 14,
        'averagePointsPerGame': 6.8,
        'bestPosition': 'Wide Receiver',
        'ranking': 3,
      };

      debugPrint('✅ Performance data fetched successfully');
      return PlayerPerformance.fromJson(mockData);

      // Uncomment when API endpoint is ready:
      /*
      final response = await dio.get('/performance/my');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          debugPrint('✅ Performance data fetched successfully');
          return PlayerPerformance.fromJson(data['data']);
        }
      }

      debugPrint('⚠️ No performance data available');
      return null;
      */

    } on DioException catch (e) {
      debugPrint('❌ DioException fetching performance: ${e.message}');
      if (e.response != null) {
        debugPrint('❌ Error response: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      debugPrint('❌ General error fetching performance: $e');
      return null;
    }
  }

  /// Fetch performance leaderboard
  /// GET /api/performance/leaderboard?limit=10
  static Future<List<PlayerPerformance>?> getLeaderboard({int limit = 10}) async {
    try {
      debugPrint('🏆 Fetching performance leaderboard...');
      final dio = await _getAuthenticatedDio();

      // TODO: Replace with actual API call when available
      await Future.delayed(const Duration(seconds: 1));

      // Mock leaderboard data
      final mockLeaderboard = [
        {
          'playerId': 'player1',
          'playerName': 'John Doe',
          'gamesPlayed': 20,
          'wins': 16,
          'losses': 4,
          'touchdowns': 12,
          'catches': 35,
          'rushes': 52,
          'flagPulls': 8,
          'yardsGained': 450.5,
          'yardsLost': 25.2,
          'completions': 25,
          'passAttempts': 40,
          'completionPercentage': 62.5,
          'safety': 3,
          'conversionPoints': 18,
          'averagePointsPerGame': 8.2,
          'bestPosition': 'Quarterback',
          'ranking': 1,
        },
        {
          'playerId': 'player2',
          'playerName': 'Jane Smith',
          'gamesPlayed': 18,
          'wins': 14,
          'losses': 4,
          'touchdowns': 10,
          'catches': 28,
          'rushes': 38,
          'flagPulls': 15,
          'yardsGained': 380.0,
          'yardsLost': 30.5,
          'completions': 20,
          'passAttempts': 35,
          'completionPercentage': 57.1,
          'safety': 1,
          'conversionPoints': 16,
          'averagePointsPerGame': 7.5,
          'bestPosition': 'Running Back',
          'ranking': 2,
        },
        // Current user
        {
          'playerId': 'player123',
          'playerName': 'Current User',
          'gamesPlayed': 15,
          'wins': 11,
          'losses': 4,
          'touchdowns': 8,
          'catches': 24,
          'rushes': 45,
          'flagPulls': 12,
          'yardsGained': 320.5,
          'yardsLost': 45.2,
          'completions': 18,
          'passAttempts': 32,
          'completionPercentage': 56.3,
          'safety': 2,
          'conversionPoints': 14,
          'averagePointsPerGame': 6.8,
          'bestPosition': 'Wide Receiver',
          'ranking': 3,
        },
      ];

      debugPrint('✅ Leaderboard fetched successfully');
      return mockLeaderboard.map((data) => PlayerPerformance.fromJson(data)).toList();

      // Uncomment when API endpoint is ready:
      /*
      final response = await dio.get('/performance/leaderboard', queryParameters: {'limit': limit});

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final leaderboard = (data['data'] as List)
              .map((item) => PlayerPerformance.fromJson(item))
              .toList();
          debugPrint('✅ Leaderboard fetched successfully');
          return leaderboard;
        }
      }

      debugPrint('⚠️ No leaderboard data available');
      return null;
      */

    } on DioException catch (e) {
      debugPrint('❌ DioException fetching leaderboard: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ General error fetching leaderboard: $e');
      return null;
    }
  }
}

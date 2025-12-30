import 'package:dio/dio.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

/// Service for fetching approved stats across all leagues
class ApprovedStatsService {
  /// Get Dio instance with authentication token
  static Future<Dio> _getAuthenticatedDio() async {
    return await AuthService.getWorkingDio();
  }

  /// Get all approved stats across all leagues
  static Future<List<Map<String, dynamic>>> getAllApprovedStats() async {
    try {
      final dio = await _getAuthenticatedDio();

      final response = await dio.get(
        '/stats',
        queryParameters: {'status': 'APPROVED'},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List? ?? [];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch approved stats');
      }
    } catch (e) {
      throw Exception('Failed to fetch approved stats: ${e.toString()}');
    }
  }

  /// Get approved stats for a specific league
  static Future<List<Map<String, dynamic>>> getApprovedStatsByLeague(
    String leagueId,
  ) async {
    try {
      final dio = await _getAuthenticatedDio();

      print(
        '📤 [APPROVED STATS DEBUG] Fetching approved stats for league: $leagueId',
      );

      final response = await dio.get(
        '/stats',
        queryParameters: {'status': 'APPROVED', 'leagueId': leagueId},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List? ?? [];
        print(
          '✅ [APPROVED STATS DEBUG] Found ${data.length} approved stats for league',
        );
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch approved stats for league');
      }
    } catch (e) {
      throw Exception(
        'Failed to fetch approved stats for league: ${e.toString()}',
      );
    }
  }

  /// Get approved stats for a specific match
  static Future<List<Map<String, dynamic>>> getApprovedStatsByMatch(
    String matchId,
  ) async {
    try {
      final dio = await _getAuthenticatedDio();

      print(
        '📤 [APPROVED STATS DEBUG] Fetching approved stats for match: $matchId',
      );

      final response = await dio.get(
        '/stats',
        queryParameters: {'status': 'APPROVED', 'matchId': matchId},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List? ?? [];
        print(
          '✅ [APPROVED STATS DEBUG] Found ${data.length} approved stats for match',
        );
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch approved stats for match');
      }
    } catch (e) {
      throw Exception(
        'Failed to fetch approved stats for match: ${e.toString()}',
      );
    }
  }
}


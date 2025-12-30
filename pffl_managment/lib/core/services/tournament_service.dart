import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/config/app_config.dart';

/// Service for tournament-related API calls
class TournamentService {
  const TournamentService();

  /// Get authenticated Dio instance
  Future<Dio> _getAuthenticatedDio() async {
    return await AuthService.getWorkingDio();
  }

  /// Get top 4 teams from league leaderboard
  /// GET /api/league/:leagueId/top-teams
  Future<Map<String, dynamic>> getTopTeams(String leagueId) async {
    try {
      final dio = await _getAuthenticatedDio();

      final response = await dio.get('${AppConfig.baseUrl}/league/$leagueId/top-teams');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          'success': false,
          'message': response.statusMessage ?? 'Failed to get top teams'
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return {
        'success': false,
        'message': e.response?.data?['error'] ?? 'Failed to get top teams: ${e.message}'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting top teams: $e'
      };
    }
  }

  /// Create semi-final matches
  /// POST /api/league/:leagueId/create-semi-finals
  Future<Map<String, dynamic>> createSemiFinals({
    required String leagueId,
    required DateTime matchDate,
    required String venue,
    List<String>? refereeIds,
    List<String>? statKeeperIds,
  }) async {
    try {
      final dio = await _getAuthenticatedDio();

      final data = {
        'matchDate': matchDate.toIso8601String(),
        'venue': venue,
        if (refereeIds != null) 'refereeIds': refereeIds,
        if (statKeeperIds != null) 'statKeeperIds': statKeeperIds,
      };

      final response = await dio.post(
        '${AppConfig.baseUrl}/league/$leagueId/create-semi-finals',
        data: data,
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        return {
          'success': false,
          'message': response.statusMessage ?? 'Failed to create semi-finals'
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return {
        'success': false,
        'message': e.response?.data?['error'] ?? 'Failed to create semi-finals: ${e.message}'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating semi-finals: $e'
      };
    }
  }

  /// Create final match
  /// POST /api/league/:leagueId/create-final
  Future<Map<String, dynamic>> createFinal({
    required String leagueId,
    required DateTime matchDate,
    required String venue,
    required String refereeId,
    required String statKeeperId,
  }) async {
    try {
      final dio = await _getAuthenticatedDio();

      final data = {
        'matchDate': matchDate.toIso8601String(),
        'venue': venue,
        'refereeId': refereeId,
        'statKeeperId': statKeeperId,
      };

      final response = await dio.post(
        '${AppConfig.baseUrl}/league/$leagueId/create-final',
        data: data,
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        return {
          'success': false,
          'message': response.statusMessage ?? 'Failed to create final'
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return {
        'success': false,
        'message': e.response?.data?['error'] ?? 'Failed to create final: ${e.message}'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating final: $e'
      };
    }
  }

  /// Complete tournament
  /// POST /api/league/:leagueId/complete-tournament
  Future<Map<String, dynamic>> completeTournament(String leagueId) async {
    try {
      final dio = await _getAuthenticatedDio();

      final response = await dio.post('${AppConfig.baseUrl}/league/$leagueId/complete-tournament');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          'success': false,
          'message': response.statusMessage ?? 'Failed to complete tournament'
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return {
        'success': false,
        'message': e.response?.data?['error'] ?? 'Failed to complete tournament: ${e.message}'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error completing tournament: $e'
      };
    }
  }

  /// Get tournament bracket data
  /// GET /api/league/:leagueId/bracket
  Future<Map<String, dynamic>> getTournamentBracket(String leagueId) async {
    try {
      final dio = await _getAuthenticatedDio();

      final response = await dio.get('${AppConfig.baseUrl}/league/$leagueId/bracket');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          'success': false,
          'message': response.statusMessage ?? 'Failed to get tournament bracket'
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return {
        'success': false,
        'message': e.response?.data?['error'] ?? 'Failed to get tournament bracket: ${e.message}'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting tournament bracket: $e'
      };
    }
  }

  /// Set match winner (for knockout advancement)
  /// PUT /api/matches/:matchId/winner
  Future<Map<String, dynamic>> setMatchWinner({
    required String matchId,
    required String winnerId,
    bool tiebreakerUsed = false,
    String? tiebreakerType,
  }) async {
    try {
      final dio = await _getAuthenticatedDio();

      final data = {
        'winnerId': winnerId,
        'tiebreakerUsed': tiebreakerUsed,
        if (tiebreakerType != null) 'tiebreakerType': tiebreakerType,
      };

      final response = await dio.put(
        '${AppConfig.baseUrl}/matches/$matchId/winner',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          'success': false,
          'message': response.statusMessage ?? 'Failed to set match winner'
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return {
        'success': false,
        'message': e.response?.data?['error'] ?? 'Failed to set match winner: ${e.message}'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error setting match winner: $e'
      };
    }
  }
}


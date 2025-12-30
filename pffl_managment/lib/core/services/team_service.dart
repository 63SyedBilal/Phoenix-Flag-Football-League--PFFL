import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

/// Service for team-related API calls
class TeamService {
  /// Get Dio instance with authentication token and working URL
  static Future<Dio> _getAuthenticatedDio() async {
    final dio = await AuthService.getWorkingDio();
    return dio;
  }

  /// Create a new team
  /// POST /api/team
  /// Required: teamName, location
  /// Optional: skillLevel, image, squad5v5, squad7v7
  static Future<Map<String, dynamic>?> createTeam({
    required String teamName,
    required String location,
    String? skillLevel,
    String? imageUrl,
    List<String>? squad5v5,
    List<String>? squad7v7,
  }) async {
    try {
      final dio = await _getAuthenticatedDio();

      final teamData = <String, dynamic>{
        'teamName': teamName.trim(),
        'location': location.trim(),
      };

      if (skillLevel != null && skillLevel.isNotEmpty) {
        teamData['skillLevel'] = skillLevel;
      }

      if (imageUrl != null && imageUrl.isNotEmpty) {
        teamData['image'] = imageUrl;
      }

      if (squad5v5 != null && squad5v5.isNotEmpty) {
        teamData['squad5v5'] = squad5v5;
      }

      if (squad7v7 != null && squad7v7.isNotEmpty) {
        teamData['squad7v7'] = squad7v7;
      }

      final response = await dio.post(AppConfig.teamEndpoint, data: teamData);

      if (response.statusCode == 201) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create team: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['error'] ?? 'Failed to create team: ${e.message}';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to create team: ${e.toString()}');
    }
  }

  /// Get team by captain ID
  /// GET /api/team?captainId=xxx
  static Future<Map<String, dynamic>?> getTeamByCaptain() async {
    try {
      // Get captain ID from SharedPreferences (stored during login)
      final prefs = await SharedPreferences.getInstance();
      final captainId = prefs.getString('userId');

      if (captainId == null || captainId.isEmpty) {
        throw Exception('User ID not found. Please login again.');
      }

      final dio = await _getAuthenticatedDio();

      // Pass captainId as query parameter to get the captain's team
      final response = await dio.get(
        AppConfig.teamEndpoint,
        queryParameters: {'captainId': captainId},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        // Backend returns single team object when captainId is provided
        if (data == null) {
          return null; // Team not found
        }

        if (data is Map) {

          // Log squad sizes for debugging
          final squad5v5 = data['squad5v5'] as List? ?? [];
          final squad7v7 = data['squad7v7'] as List? ?? [];

          return data as Map<String, dynamic>;
        }

        // Fallback: if data is a list, return first item
        if (data is List && data.isNotEmpty) {
          return data[0] as Map<String, dynamic>;
        }

        return null;
      } else {
        throw Exception('Failed to fetch team: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // Team not found
      }
      final errorMessage =
          e.response?.data['error'] ?? 'Failed to fetch team: ${e.message}';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to fetch team: ${e.toString()}');
    }
  }

  /// Check if captain has a team
  static Future<bool> hasTeam() async {
    try {
      final team = await getTeamByCaptain();
      return team != null;
    } catch (e) {
      return false;
    }
  }

  /// Get team by ID with players populated
  /// GET /api/team/:id
  /// Returns team data with squad5v5 and squad7v7 populated
  static Future<Map<String, dynamic>?> getTeamById(String teamId) async {
    try {
      final dio = await _getAuthenticatedDio();

      final response = await dio.get('${AppConfig.teamEndpoint}/$teamId');

      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (data == null) {
          return null;
        }

        if (data is Map) {

          // Log squad sizes for debugging
          final squad5v5 = data['squad5v5'] as List? ?? [];
          final squad7v7 = data['squad7v7'] as List? ?? [];

          return data as Map<String, dynamic>;
        }

        return null;
      } else {
        throw Exception('Failed to fetch team: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      final errorMessage =
          e.response?.data['error'] ?? 'Failed to fetch team: ${e.message}';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to fetch team: ${e.toString()}');
    }
  }

  /// Get team by player ID (where player is in squad5v5 or squad7v7)
  /// GET /api/team?playerId=xxx
  /// Returns team data or null if player is not in any team
  static Future<Map<String, dynamic>?> getTeamByPlayer(String playerId) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get(
        AppConfig.teamEndpoint,
        queryParameters: {'playerId': playerId},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) {
          return null; // No team found
        }
        if (data is Map) {
          return data as Map<String, dynamic>;
        }
        return null;
      } else if (response.statusCode == 404) {
        return null; // Team not found - player has no team
      } else {
        throw Exception('Failed to fetch team: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // Team not found - player has no team
      }
      final errorMessage =
          e.response?.data['error'] ?? 'Failed to fetch team: ${e.message}';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to fetch team: ${e.toString()}');
    }
  }

  /// Invite a player to the team
  /// POST /api/team/invite-player
  /// Body: { playerId: string, teamId: string, format: "5v5" | "7v7" }
  static Future<bool> invitePlayer({
    required String playerId,
    required String teamId,
    required String format, // "5v5" or "7v7"
  }) async {
    try {

      final dio = await _getAuthenticatedDio();

      if (!['5v5', '7v7'].contains(format)) {
        throw Exception('Format must be either "5v5" or "7v7"');
      }

      final requestData = {
        'playerId': playerId,
        'teamId': teamId,
        'format': format,
      };
      print(
        '🎯 [TEAM SERVICE DEBUG] Endpoint: ${AppConfig.teamInvitePlayerEndpoint}',
      );
      print(
        '🎯 [TEAM SERVICE DEBUG] Full URL: ${dio.options.baseUrl}${AppConfig.teamInvitePlayerEndpoint}',
      );

      final response = await dio.post(
        AppConfig.teamInvitePlayerEndpoint,
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(
          '🎯 [TEAM SERVICE DEBUG] Backend should have created notification for Free Agent',
        );
        return true;
      } else {
        print(
          '❌ [TEAM SERVICE DEBUG] Unexpected status code: ${response.statusCode}',
        );
        throw Exception('Failed to invite player: ${response.statusMessage}');
      }
    } on DioException catch (e) {

      if (e.response != null) {
        print(
          '❌ [TEAM SERVICE DEBUG] Response status: ${e.response?.statusCode}',
        );
      }

      final errorMessage =
          e.response?.data['error'] ?? 'Failed to invite player: ${e.message}';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to invite player: ${e.toString()}');
    }
  }

  /// Find the league that contains a specific team
  /// GET /api/league?teamId=xxx (this would need a backend endpoint)
  /// For now, we'll query all leagues and find the one containing the team
  static Future<Map<String, dynamic>?> findLeagueForTeam(String teamId) async {
    try {
      final dio = await _getAuthenticatedDio();

      // Get all leagues (we need to find which league contains this team)
      final response = await dio.get('/league');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final leagues = data['data'] as List<dynamic>;

          // Find the league that contains this team in its teams array
          for (var league in leagues) {
            final leagueData = league as Map<String, dynamic>;
            final teams = leagueData['teams'] as List<dynamic>? ?? [];

            // Check if teamId is in this league's teams array
            if (teams.any((team) {
              if (team is Map<String, dynamic>) {
                return team['_id'] == teamId || team['id'] == teamId;
              } else if (team is String) {
                return team == teamId;
              }
              return false;
            })) {
              return {
                'success': true,
                'data': leagueData,
              };
            }
          }
        }
      }

      return {
        'success': false,
        'message': 'League not found for team',
      };
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return {
        'success': false,
        'message': 'Failed to find league for team: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to find league for team: ${e.toString()}',
      };
    }
  }

  /// Transfer leadership to another player in the team
  /// PUT /api/team/:teamId/transfer-leadership
  /// Body: { newCaptainId: string }
  static Future<bool> transferLeadership({
    required String teamId,
    required String newCaptainId,
  }) async {
    try {

      final dio = await _getAuthenticatedDio();
      final endpoint = '${AppConfig.teamEndpoint}/$teamId/transfer-leadership';

      final response = await dio.put(
        endpoint,
        data: {'newCaptainId': newCaptainId},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
            '❌ [TEAM SERVICE DEBUG] Unexpected status code: ${response.statusCode}');
        throw Exception(
            'Failed to transfer leadership: ${response.statusMessage}');
      }
    } on DioException catch (e) {

      if (e.response != null) {
        print(
            '❌ [TEAM SERVICE DEBUG] Response status: ${e.response?.statusCode}');
      }

      final errorMessage = e.response?.data['error'] ??
          'Failed to transfer leadership: ${e.message}';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to transfer leadership: ${e.toString()}');
    }
  }

  /// Remove a player from the team
  /// DELETE /api/team/:teamId/remove-player/:playerId
  static Future<bool> removePlayerFromTeam({
    required String teamId,
    required String playerId,
  }) async {
    try {

      final dio = await _getAuthenticatedDio();
      final endpoint = '${AppConfig.teamEndpoint}/$teamId/remove-player/$playerId';

      final response = await dio.delete(endpoint);

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
            '❌ [TEAM SERVICE DEBUG] Unexpected status code: ${response.statusCode}');
        throw Exception('Failed to remove player: ${response.statusMessage}');
      }
    } on DioException catch (e) {

      if (e.response != null) {
        print(
            '❌ [TEAM SERVICE DEBUG] Response status: ${e.response?.statusCode}');
      }

      final errorMessage = e.response?.data['error'] ??
          'Failed to remove player: ${e.message}';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to remove player: ${e.toString()}');
    }
  }

  /// Get player payment statuses for a team
  /// GET /api/team/:teamId/player-payments
  static Future<Map<String, dynamic>> getTeamPlayerPayments(String teamId) async {
    try {
      final dio = await _getAuthenticatedDio();

      final response = await dio.get('/team/$teamId/player-payments');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {
          'success': false,
          'message': response.statusMessage ?? 'Failed to get player payment statuses'
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return {
        'success': false,
        'message': e.response?.data?['error'] ?? 'Failed to get player payment statuses: ${e.message}'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting player payment statuses: $e'
      };
    }
  }
}


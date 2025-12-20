import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

/// Service for team-related API calls
class TeamService {
  /// Get Dio instance with authentication token and working URL
  static Future<Dio> _getAuthenticatedDio() async {
    final dio = await AuthService.getWorkingDio();
    print('📡 TeamService using base URL: ${dio.options.baseUrl}');
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

      final response = await dio.post(
        AppConfig.teamEndpoint,
        data: teamData,
      );

      if (response.statusCode == 201) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to create team: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['error'] ?? 
          'Failed to create team: ${e.message}';
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
        print('⚠️ No userId found in SharedPreferences');
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
          print('⚠️ No team data returned from API');
          return null; // Team not found
        }
        
        if (data is Map) {
          print('✅ Team data retrieved successfully');
          print('   Team ID: ${data['_id'] ?? data['id']}');
          print('   Team Name: ${data['teamName'] ?? data['name']}');
          
          // Log squad sizes for debugging
          final squad5v5 = data['squad5v5'] as List? ?? [];
          final squad7v7 = data['squad7v7'] as List? ?? [];
          print('   Squad 5v5 size: ${squad5v5.length}');
          print('   Squad 7v7 size: ${squad7v7.length}');
          
          return data as Map<String, dynamic>;
        }
        
        // Fallback: if data is a list, return first item
        if (data is List && data.isNotEmpty) {
          print('⚠️ Received list instead of single team, using first item');
          return data[0] as Map<String, dynamic>;
        }
        
        return null;
      } else {
        throw Exception(
          'Failed to fetch team: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        print('⚠️ Team not found (404)');
        return null; // Team not found
      }
      final errorMessage = e.response?.data['error'] ?? 
          'Failed to fetch team: ${e.message}';
      print('❌ Error fetching team: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('❌ General error fetching team: $e');
      throw Exception('Failed to fetch team: ${e.toString()}');
    }
  }

  /// Check if captain has a team
  static Future<bool> hasTeam() async {
    try {
      final team = await getTeamByCaptain();
      return team != null;
    } catch (e) {
      print('⚠️ Error checking team existence: $e');
      return false;
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
        throw Exception(
          'Failed to fetch team: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // Team not found - player has no team
      }
      final errorMessage = e.response?.data['error'] ?? 
          'Failed to fetch team: ${e.message}';
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

      final response = await dio.post(
        AppConfig.teamInvitePlayerEndpoint,
        data: {
          'playerId': playerId,
          'teamId': teamId,
          'format': format,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Player invited successfully');
        return true;
      } else {
        throw Exception(
          'Failed to invite player: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['error'] ?? 
          'Failed to invite player: ${e.message}';
      print('❌ Error inviting player: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('❌ General error inviting player: $e');
      throw Exception('Failed to invite player: ${e.toString()}');
    }
  }
}


import 'package:dio/dio.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/services/league_service.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';

/// Service for match/game-related API calls
class MatchService {
  /// Get Dio instance with authentication token and working URL
  static Future<Dio> _getAuthenticatedDio() async {
    // Use AuthService's working Dio instance which has the correct URL
    return await AuthService.getWorkingDio();
  }

  /// Create a new match
  /// POST /api/match
  static Future<MatchModel> createMatch(Map<String, dynamic> matchData) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.post('/match', data: matchData);

      if (response.statusCode == 201) {
        final data = response.data['data'];
        return _parseMatchFromJson(data);
      } else {
        throw Exception('Failed to create match: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Error creating match: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        throw Exception(
          e.response?.data['error'] ?? 'Failed to create match',
        );
      }
      rethrow;
    } catch (e) {
      print('General error creating match: $e');
      rethrow;
    }
  }

  /// Update an existing match
  /// PUT /api/match/:id
  static Future<MatchModel> updateMatch(
    String matchId,
    Map<String, dynamic> matchData,
  ) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.put('/match/$matchId', data: matchData);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return _parseMatchFromJson(data);
      } else {
        throw Exception('Failed to update match: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Error updating match: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        throw Exception(
          e.response?.data['error'] ?? 'Failed to update match',
        );
      }
      rethrow;
    } catch (e) {
      print('General error updating match: $e');
      rethrow;
    }
  }

  /// Get all matches from all leagues
  /// GET /api/match
  static Future<List<MatchModel>> getAllMatches() async {
    try {
      final dio = await _getAuthenticatedDio();
      print('🌐 Calling GET /match endpoint...');
      final response = await dio.get('/match');
      print('✅ Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        print('📦 Response data keys: ${data.keys}');
        if (data['data'] != null) {
          final matchesList = data['data'] as List;
          print('📊 Matches count in response: ${matchesList.length}');
          final matches = matchesList
              .map((json) {
                try {
                  return _parseMatchFromJson(json);
                } catch (parseError) {
                  print('❌ Error parsing match: $parseError');
                  print('   JSON: $json');
                  return null;
                }
              })
              .whereType<MatchModel>()
              .toList();
          print('✅ Successfully parsed ${matches.length} matches');
          return matches;
        }
        print('⚠️ No data field in response');
        return [];
      } else {
        print('❌ Failed to fetch all matches: ${response.statusMessage}');
        print('   Response data: ${response.data}');
        return [];
      }
    } on DioException catch (e) {
      print('❌ DioException fetching all matches:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Status code: ${e.response?.statusCode}');
      if (e.response != null) {
        print('   Error response data: ${e.response?.data}');
        print('   Error response headers: ${e.response?.headers}');
      }
      rethrow; // Re-throw to let provider handle it
    } catch (e) {
      print('❌ General error fetching all matches: $e');
      print('   Error type: ${e.runtimeType}');
      rethrow; // Re-throw to let provider handle it
    }
  }

  /// Get all matches for a league
  /// GET /api/match?leagueId=:id
  static Future<List<MatchModel>> getMatchesByLeague(String leagueId) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/match', queryParameters: {
        'leagueId': leagueId,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          final matches = (data['data'] as List)
              .map((json) => _parseMatchFromJson(json))
              .toList();
          return matches;
        }
        return [];
      } else {
        print('Failed to fetch matches: ${response.statusMessage}');
        return [];
      }
    } on DioException catch (e) {
      print('Error fetching matches: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('General error fetching matches: $e');
      rethrow;
    }
  }

  /// Get a single match by ID
  /// GET /api/match/:id
  static Future<MatchModel> getMatchById(String matchId) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/match/$matchId');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return _parseMatchFromJson(data);
      } else {
        throw Exception('Failed to get match: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Error fetching match: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        throw Exception(
          e.response?.data['error'] ?? 'Failed to get match',
        );
      }
      rethrow;
    } catch (e) {
      print('General error fetching match: $e');
      rethrow;
    }
  }

  /// Helper to extract team ID from various formats
  /// Handles: String, Map with _id, Map with id, null
  static String? _extractTeamId(dynamic teamData) {
    if (teamData == null) return null;
    if (teamData is String) return teamData;
    if (teamData is Map) {
      return teamData['_id']?.toString() ?? 
             teamData['id']?.toString() ?? 
             null;
    }
    return null;
  }

  /// Helper to lookup team name from dummy teams by ID
  static String _lookupTeamName(String? teamId) {
    if (teamId == null || teamId.isEmpty) {
      print('DEBUG: Team ID is null or empty');
      return 'Unknown Team';
    }
    
    // Normalize team ID (convert to string and trim)
    final normalizedId = teamId.toString().trim();
    print('DEBUG: Looking up team with ID: $normalizedId');
    
    try {
      final team = _getDummyTeams().firstWhere(
        (t) => t.id.toString().trim() == normalizedId,
        orElse: () {
          print('DEBUG: Team not found in dummy teams. Available IDs: ${_getDummyTeams().map((t) => t.id).join(", ")}');
          return TeamModel(
            id: normalizedId,
            teamName: 'Unknown Team',
            enterCode: null,
            location: null,
            skillLevel: null,
          );
        },
      );
      print('DEBUG: Found team: ${team.teamName}');
      return team.teamName;
    } catch (e) {
      print('DEBUG: Error looking up team: $e');
      return 'Unknown Team';
    }
  }

  /// In the future, teams will be fetched from the backend API
  /// Teams will be created by captains during team creation process
  /// This list should be removed once backend team fetching is fully implemented
  static List<TeamModel> _getDummyTeams() {
    return [
      TeamModel(
        id: '507f1f77bcf86cd799439011', // Valid MongoDB ObjectId format
        teamName: 'Shadow Wolves',
        enterCode: 'SW',
        location: 'City Arena',
        skillLevel: 'intermediate',
      ),
      TeamModel(
        id: '507f1f77bcf86cd799439012',
        teamName: 'Iron Rangers',
        enterCode: 'IR',
        location: 'Main Stadium',
        skillLevel: 'advanced',
      ),
      TeamModel(
        id: '507f1f77bcf86cd799439013',
        teamName: 'Eagle Eye',
        enterCode: 'EE',
        location: 'Training Ground A',
        skillLevel: 'beginner',
      ),
      TeamModel(
        id: '507f1f77bcf86cd799439014',
        teamName: 'Thunder Strike',
        enterCode: 'TS',
        location: 'City Arena',
        skillLevel: 'professional',
      ),
      TeamModel(
        id: '507f1f77bcf86cd799439015',
        teamName: 'Mystic Dragons',
        enterCode: 'MD',
        location: 'Training Ground B',
        skillLevel: 'intermediate',
      ),
    ];
  }

  /// Parse match JSON from backend to MatchModel
  static MatchModel _parseMatchFromJson(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    
    print('🔍 Parsing match: $id');
    print('   Raw gameDate: ${json['gameDate']}, type: ${json['gameDate']?.runtimeType}');
    print('   Raw gameTime: ${json['gameTime']}');
    print('   Raw status: ${json['status']}');

    // Parse league data
    final leagueData = json['leagueId'];
    final leagueName = leagueData is Map
        ? (leagueData['leagueName'] ?? '')
        : json['leagueName'] ?? '';
    
    // Extract league ID for filtering
    final leagueId = leagueData is Map
        ? (leagueData['_id']?.toString() ?? leagueData['id']?.toString())
        : (json['leagueId']?.toString());

    // Debug: Print team data to understand the format
    print('DEBUG: teamA data type: ${json['teamA'].runtimeType}, value: ${json['teamA']}');
    print('DEBUG: teamB data type: ${json['teamB'].runtimeType}, value: ${json['teamB']}');

    // Parse team A data
    // First check if team name is stored directly in database
    String teamAName = json['teamAName']?.toString() ?? '';
    String teamALogo = '';
    String? homeTeamId;

    // If stored name is empty, fallback to existing logic
    if (teamAName.isEmpty) {
      final teamAData = json['teamA'];
      
      if (teamAData == null) {
        // Team data is null - skip
        teamAName = '';
      } else if (teamAData is Map) {
        // Extract team ID for filtering
        homeTeamId = _extractTeamId(teamAData);
        
        // Check if team is populated (has teamName) or just has _id
        if (teamAData['teamName'] != null || teamAData['enterCode'] != null) {
          // Team is populated from backend (real team data)
          teamAName = teamAData['teamName'] ?? teamAData['enterCode'] ?? '';
          teamALogo = teamAData['image'] ?? '';
        } else {
          // Team has _id but not populated - look up from dummy teams
          teamAName = _lookupTeamName(homeTeamId);
        }
      } else if (teamAData is String) {
        // Team is just an ObjectId string - look up from dummy teams
        homeTeamId = teamAData;
        teamAName = _lookupTeamName(homeTeamId);
      }
    } else {
      // Stored name exists, but try to get logo from populated data if available
      final teamAData = json['teamA'];
      if (teamAData is Map) {
        homeTeamId = _extractTeamId(teamAData);
        if (teamAData['image'] != null) {
          teamALogo = teamAData['image'] ?? '';
        }
      } else if (teamAData is String) {
        homeTeamId = teamAData;
      }
    }

    // Parse team B data
    // First check if team name is stored directly in database
    String teamBName = json['teamBName']?.toString() ?? '';
    String teamBLogo = '';
    String? awayTeamId;

    // If stored name is empty, fallback to existing logic
    if (teamBName.isEmpty) {
      final teamBData = json['teamB'];
      
      if (teamBData == null) {
        // Team data is null - skip
        teamBName = '';
      } else if (teamBData is Map) {
        // Extract team ID for filtering
        awayTeamId = _extractTeamId(teamBData);
        
        // Check if team is populated (has teamName) or just has _id
        if (teamBData['teamName'] != null || teamBData['enterCode'] != null) {
          // Team is populated from backend (real team data)
          teamBName = teamBData['teamName'] ?? teamBData['enterCode'] ?? '';
          teamBLogo = teamBData['image'] ?? '';
        } else {
          // Team has _id but not populated - look up from dummy teams
          teamBName = _lookupTeamName(awayTeamId);
        }
      } else if (teamBData is String) {
        // Team is just an ObjectId string - look up from dummy teams
        awayTeamId = teamBData;
        teamBName = _lookupTeamName(awayTeamId);
      }
    } else {
      // Stored name exists, but try to get logo from populated data if available
      final teamBData = json['teamB'];
      if (teamBData is Map) {
        awayTeamId = _extractTeamId(teamBData);
        if (teamBData['image'] != null) {
          teamBLogo = teamBData['image'] ?? '';
        }
      } else if (teamBData is String) {
        awayTeamId = teamBData;
      }
    }

    // Parse date and time
    DateTime gameDate;
    if (json['gameDate'] != null) {
      try {
        final dateValue = json['gameDate'];
        
        // Handle different date formats from MongoDB
        if (dateValue is String) {
          // ISO string format
          gameDate = DateTime.parse(dateValue);
        } else if (dateValue is Map) {
          // MongoDB extended JSON format with $date
          if (dateValue['\$date'] != null) {
            final dateStr = dateValue['\$date'].toString();
            gameDate = DateTime.parse(dateStr);
          } else {
            // Try to parse as ISO string
            gameDate = DateTime.parse(dateValue.toString());
          }
        } else {
          // Try direct parsing (might be a Date object serialized)
          gameDate = DateTime.parse(dateValue.toString());
        }
      } catch (e) {
        print('❌ Error parsing gameDate: $e, value: ${json['gameDate']}, type: ${json['gameDate'].runtimeType}');
        // Fallback: use current date + 1 day to ensure it's in the future
        gameDate = DateTime.now().add(const Duration(days: 1));
      }
    } else {
      // Fallback: use current date + 1 day to ensure it's in the future
      gameDate = DateTime.now().add(const Duration(days: 1));
    }
    
    print('📅 Parsed gameDate: $gameDate for match ${json['_id'] ?? json['id']}');
    
    final gameTime = json['gameTime'] ?? '';

    // Combine date and time for matchDateTime
    DateTime? matchDateTime;
    if (gameTime.isNotEmpty) {
      try {
        // Parse time string (format: "HH:mm" or "HH:mm AM/PM" or "10:00")
        final timeParts = gameTime.trim().split(':');
        if (timeParts.length >= 2) {
          int hour = int.parse(timeParts[0].trim());
          final minutePart = timeParts[1].trim().split(RegExp(r'[\s]'))[0];
          int minute = int.parse(minutePart);
          
          // Check for AM/PM (case insensitive)
          final timeUpper = gameTime.toUpperCase();
          if (timeUpper.contains('PM') && hour != 12) {
            hour += 12;
          } else if (timeUpper.contains('AM') && hour == 12) {
            hour = 0;
          }
          
          // Ensure hour is in valid range
          if (hour < 0 || hour > 23) hour = 0;
          if (minute < 0 || minute > 59) minute = 0;
          
          matchDateTime = DateTime(
            gameDate.year,
            gameDate.month,
            gameDate.day,
            hour,
            minute,
          );
        } else {
          matchDateTime = gameDate;
        }
      } catch (e) {
        print('Error parsing gameTime: $e, value: $gameTime');
        matchDateTime = gameDate;
      }
    } else {
      matchDateTime = gameDate;
    }
    
    print('🕐 matchDateTime set to: $matchDateTime for match ${json['_id'] ?? json['id']}');

    // Format date as dd/MM
    final dateStr = '${gameDate.day.toString().padLeft(2, '0')}/${gameDate.month.toString().padLeft(2, '0')}';

    // Format time
    final timeStr = gameTime.isNotEmpty ? gameTime : '';

    // Parse status
    MatchStatus? status;
    final statusStr = json['status'] ?? 'upcoming';
    switch (statusStr) {
      case 'upcoming':
        status = MatchStatus.upcoming;
        break;
      case 'live':
        status = MatchStatus.live;
        break;
      case 'completed':
        status = MatchStatus.completed;
        break;
      case 'cancelled':
        status = MatchStatus.cancelled;
        break;
      default:
        status = MatchStatus.upcoming;
    }

    // Parse referee and stat keeper IDs
    final refereeData = json['refereeId'];
    final refereeId = refereeData is Map
        ? (refereeData['_id']?.toString() ?? refereeData['id']?.toString())
        : (json['refereeId']?.toString());

    final statKeeperData = json['statKeeperId'];
    final statKeeperId = statKeeperData is Map
        ? (statKeeperData['_id']?.toString() ?? statKeeperData['id']?.toString())
        : (json['statKeeperId']?.toString());

    return MatchModel(
      id: id,
      leagueName: leagueName,
      homeTeam: teamAName,
      homeTeamLogo: teamALogo,
      awayTeam: teamBName,
      awayTeamLogo: teamBLogo,
      date: dateStr,
      time: timeStr,
      status: status,
      matchDateTime: matchDateTime,
      venue: json['venue'] ?? '',
      refereeId: refereeId,
      statKeeperId: statKeeperId,
      roundName: json['roundName'] ?? '',
      gameNumber: json['gameNumber'] ?? '',
      homeScore: json['homeScore'],
      awayScore: json['awayScore'],
      leagueId: leagueId,
      homeTeamId: homeTeamId,
      awayTeamId: awayTeamId,
    );
  }
}


import 'package:dio/dio.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/services/league_service.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/stat_keeper/models/game_stat_model.dart';
import 'package:pffl_managment/features/stat_keeper/models/player_model.dart';
import 'package:pffl_managment/features/stat_keeper/models/team_model.dart';
import 'package:pffl_managment/features/stat_keeper/models/team_stat_model.dart';

/// Repository for Stat Keeper API operations
class StatKeeperRepository {
  /// Get Dio instance with authentication token
  static Future<Dio> _getAuthenticatedDio() async {
    return await AuthService.getWorkingDio();
  }

  /// Get all matches assigned to the current stat keeper
  static Future<List<MatchModel>> getAssignedMatches() async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/match/stat-keeper');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) return [];

        final matches = (data as List)
            .map((json) => MatchModel(
                  id: json['_id']?.toString(),
                  leagueName: json['leagueId'] is Map
                      ? json['leagueId']['leagueName'] ?? ''
                      : '',
                  homeTeam: json['teamAName'] ?? json['teamA'] ?? '',
                  homeTeamLogo: '',
                  awayTeam: json['teamBName'] ?? json['teamB'] ?? '',
                  awayTeamLogo: '',
                  date: '',
                  time: json['gameTime'] ?? '',
                  leagueId: json['leagueId'] is Map
                      ? json['leagueId']['_id']?.toString()
                      : json['leagueId']?.toString(),
                  homeTeamId: json['teamA']?.toString(),
                  awayTeamId: json['teamB']?.toString(),
                ))
            .toList();

        return matches;
      } else {
        throw Exception('Failed to fetch assigned matches');
      }
    } on DioException catch (e) {
      print('Error fetching assigned matches: ${e.message}');
      throw Exception('Failed to fetch assigned matches: ${e.message}');
    } catch (e) {
      print('General error fetching assigned matches: $e');
      throw Exception('Failed to fetch assigned matches');
    }
  }

  /// Get teams for a specific match
  /// Uses existing MatchService and LeagueService to get team data
  static Future<List<StatKeeperTeamModel>> getMatchTeams(String matchId) async {
    try {
      // Step 1: Get the match to find team IDs and league ID
      final match = await MatchService.getMatchById(matchId);
      if (match == null) {
        throw Exception('Match not found');
      }

      final leagueId = match.leagueId;
      if (leagueId == null || leagueId.isEmpty) {
        throw Exception('Match has no league ID');
      }

      // Step 2: Get the league to find team details
      final league = await LeagueService.getLeagueById(leagueId);
      if (league == null) {
        throw Exception('League not found');
      }

      // Step 3: Find the teams that are playing in this match
      final List<StatKeeperTeamModel> matchTeams = [];

      // Find home team
      if (match.homeTeamId != null && match.homeTeamId!.isNotEmpty) {
          final homeTeam = league.teams.firstWhere(
          (team) => team.id == match.homeTeamId,
          orElse: () => throw Exception('Home team not found in league'),
        );
        matchTeams.add(StatKeeperTeamModel.fromJson({
          '_id': homeTeam.id,
          'teamName': homeTeam.teamName,
          'image': homeTeam.image,
          'captain': homeTeam.captain,
          'squad5v5': homeTeam.squad5v5,
          'squad7v7': homeTeam.squad7v7,
        }));
      }

      // Find away team
      if (match.awayTeamId != null && match.awayTeamId!.isNotEmpty) {
          final awayTeam = league.teams.firstWhere(
          (team) => team.id == match.awayTeamId,
          orElse: () => throw Exception('Away team not found in league'),
        );
        matchTeams.add(StatKeeperTeamModel.fromJson({
          '_id': awayTeam.id,
          'teamName': awayTeam.teamName,
          'image': awayTeam.image,
          'captain': awayTeam.captain,
          'squad5v5': awayTeam.squad5v5,
          'squad7v7': awayTeam.squad7v7,
        }));
      }

      return matchTeams;
    } catch (e) {
      print('Error fetching match teams: $e');
      throw Exception('Failed to fetch match teams: ${e.toString()}');
    }
  }

  /// Get players for a specific team who played in a match
  /// Fetches players from match data (attendance/selected players) for the specified team
  static Future<List<StatKeeperPlayerModel>> getMatchTeamPlayers(String matchId, String teamId) async {
    try {

      // Fetch the raw match data to get the players array for each team
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/match/$matchId');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) {
          print('❌ No match data returned');
          return [];
        }

        // Extract players from the specific team's data in the match
        final teamAData = data['teamA'] as Map<String, dynamic>?;
        final teamBData = data['teamB'] as Map<String, dynamic>?;

        List<dynamic> teamPlayers = [];

        // Find the team data that matches the requested teamId
        if (teamAData != null && _extractTeamId(teamAData) == teamId) {
          teamPlayers = teamAData['players'] as List<dynamic>? ?? [];
        } else if (teamBData != null && _extractTeamId(teamBData) == teamId) {
          teamPlayers = teamBData['players'] as List<dynamic>? ?? [];
        } else {
          return [];
        }

        final players = _parsePlayersFromMatchData(teamPlayers);
        return players;
      } else {
        print('❌ Failed to fetch match data: ${response.statusMessage}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching match team players: $e');
      throw Exception('Failed to fetch match team players: ${e.toString()}');
    }
  }

  /// Get players who actually played in a match
  /// Fetches players from match data (attendance/selected players), not team master data
  static Future<List<StatKeeperPlayerModel>> getMatchPlayers(String matchId) async {
    try {
      // Get the match data to find attendance/selected players
      final match = await MatchService.getMatchById(matchId);
      if (match == null) {
        return [];
      }

      final List<StatKeeperPlayerModel> allPlayers = [];

      // We need to fetch the raw match data to get the players array
      // The MatchService.getMatchById doesn't parse the players array
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/match/$matchId');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) {
          return [];
        }

        // Extract players from teamA and teamB data in the match
        final teamAData = data['teamA'] as Map<String, dynamic>?;
        final teamBData = data['teamB'] as Map<String, dynamic>?;

        // Process teamA players
        if (teamAData != null && teamAData['players'] is List) {
          final teamAPlayers = teamAData['players'] as List;
          allPlayers.addAll(_parsePlayersFromMatchData(teamAPlayers));
        }

        // Process teamB players
        if (teamBData != null && teamBData['players'] is List) {
          final teamBPlayers = teamBData['players'] as List;
          allPlayers.addAll(_parsePlayersFromMatchData(teamBPlayers));
        }

        return allPlayers;
      } else {
        print('❌ Failed to fetch match data: ${response.statusMessage}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching match players: $e');
      throw Exception('Failed to fetch match players: ${e.toString()}');
    }
  }

  /// Helper to extract team ID from various formats
  /// Handles: String, Map with _id, Map with id, nested teamId structure, null
  static String? _extractTeamId(dynamic teamData) {
    if (teamData == null) return null;
    if (teamData is String) return teamData;
    if (teamData is Map) {
      // Check for teamId first (for teamA.teamId or teamB.teamId structure)
      if (teamData['teamId'] != null) {
        final teamId = teamData['teamId'];
        // If teamId is a Map (nested structure), extract _id from it
        if (teamId is Map) {
          return teamId['_id']?.toString() ?? teamId['id']?.toString();
        }
        // If teamId is a String, return it directly
        if (teamId is String) {
          return teamId;
        }
      }

      // Then check for _id (for populated team objects)
      // Finally check for id
      return teamData['_id']?.toString() ??
             teamData['id']?.toString() ??
             null;
    }
    return null;
  }

  /// Helper method to parse players from match team data
  static List<StatKeeperPlayerModel> _parsePlayersFromMatchData(List<dynamic> playersData) {
    final players = <StatKeeperPlayerModel>[];

    for (final playerData in playersData) {
      if (playerData is Map<String, dynamic>) {
        final playerId = playerData['_id']?.toString() ?? playerData['id']?.toString();
        final firstName = playerData['firstName'] ?? '';
        final lastName = playerData['lastName'] ?? '';
        final email = playerData['email'] ?? '';

        if (playerId != null && playerId.isNotEmpty) {
          players.add(StatKeeperPlayerModel(
            id: playerId,
            name: '$firstName $lastName'.trim().isEmpty ? 'Player $playerId' : '$firstName $lastName'.trim(),
            number: playerData['number']?.toString() ?? '',
            email: email,
            position: playerData['position'] ?? '',
            isCaptain: playerData['isCaptain'] ?? false,
          ));
        }
      } else if (playerData is String && playerData.isNotEmpty) {
        // Handle case where player is just an ID string
        players.add(StatKeeperPlayerModel(
          id: playerData,
          name: 'Player $playerData',
          number: '',
          email: '',
          position: '',
          isCaptain: false,
        ));
      }
    }

    return players;
  }

  /// Add stats to a match
  /// NOTE: This endpoint (/match/:matchId/stats) doesn't exist yet.
  /// The backend needs to implement stats storage in the Match collection.
  /// For now, this creates a local GameStatModel for UI purposes.
  static Future<GameStatModel> addMatchStats({
    required String matchId,
    required String teamId,
    String? playerId,
    required int catches,
    required int catchesYards,
    required int rushes,
    required int rushesYards,
    required int passAttempts,
    required int passYards,
    required int completions,
    required int tds,
    required int flagPull,
    required int sack,
    required int interceptions,
    required int safety,
    required int conversionPoints,
  }) async {
    try {
      // TODO: Implement backend endpoint /api/match/:matchId/stats
      // For now, simulate success and return a GameStatModel
      print('⚠️ addMatchStats called - backend endpoint not implemented yet');
      print('   Match ID: $matchId');
      print('   Team ID: $teamId');
      print('   Player ID: $playerId');
      print('   Stats: catches=$catches, tds=$tds, etc.');

      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Return a mock GameStatModel for UI purposes
      // In a real implementation, this would parse the response from the backend
      return GameStatModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        leagueName: 'Current League',
        team1Name: 'Team A',
        team1Logo: '',
        team2Name: 'Team B',
        team2Logo: '',
        date: DateTime.now(),
        time: DateTime.now().toString(),
        status: StatStatus.draft,
        team1Stats: TeamStatModel(
          teamName: 'Team A',
          teamLogo: '',
          catches: catches,
          catchesYards: catchesYards,
          rushes: rushes,
          rushesYards: rushesYards,
          passAttempts: passAttempts,
          passYards: passYards,
          completions: completions,
          tds: tds,
          flagPull: flagPull,
          sack: sack,
          interceptions: interceptions,
          safety: safety,
          conversionPoints: conversionPoints,
          playerStats: playerId != null ? [
            PlayerStatModel(
              playerId: playerId,
              playerName: 'Selected Player',
              catches: catches,
              catchesYards: catchesYards,
              rushes: rushes,
              rushesYards: rushesYards,
              passAttempts: passAttempts,
              passYards: passYards,
              completions: completions,
              tds: tds,
              flagPull: flagPull,
              sack: sack,
              interceptions: interceptions,
              safety: safety,
              conversionPoints: conversionPoints,
            )
          ] : [],
        ),
        team2Stats: TeamStatModel(
          teamName: 'Team B',
          teamLogo: '',
        ),
      );

      // Uncomment below when backend endpoint is implemented:
      /*
      final dio = await _getAuthenticatedDio();

      final statsData = {
        'teamId': teamId,
        if (playerId != null) 'playerId': playerId,
        'stats': {
          'catches': catches,
          'catchesYards': catchesYards,
          'rushes': rushes,
          'rushesYards': rushesYards,
          'passAttempts': passAttempts,
          'passYards': passYards,
          'completions': completions,
          'tds': tds,
          'flagPull': flagPull,
          'sack': sack,
          'interceptions': interceptions,
          'safety': safety,
          'conversionPoints': conversionPoints,
        }
      };

      final response = await dio.post('/match/$matchId/stats', data: statsData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        return _parseGameStatFromJson(data);
      } else {
        throw Exception('Failed to add match stats');
      }
      */
    } catch (e) {
      print('Error adding match stats: $e');
      throw Exception('Failed to add match stats: ${e.toString()}');
    }
  }

  /// Get current stats for a match
  /// NOTE: This endpoint doesn't exist yet. Returns null for now.
  static Future<GameStatModel?> getMatchStats(String matchId) async {
    // TODO: Implement backend endpoint /api/match/:matchId/stats
    print('⚠️ getMatchStats called - backend endpoint not implemented yet');
    return null; // No stats available yet
  }

  /// Update existing match stats
  /// NOTE: This endpoint doesn't exist yet. For now, delegates to addMatchStats.
  static Future<GameStatModel> updateMatchStats({
    required String matchId,
    required String statId,
    required String teamId,
    String? playerId,
    required int catches,
    required int catchesYards,
    required int rushes,
    required int rushesYards,
    required int passAttempts,
    required int passYards,
    required int completions,
    required int tds,
    required int flagPull,
    required int sack,
    required int interceptions,
    required int safety,
    required int conversionPoints,
  }) async {
    // TODO: Implement backend endpoint /api/match/:matchId/stats/:statId
    print('⚠️ updateMatchStats called - backend endpoint not implemented yet');
    print('   Would update stat ID: $statId');

    // For now, delegate to addMatchStats (which creates new stats)
    return addMatchStats(
      matchId: matchId,
      teamId: teamId,
      playerId: playerId,
      catches: catches,
      catchesYards: catchesYards,
      rushes: rushes,
      rushesYards: rushesYards,
      passAttempts: passAttempts,
      passYards: passYards,
      completions: completions,
      tds: tds,
      flagPull: flagPull,
      sack: sack,
      interceptions: interceptions,
      safety: safety,
      conversionPoints: conversionPoints,
    );
  }

}

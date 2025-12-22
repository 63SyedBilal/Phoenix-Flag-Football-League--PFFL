import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/core/services/team_service.dart';
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
      // Get current user ID
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('userId') ?? '';

      if (currentUserId.isEmpty) {
        throw Exception('User ID not found');
      }

      // Fetch all matches using MatchService which handles parsing robustness
      final allMatches = await MatchService.getAllMatches();

      // Filter matches assigned to this user (as Stat Keeper or Referee)
      final assignedMatches = allMatches.where((match) {
        final isStatKeeper =
            match.statKeeperId != null &&
            match.statKeeperId!.isNotEmpty &&
            match.statKeeperId == currentUserId;
        final isReferee =
            match.refereeId != null &&
            match.refereeId!.isNotEmpty &&
            match.refereeId == currentUserId;
        return isStatKeeper || isReferee;
      }).toList();

      return assignedMatches;
    } catch (e) {
      print('Error fetching assigned matches: $e');
      throw Exception('Failed to fetch assigned matches: ${e.toString()}');
    }
  }

  /// Get teams for a specific match
  /// Uses existing MatchService to get team data directly from the match
  static Future<List<StatKeeperTeamModel>> getMatchTeams(String matchId) async {
    try {
      // Step 1: Get the match to find team IDs and names
      final match = await MatchService.getMatchById(matchId);

      // Step 2: Extract teams directly from MatchModel
      final List<StatKeeperTeamModel> matchTeams = [];

      // Add home team
      if (match.homeTeamId != null && match.homeTeamId!.isNotEmpty) {
        matchTeams.add(
          StatKeeperTeamModel.fromJson({
            '_id': match.homeTeamId,
            'teamName': match.homeTeam.isNotEmpty
                ? match.homeTeam
                : 'Home Team',
            'image': match.homeTeamLogo,
            // We might lack captain/squad info here if not in MatchModel,
            // but for stats dropdown, ID and Name are critical.
            // If strictly needed, we could fetch Team details,
            // but requirements say "Teams must come from the Match document".
          }),
        );
      }

      // Add away team
      if (match.awayTeamId != null && match.awayTeamId!.isNotEmpty) {
        matchTeams.add(
          StatKeeperTeamModel.fromJson({
            '_id': match.awayTeamId,
            'teamName': match.awayTeam.isNotEmpty
                ? match.awayTeam
                : 'Away Team',
            'image': match.awayTeamLogo,
          }),
        );
      }

      return matchTeams;
    } catch (e) {
      print('Error fetching match teams: $e');
      throw Exception('Failed to fetch match teams: ${e.toString()}');
    }
  }

  /// Get players for a specific team who played in a match
  /// Fetches players from the Team Service to get the FULL ROSTER as per user request.
  static Future<List<StatKeeperPlayerModel>> getMatchTeamPlayers(
    String matchId,
    String teamId,
  ) async {
    try {
      // 1. Fetch the full Team details directly from TeamService
      // This ensures we get ALL players added by the captain, not just those in the match.
      final teamData = await TeamService.getTeamById(teamId);

      if (teamData == null) {
        print('❌ Team not found: $teamId');
        return [];
      }

      final List<StatKeeperPlayerModel> allPlayers = [];
      final Set<String> processedIds =
          {}; // To avoid duplicates if a player is in both squads

      // Helper to process squad lists
      void processSquad(List<dynamic>? squad) {
        if (squad == null) return;

        for (final p in squad) {
          if (p is Map<String, dynamic>) {
            final id = p['_id']?.toString() ?? p['id']?.toString();
            if (id != null && !processedIds.contains(id)) {
              processedIds.add(id);

              final firstName = p['firstName'] ?? '';
              final lastName = p['lastName'] ?? '';
              final name = '$firstName $lastName'.trim();

              allPlayers.add(
                StatKeeperPlayerModel(
                  id: id,
                  name: name.isEmpty ? 'Player' : name,
                  number: p['number']?.toString() ?? '',
                  email: p['email'] ?? '',
                  position: p['position'] ?? '',
                  isCaptain:
                      false, // Can't determine captaincy easily from mixed squads without loop
                ),
              );
            }
          }
        }
      }

      // 2. Extract players from both squads
      processSquad(teamData['squad5v5'] as List?);
      processSquad(teamData['squad7v7'] as List?);

      print('✅ Fetched ${allPlayers.length} players from team roster');
      return allPlayers;
    } catch (e) {
      print('❌ Error fetching team roster: $e');
      throw Exception('Failed to fetch team players: ${e.toString()}');
    }
  }

  /// Get players who actually played in a match
  /// Fetches players from match data (attendance/selected players), not team master data
  static Future<List<StatKeeperPlayerModel>> getMatchPlayers(
    String matchId,
  ) async {
    try {
      // Get the match data to find attendance/selected players
      await MatchService.getMatchById(matchId);

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

  /// Helper method to parse players from match team data
  static List<StatKeeperPlayerModel> _parsePlayersFromMatchData(
    List<dynamic> playersData,
  ) {
    final players = <StatKeeperPlayerModel>[];

    for (final playerData in playersData) {
      if (playerData is Map<String, dynamic>) {
        final playerId =
            playerData['_id']?.toString() ?? playerData['id']?.toString();
        final firstName = playerData['firstName'] ?? '';
        final lastName = playerData['lastName'] ?? '';
        final email = playerData['email'] ?? '';

        if (playerId != null && playerId.isNotEmpty) {
          players.add(
            StatKeeperPlayerModel(
              id: playerId,
              name: '$firstName $lastName'.trim().isEmpty
                  ? 'Player $playerId'
                  : '$firstName $lastName'.trim(),
              number: playerData['number']?.toString() ?? '',
              email: email,
              position: playerData['position'] ?? '',
              isCaptain: playerData['isCaptain'] ?? false,
            ),
          );
        }
      } else if (playerData is String && playerData.isNotEmpty) {
        // Handle case where player is just an ID string
        players.add(
          StatKeeperPlayerModel(
            id: playerData,
            name: 'Player $playerData',
            number: '',
            email: '',
            position: '',
            isCaptain: false,
          ),
        );
      }
    }

    return players;
  }

  /// Add/Update stats via the new Stat collection
  static Future<void> saveStat({
    required String leagueId,
    required String matchId,
    required String teamId,
    required String playerId,
    required Map<String, dynamic> stats,
  }) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.post(
        '/stats',
        data: {
          'leagueId': leagueId,
          'matchId': matchId,
          'teamId': teamId,
          'playerId': playerId,
          'stats': stats,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to save stat');
      }
    } catch (e) {
      print('Error saving stat: $e');
      throw Exception('Failed to save stat: ${e.toString()}');
    }
  }

  /// Get stats for a match with optional filters
  static Future<List<dynamic>> getMatchStatsList({
    required String matchId,
    String? status,
    String? createdBy,
  }) async {
    try {
      final dio = await _getAuthenticatedDio();
      final queryParams = {
        'matchId': matchId,
        if (status != null) 'status': status,
        if (createdBy != null) 'createdBy': createdBy,
      };

      final response = await dio.get('/stats', queryParameters: queryParams);

      if (response.statusCode == 200) {
        return response.data['data'] as List? ?? [];
      } else {
        throw Exception('Failed to fetch stats');
      }
    } catch (e) {
      print('Error fetching stats: $e');
      throw Exception('Failed to fetch stats: ${e.toString()}');
    }
  }

  /// Submit all DRAFT stats for a match for approval
  static Future<void> submitStatsForApproval(String matchId) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.post(
        '/stats/submit',
        data: {'matchId': matchId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to submit stats for approval');
      }
    } catch (e) {
      print('Error submitting stats: $e');
      throw Exception('Failed to submit stats: ${e.toString()}');
    }
  }

  /// Approve stats for a match (Admin only)
  static Future<void> approveStats(String matchId, String statkeeperId) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.post(
        '/stats/approve',
        data: {'matchId': matchId, 'statkeeperId': statkeeperId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to approve stats');
      }
    } catch (e) {
      print('Error approving stats: $e');
      throw Exception('Failed to approve stats: ${e.toString()}');
    }
  }

  /// Add stats to a match (Thin wrapper around saveStat)
  static Future<void> addMatchStats({
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
    if (playerId == null) throw Exception('Player ID is required');

    // Get match to get leagueId
    final match = await MatchService.getMatchById(matchId);

    await saveStat(
      leagueId: match.leagueId ?? '',
      matchId: matchId,
      teamId: teamId,
      playerId: playerId,
      stats: {
        'catches': catches,
        'catchYards': catchesYards,
        'rushes': rushes,
        'rushYards': rushesYards,
        'passAttempts': passAttempts,
        'passYards': passYards,
        'completions': completions,
        'touchdowns': tds,
        'flagPull': flagPull,
        'sack': sack,
        'interceptions': interceptions,
        'safeties': safety,
        'extraPoints': conversionPoints,
      },
    );
  }

  /// Update existing match stats (Thin wrapper around addMatchStats)
  static Future<void> updateMatchStats({
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
    // In the new system, update and add are the same (upsert logic in backend)
    await addMatchStats(
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

  /// Get current cumulative stats for a match (From Match document)
  static Future<GameStatModel?> getMatchStats(String matchId) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/match/$matchId');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) return null;

        // Parse team stats from the match data
        final team1Stats = _parseTeamStats(data['teamA'], 'Team A');
        final team2Stats = _parseTeamStats(data['teamB'], 'Team B');

        // Parse basic match info
        final dateValue = data['gameDate'];
        DateTime date;
        if (dateValue != null) {
          date = DateTime.tryParse(dateValue.toString()) ?? DateTime.now();
        } else {
          date = DateTime.now();
        }

        final leagueIdData = data['leagueId'];
        String leagueName = '';
        if (leagueIdData is Map) {
          leagueName = leagueIdData['leagueName'] ?? '';
        }

        return GameStatModel(
          id: data['_id']?.toString() ?? matchId,
          leagueName: leagueName,
          team1Name: team1Stats.teamName,
          team1Logo: team1Stats.teamLogo,
          team2Name: team2Stats.teamName,
          team2Logo: team2Stats.teamLogo,
          date: date,
          time: data['gameTime'] ?? '',
          status: _parseMatchStatus(data['status']),
          team1Stats: team1Stats,
          team2Stats: team2Stats,
          isAssignedToMe: true,
          isCompleted: data['status'] == 'completed',
        );
      }
      return null;
    } catch (e) {
      print('Error fetching match stats: $e');
      throw Exception('Failed to fetch match stats: ${e.toString()}');
    }
  }

  // Helper parsing methods

  static TeamStatModel _parseTeamStats(dynamic teamData, String defaultName) {
    if (teamData == null || teamData is! Map) {
      return TeamStatModel(teamName: defaultName, teamLogo: '');
    }

    // Backend schema uses `teamStats` and `playerStats`
    final stats =
        teamData['teamStats'] as Map? ?? teamData['stats'] as Map? ?? {};
    final players =
        teamData['playerStats'] as List? ?? teamData['players'] as List? ?? [];

    // Parse players
    final List<PlayerStatModel> playerStatsList = [];
    for (final p in players) {
      if (p is Map) {
        // Find player ID (schema uses `playerId`)
        final id =
            p['playerId']?.toString() ??
            p['_id']?.toString() ??
            p['id']?.toString() ??
            '';

        // Find player name from the populated player or elsewhere
        // Note: Match schema doesn't always have names in playerStats,
        // they might be in the separate `players` array or populated.
        String name = 'Player';
        final firstName = p['firstName'] ?? '';
        final lastName = p['lastName'] ?? '';
        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          name = '$firstName $lastName'.trim();
        }

        playerStatsList.add(
          PlayerStatModel(
            playerId: id,
            playerName: name,
            catches: coin(p['catches']),
            catchesYards: coin(p['catchYards'] ?? p['catchesYards']),
            rushes: coin(p['rushes']),
            rushesYards: coin(p['rushYards'] ?? p['rushesYards']),
            passAttempts: coin(p['passAttempts']),
            passYards: coin(p['passYards']),
            completions: coin(p['completions']),
            tds: coin(p['touchdowns'] ?? p['tds']),
            flagPull: coin(p['flags'] ?? p['flagPull']),
            sack: coin(p['sack']),
            interceptions: coin(p['defensiveTDs'] ?? p['interceptions']),
            safety: coin(p['safeties'] ?? p['safety']),
            conversionPoints: coin(p['extraPoints'] ?? p['conversionPoints']),
          ),
        );
      }
    }

    String teamName = defaultName;
    String teamLogo = '';

    if (teamData['teamName'] != null)
      teamName = teamData['teamName'];
    else if (teamData['enterCode'] != null)
      teamName = teamData['enterCode'];

    if (teamData['image'] != null) teamLogo = teamData['image'];

    return TeamStatModel(
      teamName: teamName,
      teamLogo: teamLogo,
      catches: coin(stats['catches']),
      catchesYards: coin(stats['catchYards'] ?? stats['catchesYards']),
      rushes: coin(stats['rushes']),
      rushesYards: coin(stats['rushYards'] ?? stats['rushesYards']),
      passAttempts: coin(stats['passAttempts']),
      passYards: coin(stats['passYards']),
      completions: coin(stats['completions']),
      tds: coin(stats['touchdowns'] ?? stats['tds']),
      flagPull: coin(stats['flags'] ?? stats['flagPull']),
      sack: coin(stats['sack']),
      interceptions: coin(stats['defensiveTDs'] ?? stats['interceptions']),
      safety: coin(stats['safeties'] ?? stats['safety']),
      conversionPoints: coin(stats['extraPoints'] ?? stats['conversionPoints']),
      playerStats: playerStatsList,
    );
  }

  static int coin(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  static StatStatus _parseMatchStatus(String? status) {
    if (status == 'completed') return StatStatus.approved;
    return StatStatus.draft;
  }
}

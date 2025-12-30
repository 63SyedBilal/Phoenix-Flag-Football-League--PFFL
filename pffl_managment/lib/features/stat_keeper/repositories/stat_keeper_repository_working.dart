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

/// WORKING repository that uses existing backend endpoints
class StatKeeperRepositoryWorking {
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
      throw Exception('Failed to fetch assigned matches: ${e.toString()}');
    }
  }

  /// Get teams for a specific match
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
      throw Exception('Failed to fetch match teams: ${e.toString()}');
    }
  }

  /// Get players for a specific team who played in a match
  static Future<List<StatKeeperPlayerModel>> getMatchTeamPlayers(
    String matchId,
    String teamId,
  ) async {
    try {
      // Fetch the full Team details directly from TeamService
      final teamData = await TeamService.getTeamById(teamId);

      if (teamData == null) {
        return [];
      }

      final List<StatKeeperPlayerModel> allPlayers = [];
      final Set<String> processedIds = {};

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
                  isCaptain: false,
                ),
              );
            }
          }
        }
      }

      // Extract players from both squads
      processSquad(teamData['squad5v5'] as List?);
      processSquad(teamData['squad7v7'] as List?);
      return allPlayers;
    } catch (e) {
      throw Exception('Failed to fetch team players: ${e.toString()}');
    }
  }

  /// WORKING: Save stats using existing match action endpoint
  static Future<void> addMatchStatsWorking({
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
    if (playerId == null || playerId.isEmpty) {
      throw Exception('Player ID is required and cannot be empty');
    }

    try {

      final dio = await _getAuthenticatedDio();

      // Create individual actions for each non-zero stat
      final actions = <Map<String, dynamic>>[];

      // Add actions for each stat type
      if (catches > 0) {
        actions.add({
          'teamId': teamId,
          'playerId': playerId,
          'actionType': 'CATCH',
          'count': catches,
          'yards': catchesYards,
        });
      }

      if (rushes > 0) {
        actions.add({
          'teamId': teamId,
          'playerId': playerId,
          'actionType': 'RUSH',
          'count': rushes,
          'yards': rushesYards,
        });
      }

      if (passAttempts > 0) {
        actions.add({
          'teamId': teamId,
          'playerId': playerId,
          'actionType': 'PASS_ATTEMPT',
          'count': passAttempts,
          'yards': passYards,
          'completions': completions,
        });
      }

      if (tds > 0) {
        actions.add({
          'teamId': teamId,
          'playerId': playerId,
          'actionType': 'TOUCHDOWN',
          'count': tds,
        });
      }

      if (flagPull > 0) {
        actions.add({
          'teamId': teamId,
          'playerId': playerId,
          'actionType': 'FLAG_PULL',
          'count': flagPull,
        });
      }

      if (sack > 0) {
        actions.add({
          'teamId': teamId,
          'playerId': playerId,
          'actionType': 'SACK',
          'count': sack,
        });
      }

      if (interceptions > 0) {
        actions.add({
          'teamId': teamId,
          'playerId': playerId,
          'actionType': 'INTERCEPTION',
          'count': interceptions,
        });
      }

      if (safety > 0) {
        actions.add({
          'teamId': teamId,
          'playerId': playerId,
          'actionType': 'SAFETY',
          'count': safety,
        });
      }

      if (conversionPoints > 0) {
        actions.add({
          'teamId': teamId,
          'playerId': playerId,
          'actionType': 'EXTRA_POINT',
          'count': conversionPoints,
        });
      }

      // If no stats to save, create a general stat update action
      if (actions.isEmpty) {
        actions.add({
          'teamId': teamId,
          'playerId': playerId,
          'actionType': 'STAT_UPDATE',
          'stats': {
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
        });
      }

      // Send each action individually using the existing endpoint
      for (int i = 0; i < actions.length; i++) {
        final action = actions[i];

        try {
          final response = await dio.post(
            '/match/$matchId/action',
            data: action,
          );

          print(
            '✅ [WORKING STATS] Action ${i + 1} success: ${response.statusCode}',
          );

          if (response.statusCode != 200 && response.statusCode != 201) {
            print(
              '⚠️ [WORKING STATS] Unexpected status: ${response.statusCode}',
            );
          }
        } catch (actionError) {

          // Continue with other actions even if one fails
          if (actionError is DioException) {
            print(
              '❌ [WORKING STATS] Status: ${actionError.response?.statusCode}',
            );
          }
        }
      }
    } catch (e) {
      rethrow;
    }
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
      throw Exception('Failed to fetch match stats: ${e.toString()}');
    }
  }

  /// Get stats for a match - use match data since separate stats endpoint doesn't exist
  static Future<List<dynamic>> getMatchStatsList({
    required String matchId,
    String? status,
    String? createdBy,
  }) async {
    try {
      // Since /stats endpoint doesn't exist, return match actions as stats
      final match = await MatchService.getMatchById(matchId);

      // Convert match actions to stats format
      final statsList = <dynamic>[];

      for (final action in match.actions) {
        if (action['playerId'] != null &&
            (createdBy == null || action['createdBy'] == createdBy)) {
          statsList.add({
            '_id':
                '${matchId}_${action['playerId']}_${DateTime.now().millisecondsSinceEpoch}',
            'matchId': matchId,
            'playerId': action['playerId'],
            'teamId': action['teamId'],
            'actionType': action['actionType'],
            'stats': action,
            'status': status ?? 'DRAFT',
            'createdBy': createdBy,
          });
        }
      }

      return statsList;
    } catch (e) {
      return [];
    }
  }

  /// Submit stats for approval - use match status update
  static Future<void> submitStatsForApproval(String matchId) async {
    try {

      // Since there's no separate stats approval endpoint,
      // we'll update the match status to indicate stats are ready for review
      final dio = await _getAuthenticatedDio();

      final response = await dio.put(
        '/match/$matchId',
        data: {
          'statsStatus': 'PENDING_APPROVAL',
          'statsSubmittedAt': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to submit stats for approval');
      }
    } catch (e) {
      throw Exception('Failed to submit stats: ${e.toString()}');
    }
  }

  // Helper parsing methods
  static TeamStatModel _parseTeamStats(dynamic teamData, String defaultName) {
    if (teamData == null || teamData is! Map) {
      return TeamStatModel(teamName: defaultName, teamLogo: '');
    }

    final stats =
        teamData['teamStats'] as Map? ?? teamData['stats'] as Map? ?? {};
    final players =
        teamData['playerStats'] as List? ?? teamData['players'] as List? ?? [];

    final List<PlayerStatModel> playerStatsList = [];
    for (final p in players) {
      if (p is Map) {
        final id =
            p['playerId']?.toString() ??
            p['_id']?.toString() ??
            p['id']?.toString() ??
            '';

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
            catches: _toInt(p['catches']),
            catchesYards: _toInt(p['catchYards'] ?? p['catchesYards']),
            rushes: _toInt(p['rushes']),
            rushesYards: _toInt(p['rushYards'] ?? p['rushesYards']),
            passAttempts: _toInt(p['passAttempts']),
            passYards: _toInt(p['passYards']),
            completions: _toInt(p['completions']),
            tds: _toInt(p['touchdowns'] ?? p['tds']),
            flagPull: _toInt(p['flags'] ?? p['flagPull']),
            sack: _toInt(p['sack']),
            interceptions: _toInt(p['defensiveTDs'] ?? p['interceptions']),
            safety: _toInt(p['safeties'] ?? p['safety']),
            conversionPoints: _toInt(p['extraPoints'] ?? p['conversionPoints']),
          ),
        );
      }
    }

    String teamName = defaultName;
    String teamLogo = '';

    if (teamData['teamName'] != null) {
      teamName = teamData['teamName'];
    } else if (teamData['enterCode'] != null) {
      teamName = teamData['enterCode'];
    }

    if (teamData['image'] != null) teamLogo = teamData['image'];

    return TeamStatModel(
      teamName: teamName,
      teamLogo: teamLogo,
      catches: _toInt(stats['catches']),
      catchesYards: _toInt(stats['catchYards'] ?? stats['catchesYards']),
      rushes: _toInt(stats['rushes']),
      rushesYards: _toInt(stats['rushYards'] ?? stats['rushesYards']),
      passAttempts: _toInt(stats['passAttempts']),
      passYards: _toInt(stats['passYards']),
      completions: _toInt(stats['completions']),
      tds: _toInt(stats['touchdowns'] ?? stats['tds']),
      flagPull: _toInt(stats['flags'] ?? stats['flagPull']),
      sack: _toInt(stats['sack']),
      interceptions: _toInt(stats['defensiveTDs'] ?? stats['interceptions']),
      safety: _toInt(stats['safeties'] ?? stats['safety']),
      conversionPoints: _toInt(
        stats['extraPoints'] ?? stats['conversionPoints'],
      ),
      playerStats: playerStatsList,
    );
  }

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  static StatStatus _parseMatchStatus(String? status) {
    if (status == 'completed') return StatStatus.approved;
    return StatStatus.draft;
  }
}


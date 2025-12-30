import 'package:dio/dio.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/services/league_service.dart';
import 'package:pffl_managment/core/services/team_service.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/stat_keeper/models/team_stat_model.dart';

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
        final data = response.data?['data'];
        if (data == null) {
          throw Exception('Invalid response format: missing data field');
        }
        final parsed = _parseMatchFromJson(data);
        final fallbackHomeName = matchData['teamAName']?.toString();
        final fallbackAwayName = matchData['teamBName']?.toString();
        final fallbackHomeId = matchData['teamA']?.toString();
        final fallbackAwayId = matchData['teamB']?.toString();

        MatchModel fixed = parsed;
        final needsHomeNameFix =
            (parsed.homeTeam.isEmpty || parsed.homeTeam == 'Unknown Team') &&
            (fallbackHomeName != null && fallbackHomeName.isNotEmpty);
        final needsAwayNameFix =
            (parsed.awayTeam.isEmpty || parsed.awayTeam == 'Unknown Team') &&
            (fallbackAwayName != null && fallbackAwayName.isNotEmpty);
        final needsHomeIdFix =
            (parsed.homeTeamId == null || parsed.homeTeamId!.isEmpty) &&
            (fallbackHomeId != null && fallbackHomeId.isNotEmpty);
        final needsAwayIdFix =
            (parsed.awayTeamId == null || parsed.awayTeamId!.isEmpty) &&
            (fallbackAwayId != null && fallbackAwayId.isNotEmpty);

        if (needsHomeNameFix ||
            needsAwayNameFix ||
            needsHomeIdFix ||
            needsAwayIdFix) {
          fixed = parsed.copyWith(
            homeTeam: needsHomeNameFix ? fallbackHomeName : null,
            awayTeam: needsAwayNameFix ? fallbackAwayName : null,
            homeTeamId: needsHomeIdFix ? fallbackHomeId : null,
            awayTeamId: needsAwayIdFix ? fallbackAwayId : null,
          );
        }

        return fixed;
      } else {
        throw Exception('Failed to create match: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Error creating match: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        throw Exception(e.response?.data['error'] ?? 'Failed to create match');
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
        final data = response.data?['data'];
        if (data == null) {
          throw Exception('Invalid response format: missing data field');
        }
        final parsed = _parseMatchFromJson(data);
        final fallbackHomeName = matchData['teamAName']?.toString();
        final fallbackAwayName = matchData['teamBName']?.toString();
        final fallbackHomeId = matchData['teamA']?.toString();
        final fallbackAwayId = matchData['teamB']?.toString();

        MatchModel fixed = parsed;
        final needsHomeNameFix =
            (parsed.homeTeam.isEmpty || parsed.homeTeam == 'Unknown Team') &&
            (fallbackHomeName != null && fallbackHomeName.isNotEmpty);
        final needsAwayNameFix =
            (parsed.awayTeam.isEmpty || parsed.awayTeam == 'Unknown Team') &&
            (fallbackAwayName != null && fallbackAwayName.isNotEmpty);
        final needsHomeIdFix =
            (parsed.homeTeamId == null || parsed.homeTeamId!.isEmpty) &&
            (fallbackHomeId != null && fallbackHomeId.isNotEmpty);
        final needsAwayIdFix =
            (parsed.awayTeamId == null || parsed.awayTeamId!.isEmpty) &&
            (fallbackAwayId != null && fallbackAwayId.isNotEmpty);

        if (needsHomeNameFix ||
            needsAwayNameFix ||
            needsHomeIdFix ||
            needsAwayIdFix) {
          fixed = parsed.copyWith(
            homeTeam: needsHomeNameFix ? fallbackHomeName : null,
            awayTeam: needsAwayNameFix ? fallbackAwayName : null,
            homeTeamId: needsHomeIdFix ? fallbackHomeId : null,
            awayTeamId: needsAwayIdFix ? fallbackAwayId : null,
          );
        }

        return fixed;
      } else {
        throw Exception('Failed to update match: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Error updating match: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        throw Exception(e.response?.data['error'] ?? 'Failed to update match');
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
      final response = await dio.get('/match');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          final matchesList = data['data'] as List;

          // First parse to models
          final parsed = matchesList
              .map((json) {
                try {
                  return _parseMatchFromJson(json);
                } catch (parseError) {
                  return null;
                }
              })
              .whereType<MatchModel>()
              .toList();

          // Identify unique league IDs that need resolution
          final leagueIds = parsed
              .map((m) => m.leagueId)
              .where((lid) => lid != null && lid.isNotEmpty)
              .toSet()
              .cast<String>();

          // Build a cache of league teams to resolve team names in parallel
          final Map<String, Map<String, String>> leagueTeamNameCache = {};
          if (leagueIds.isNotEmpty) {
            final leagueFutures = leagueIds.map(
              (lid) => LeagueService.getLeagueById(lid),
            );
            final leagues = await Future.wait(leagueFutures);

            for (int i = 0; i < leagueIds.length; i++) {
              final lid = leagueIds.elementAt(i);
              final league = leagues[i];
              final Map<String, String> teamMap = {};
              if (league != null) {
                for (final t in league.teams) {
                  if (t.id.isNotEmpty) {
                    teamMap[t.id] = t.teamName;
                  }
                }
              }
              leagueTeamNameCache[lid] = teamMap;
            }
          }

          // Fill names from cache if missing
          List<MatchModel> fixed = parsed.map((m) {
            final lid = m.leagueId;
            if (lid != null && leagueTeamNameCache.containsKey(lid)) {
              return _fillTeamNamesFromLeague(m, leagueTeamNameCache[lid]!);
            }
            return m;
          }).toList();

          // Build a set of team IDs that need resolution
          final Set<String> teamIdsToResolve = {};
          for (final m in fixed) {
            bool needHome =
                (m.homeTeam.isEmpty || m.homeTeam == 'Unknown Team') &&
                (m.homeTeamId != null && m.homeTeamId!.isNotEmpty);
            bool needAway =
                (m.awayTeam.isEmpty || m.awayTeam == 'Unknown Team') &&
                (m.awayTeamId != null && m.awayTeamId!.isNotEmpty);

            if (needHome) teamIdsToResolve.add(m.homeTeamId!);
            if (needAway) teamIdsToResolve.add(m.awayTeamId!);
          }

          // Fetch team names in parallel
          final Map<String, String> teamNameCache = {};
          if (teamIdsToResolve.isNotEmpty) {
            final teamFutures = teamIdsToResolve.map(
              (tid) => TeamService.getTeamById(tid),
            );
            final teams = await Future.wait(teamFutures);

            for (int i = 0; i < teamIdsToResolve.length; i++) {
              final tid = teamIdsToResolve.elementAt(i);
              final teamData = teams[i];
              final String? name =
                  (teamData?['teamName']?.toString() ??
                  teamData?['enterCode']?.toString());
              if (name != null) {
                teamNameCache[tid] = name;
              }
            }
          }

          // Apply team names from cache
          for (int i = 0; i < fixed.length; i++) {
            final m = fixed[i];
            String resolvedHome = m.homeTeam;
            String resolvedAway = m.awayTeam;

            if ((resolvedHome.isEmpty || resolvedHome == 'Unknown Team') &&
                m.homeTeamId != null &&
                teamNameCache.containsKey(m.homeTeamId)) {
              resolvedHome = teamNameCache[m.homeTeamId]!;
            }
            if ((resolvedAway.isEmpty || resolvedAway == 'Unknown Team') &&
                m.awayTeamId != null &&
                teamNameCache.containsKey(m.awayTeamId)) {
              resolvedAway = teamNameCache[m.awayTeamId]!;
            }

            if (resolvedHome != m.homeTeam || resolvedAway != m.awayTeam) {
              fixed[i] = m.copyWith(
                homeTeam: resolvedHome,
                awayTeam: resolvedAway,
              );
            }
          }

          return fixed;
        }

        return [];
      } else {
        return [];
      }
    } on DioException {
      rethrow; // Re-throw to let provider handle it
    } catch (_) {
      rethrow; // Re-throw to let provider handle it
    }
  }

  /// Get all matches for a league
  /// GET /api/match?leagueId=:id
  static Future<List<MatchModel>> getMatchesByLeague(String leagueId) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get(
        '/match',
        queryParameters: {'leagueId': leagueId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          // Build a map of league teams for reliable name lookup
          final league = await LeagueService.getLeagueById(leagueId);
          final Map<String, String> teamNameById = {};
          if (league != null) {
            for (final t in league.teams) {
              if (t.id.isNotEmpty) {
                teamNameById[t.id] = t.teamName;
              }
            }
          }

          final matches = (data['data'] as List)
              .map((json) => _parseMatchFromJson(json))
              .map((m) => _fillTeamNamesFromLeague(m, teamNameById))
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
        final parsed = _parseMatchFromJson(data);
        // Try to resolve names from league teams if missing
        if (parsed.leagueId != null && parsed.leagueId!.isNotEmpty) {
          try {
            final league = await LeagueService.getLeagueById(parsed.leagueId!);
            final Map<String, String> teamNameById = {};
            if (league != null) {
              for (final t in league.teams) {
                if (t.id.isNotEmpty) {
                  teamNameById[t.id] = t.teamName;
                }
              }
            }
            return _fillTeamNamesFromLeague(parsed, teamNameById);
          } catch (_) {
            return parsed;
          }
        }
        return parsed;
      } else {
        throw Exception('Failed to get match: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Error fetching match: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        throw Exception(e.response?.data['error'] ?? 'Failed to get match');
      }
      rethrow;
    } catch (e) {
      print('General error fetching match: $e');
      rethrow;
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
      return teamData['_id']?.toString() ?? teamData['id']?.toString() ?? null;
    }
    return null;
  }

  /// Helper to lookup team name from dummy teams by ID
  static String _lookupTeamName(String? teamId) {
    if (teamId == null || teamId.isEmpty) {
      return 'Unknown Team';
    }

    // Normalize team ID (convert to string and trim)
    final normalizedId = teamId.toString().trim();

    try {
      final team = _getDummyTeams().firstWhere(
        (t) => t.id.toString().trim() == normalizedId,
        orElse: () {
          return TeamModel(
            id: normalizedId,
            teamName: 'Unknown Team',
            enterCode: null,
            location: null,
            skillLevel: null,
          );
        },
      );
      return team.teamName;
    } catch (e) {
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

    // Parse league data
    final leagueData = json['leagueId'];
    final leagueName = leagueData is Map
        ? (leagueData['leagueName'] ?? '')
        : json['leagueName'] ?? '';

    // Extract league ID for filtering
    final leagueId = leagueData is Map
        ? (leagueData['_id']?.toString() ?? leagueData['id']?.toString())
        : (json['leagueId']?.toString());

    // Parse team A data
    // Prioritize root fields from backend DTO (homeTeam, homeTeamLogo, homeTeamId)
    String teamAName =
        json['homeTeam']?.toString() ?? json['teamAName']?.toString() ?? '';
    String teamALogo = json['homeTeamLogo']?.toString() ?? '';
    String? homeTeamId = json['homeTeamId']?.toString();

    final teamAData = json['teamA'];
    if (teamAData is Map) {
      if (homeTeamId == null || homeTeamId.isEmpty) {
        homeTeamId = _extractTeamId(teamAData);
      }

      // Look for logo in populated teamId object
      if (teamALogo.isEmpty) {
        final teamIdObj = teamAData['teamId'];
        if (teamIdObj is Map && teamIdObj['image'] != null) {
          teamALogo = teamIdObj['image'].toString();
        } else if (teamAData['image'] != null) {
          teamALogo = teamAData['image'].toString();
        }
      }

      if (teamAName.isEmpty || teamAName == 'Unknown Team') {
        final teamIdObj = teamAData['teamId'];
        if (teamIdObj is Map) {
          teamAName =
              teamIdObj['teamName']?.toString() ??
              teamIdObj['enterCode']?.toString() ??
              '';
        } else {
          teamAName =
              teamAData['teamName']?.toString() ??
              teamAData['enterCode']?.toString() ??
              _lookupTeamName(homeTeamId);
        }
      }
    } else if (teamAData is String) {
      if (homeTeamId == null || homeTeamId.isEmpty) homeTeamId = teamAData;
      if (teamAName.isEmpty || teamAName == 'Unknown Team')
        teamAName = _lookupTeamName(homeTeamId);
    }

    // Parse team B data
    // Prioritize root fields from backend DTO (awayTeam, awayTeamLogo, awayTeamId)
    String teamBName =
        json['awayTeam']?.toString() ?? json['teamBName']?.toString() ?? '';
    String teamBLogo = json['awayTeamLogo']?.toString() ?? '';
    String? awayTeamId = json['awayTeamId']?.toString();

    final teamBData = json['teamB'];
    if (teamBData is Map) {
      if (awayTeamId == null || awayTeamId.isEmpty) {
        awayTeamId = _extractTeamId(teamBData);
      }

      // Look for logo in populated teamId object
      if (teamBLogo.isEmpty) {
        final teamIdObj = teamBData['teamId'];
        if (teamIdObj is Map && teamIdObj['image'] != null) {
          teamBLogo = teamIdObj['image'].toString();
        } else if (teamBData['image'] != null) {
          teamBLogo = teamBData['image'].toString();
        }
      }

      if (teamBName.isEmpty || teamBName == 'Unknown Team') {
        final teamIdObj = teamBData['teamId'];
        if (teamIdObj is Map) {
          teamBName =
              teamIdObj['teamName']?.toString() ??
              teamIdObj['enterCode']?.toString() ??
              '';
        } else {
          teamBName =
              teamBData['teamName']?.toString() ??
              teamBData['enterCode']?.toString() ??
              _lookupTeamName(awayTeamId);
        }
      }
    } else if (teamBData is String) {
      if (awayTeamId == null || awayTeamId.isEmpty) awayTeamId = teamBData;
      if (teamBName.isEmpty || teamBName == 'Unknown Team')
        teamBName = _lookupTeamName(awayTeamId);
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
        // Fallback: use current date + 1 day to ensure it's in the future
        gameDate = DateTime.now().add(const Duration(days: 1));
      }
    } else {
      // Fallback: use current date + 1 day to ensure it's in the future
      gameDate = DateTime.now().add(const Duration(days: 1));
    }

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
        matchDateTime = gameDate;
      }
    } else {
      matchDateTime = gameDate;
    }

    // Format date as dd/MM
    final dateStr =
        '${gameDate.day.toString().padLeft(2, '0')}/${gameDate.month.toString().padLeft(2, '0')}';

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
      case 'continue':
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
    final statKeeperData = json['statKeeperId'];

    // Try to get raw IDs first (from backend fix), fallback to populated data extraction
    final refereeId =
        json['refereeIdRaw']?.toString() ??
        (refereeData is Map
            ? (refereeData['_id']?.toString() ?? refereeData['id']?.toString())
            : (json['refereeId']?.toString()));

    final statKeeperId =
        json['statKeeperIdRaw']?.toString() ??
        (statKeeperData is Map
            ? (statKeeperData['_id']?.toString() ??
                  statKeeperData['id']?.toString())
            : (json['statKeeperId']?.toString()));

    // Parse actions
    List<Map<String, dynamic>> actionsList = [];
    final rawActions = json['actions'] ?? json['timeline'] ?? [];
    if (rawActions is List) {
      for (var item in rawActions) {
        if (item is Map) {
          actionsList.add(Map<String, dynamic>.from(item));
        }
      }
    }

    final tossWinnerId = json['tossWinner']?.toString();
    final tossChoice = json['tossChoice']?.toString();

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
      format: json['format']?.toString(),
      homeTeamStats: _parseTeamStats(json['teamA'], teamAName),
      awayTeamStats: _parseTeamStats(json['teamB'], teamBName),
      actions: actionsList,
      tossWinnerId: tossWinnerId,
      tossChoice: tossChoice,
    );
  }

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

        String name = '';
        final firstName = p['firstName']?.toString() ?? '';
        final lastName = p['lastName']?.toString() ?? '';
        final playerName = p['playerName']?.toString() ?? '';
        final fullName = p['name']?.toString() ?? '';

        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          name = '$firstName $lastName'.trim();
        } else if (playerName.isNotEmpty) {
          name = playerName;
        } else if (fullName.isNotEmpty) {
          name = fullName;
        }
        // If still empty, leave it as empty string - no fallback text

        playerStatsList.add(
          PlayerStatModel(
            playerId: id,
            playerName: name,
            image: p['image'] ?? p['avatar'] ?? p['profileImage'] ?? '',
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
    if (teamData['teamName'] != null) teamName = teamData['teamName'];

    return TeamStatModel(
      teamName: teamName,
      teamLogo: teamData['image'] ?? '',
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

  /// Fallback fill: if names are missing/Unknown, use league team map
  static MatchModel _fillTeamNamesFromLeague(
    MatchModel match,
    Map<String, String> teamNameById,
  ) {
    String resolvedHome = match.homeTeam;
    String resolvedAway = match.awayTeam;

    if ((resolvedHome.isEmpty || resolvedHome == 'Unknown Team') &&
        match.homeTeamId != null &&
        teamNameById.containsKey(match.homeTeamId)) {
      resolvedHome = teamNameById[match.homeTeamId] ?? resolvedHome;
    }
    if ((resolvedAway.isEmpty || resolvedAway == 'Unknown Team') &&
        match.awayTeamId != null &&
        teamNameById.containsKey(match.awayTeamId)) {
      resolvedAway = teamNameById[match.awayTeamId] ?? resolvedAway;
    }

    if (resolvedHome == match.homeTeam && resolvedAway == match.awayTeam) {
      return match;
    }

    return match.copyWith(homeTeam: resolvedHome, awayTeam: resolvedAway);
  }

  /// Switch to half time
  /// POST /api/match/:id/halftime
  static Future<MatchModel> switchHalfTime(String matchId) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.post('/match/$matchId/halftime');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return _parseMatchFromJson(data);
      } else {
        throw Exception(
          'Failed to switch half time: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      print('Error switching half time: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        throw Exception(
          e.response?.data['error'] ?? 'Failed to switch half time',
        );
      }
      rethrow;
    } catch (e) {
      print('General error switching half time: $e');
      rethrow;
    }
  }

  /// Switch to full time
  /// POST /api/match/:id/fulltime
  static Future<MatchModel> switchFullTime(String matchId) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.post('/match/$matchId/fulltime');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return _parseMatchFromJson(data);
      } else {
        throw Exception(
          'Failed to switch full time: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      print('Error switching full time: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        throw Exception(
          e.response?.data['error'] ?? 'Failed to switch full time',
        );
      }
      rethrow;
    } catch (e) {
      print('General error switching full time: $e');
      rethrow;
    }
  }

  /// Switch to overtime
  /// POST /api/match/:id/overtime
  static Future<MatchModel> switchOvertime(String matchId) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.post('/match/$matchId/overtime');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return _parseMatchFromJson(data);
      } else {
        throw Exception('Failed to switch overtime: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Error switching overtime: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        throw Exception(
          e.response?.data['error'] ?? 'Failed to switch overtime',
        );
      }
      rethrow;
    } catch (e) {
      print('General error switching overtime: $e');
      rethrow;
    }
  }

  /// Complete toss - set team sides and update status to continue
  /// POST /api/match/:id/toss
  /// Sets the winner team's side and opposite side for the other team
  /// Updates status from "upcoming" to "continue"
  static Future<MatchModel> completeToss({
    required String matchId,
    required String winnerTeamId,
    required String winnerSide, // 'offense' or 'defense'
  }) async {
    try {
      final dio = await _getAuthenticatedDio();

      // Prepare request body for toss endpoint
      final requestData = {
        'winnerTeamId': winnerTeamId,
        'winnerSide': winnerSide,
      };

      final response = await dio.post(
        '/match/$matchId/toss',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return _parseMatchFromJson(data);
      } else {
        throw Exception('Failed to complete toss: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('Error completing toss: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        throw Exception(e.response?.data['error'] ?? 'Failed to complete toss');
      }
      rethrow;
    } catch (e) {
      print('General error completing toss: $e');
      rethrow;
    }
  }

  /// Add game action (Touchdown, Extra Point, etc.)
  /// POST /api/match/:id/action
  /// Body: { teamId: string, playerId: string, actionType: string, quarter?: string }
  static Future<MatchModel> addGameAction({
    required String matchId,
    required String teamId,
    required String playerId,
    required String actionType,
    String? quarter,
  }) async {
    try {
      final dio = await _getAuthenticatedDio();

      final requestData = {
        'teamId': teamId,
        'playerId': playerId,
        'actionType': actionType,
        if (quarter != null) 'quarter': quarter,
      };

      print('📤 Adding game action: $requestData');

      final response = await dio.post(
        '/match/$matchId/action',
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        print('✅ Game action added successfully');
        return _parseMatchFromJson(data);
      } else {
        throw Exception('Failed to add game action: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('❌ Error adding game action: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        throw Exception(
          e.response?.data['error'] ?? 'Failed to add game action',
        );
      }
      rethrow;
    } catch (e) {
      print('❌ General error adding game action: $e');
      rethrow;
    }
  }
}

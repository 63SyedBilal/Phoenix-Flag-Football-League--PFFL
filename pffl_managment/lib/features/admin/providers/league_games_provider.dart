import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/core/services/league_service.dart' show TeamModel, LeagueService;

/// Provider for managing league games state, standings, and semi-final/final logic
class LeagueGamesProvider extends ChangeNotifier {
  final String leagueId;
  
  List<MatchModel> _allGames = [];
  List<TeamModel> _leagueTeams = [];
  bool _isLoading = false;
  String? _errorMessage;

  LeagueGamesProvider(this.leagueId);

  // Getters
  List<MatchModel> get allGames => List.unmodifiable(_allGames);
  List<TeamModel> get leagueTeams => List.unmodifiable(_leagueTeams);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Team standings calculated from completed games
  List<TeamStanding> get teamStandings {
    final Map<String, TeamStanding> standingsMap = {};

    // Initialize all teams and collect team logos from match data
    final Map<String, String> teamLogos = {};
    for (final game in _allGames) {
      if (game.homeTeamId != null && game.homeTeamLogo.isNotEmpty) {
        teamLogos[game.homeTeamId!] = game.homeTeamLogo;
      }
      if (game.awayTeamId != null && game.awayTeamLogo.isNotEmpty) {
        teamLogos[game.awayTeamId!] = game.awayTeamLogo;
      }
    }

    for (final team in _leagueTeams) {
      standingsMap[team.id] = TeamStanding(
        teamId: team.id,
        teamName: team.teamName,
        teamLogo: teamLogos[team.id] ?? '', // Get logo from match data if available
        wins: 0,
        draws: 0,
        losses: 0,
      );
    }

    // Calculate from completed games
    for (final game in _allGames) {
      if (game.status == MatchStatus.completed &&
          game.homeScore != null &&
          game.awayScore != null &&
          game.homeTeamId != null &&
          game.awayTeamId != null) {
        
        final homeTeamId = game.homeTeamId!;
        final awayTeamId = game.awayTeamId!;
        final homeScore = game.homeScore!;
        final awayScore = game.awayScore!;

        // Update home team
        if (standingsMap.containsKey(homeTeamId)) {
          // Update logo if available from this game
          if (game.homeTeamLogo.isNotEmpty) {
            standingsMap[homeTeamId]!.teamLogo = game.homeTeamLogo;
          }
          
          if (homeScore > awayScore) {
            standingsMap[homeTeamId]!.wins++;
          } else if (homeScore == awayScore) {
            standingsMap[homeTeamId]!.draws++;
          } else {
            standingsMap[homeTeamId]!.losses++;
          }
        }

        // Update away team
        if (standingsMap.containsKey(awayTeamId)) {
          // Update logo if available from this game
          if (game.awayTeamLogo.isNotEmpty) {
            standingsMap[awayTeamId]!.teamLogo = game.awayTeamLogo;
          }
          
          if (awayScore > homeScore) {
            standingsMap[awayTeamId]!.wins++;
          } else if (awayScore == homeScore) {
            standingsMap[awayTeamId]!.draws++;
          } else {
            standingsMap[awayTeamId]!.losses++;
          }
        }
      }
    }

    // Convert to list and sort by points (descending)
    final standings = standingsMap.values.toList();
    standings.sort((a, b) {
      final pointsA = a.points;
      final pointsB = b.points;
      if (pointsA != pointsB) {
        return pointsB.compareTo(pointsA);
      }
      // If points are equal, sort by wins
      return b.wins.compareTo(a.wins);
    });

    return standings;
  }

  /// Get top 4 teams for semi-finals
  List<TeamStanding> get semiFinalTeams {
    final standings = teamStandings;
    return standings.take(4).toList();
  }

  /// Get semi-final 1 teams (rank 1 vs rank 4)
  SemiFinalMatch? get semiFinal1 {
    final teams = semiFinalTeams;
    if (teams.length < 4) return null;
    
    // Find existing semi-final 1 game
    MatchModel? existingGame;
    try {
      existingGame = _allGames.firstWhere(
        (game) => (game.roundName?.toLowerCase() == 'semi-final 1' ||
                   game.roundName?.toLowerCase() == 'semi - final 1' ||
                   game.roundName?.toLowerCase() == 'semi-final') &&
                   game.id != null,
      );
    } catch (e) {
      existingGame = null;
    }

    return SemiFinalMatch(
      team1: teams[0], // Rank 1
      team2: teams[3], // Rank 4
      game: existingGame,
    );
  }

  /// Get semi-final 2 teams (rank 2 vs rank 3)
  SemiFinalMatch? get semiFinal2 {
    final teams = semiFinalTeams;
    if (teams.length < 4) return null;
    
    // Find existing semi-final 2 game
    MatchModel? existingGame;
    try {
      existingGame = _allGames.firstWhere(
        (game) => (game.roundName?.toLowerCase() == 'semi-final 2' ||
                   game.roundName?.toLowerCase() == 'semi - final 2') &&
                   game.id != null,
      );
    } catch (e) {
      existingGame = null;
    }

    return SemiFinalMatch(
      team1: teams[1], // Rank 2
      team2: teams[2], // Rank 3
      game: existingGame,
    );
  }

  /// Get final teams (winners from semi-finals)
  FinalMatch? get finalMatch {
    // Find semi-final 1 and 2 completed games
    MatchModel? semi1Game;
    MatchModel? semi2Game;
    
    try {
      semi1Game = _allGames.firstWhere(
        (game) => (game.roundName?.toLowerCase() == 'semi-final 1' ||
                   game.roundName?.toLowerCase() == 'semi - final 1') &&
                   game.status == MatchStatus.completed &&
                   game.homeScore != null &&
                   game.awayScore != null &&
                   game.id != null,
      );
    } catch (e) {
      semi1Game = null;
    }

    try {
      semi2Game = _allGames.firstWhere(
        (game) => (game.roundName?.toLowerCase() == 'semi-final 2' ||
                   game.roundName?.toLowerCase() == 'semi - final 2') &&
                   game.status == MatchStatus.completed &&
                   game.homeScore != null &&
                   game.awayScore != null &&
                   game.id != null,
      );
    } catch (e) {
      semi2Game = null;
    }

    // Both semi-finals must be completed to determine final teams
    if (semi1Game == null || semi2Game == null) {
      // Find existing final game (may have TBD teams)
      MatchModel? existingFinal;
      try {
        existingFinal = _allGames.firstWhere(
          (game) => game.roundName?.toLowerCase() == 'final' && game.id != null,
        );
      } catch (e) {
        existingFinal = null;
      }

      if (existingFinal != null) {
        return FinalMatch(
          team1: null, // TBD
          team2: null, // TBD
          game: existingFinal,
        );
      }
      return null;
    }

    // Determine winners (both games are guaranteed non-null at this point)
    final semi1GameNonNull = semi1Game;
    final semi2GameNonNull = semi2Game;
    
    final semi1Winner = (semi1GameNonNull.homeScore ?? 0) > (semi1GameNonNull.awayScore ?? 0)
        ? semi1GameNonNull.homeTeamId
        : semi1GameNonNull.awayTeamId;
    final semi2Winner = (semi2GameNonNull.homeScore ?? 0) > (semi2GameNonNull.awayScore ?? 0)
        ? semi2GameNonNull.homeTeamId
        : semi2GameNonNull.awayTeamId;

    // Find team details
    final teams = semiFinalTeams;
    final isSemi1HomeWinner = (semi1GameNonNull.homeScore ?? 0) > (semi1GameNonNull.awayScore ?? 0);
    final isSemi2HomeWinner = (semi2GameNonNull.homeScore ?? 0) > (semi2GameNonNull.awayScore ?? 0);
    
    final team1 = teams.firstWhere(
      (t) => t.teamId == semi1Winner,
      orElse: () => TeamStanding(
        teamId: semi1Winner ?? '',
        teamName: isSemi1HomeWinner
            ? semi1GameNonNull.homeTeam
            : semi1GameNonNull.awayTeam,
        teamLogo: isSemi1HomeWinner
            ? semi1GameNonNull.homeTeamLogo
            : semi1GameNonNull.awayTeamLogo,
        wins: 0,
        draws: 0,
        losses: 0,
      ),
    );

    final team2 = teams.firstWhere(
      (t) => t.teamId == semi2Winner,
      orElse: () => TeamStanding(
        teamId: semi2Winner ?? '',
        teamName: isSemi2HomeWinner
            ? semi2GameNonNull.homeTeam
            : semi2GameNonNull.awayTeam,
        teamLogo: isSemi2HomeWinner
            ? semi2GameNonNull.homeTeamLogo
            : semi2GameNonNull.awayTeamLogo,
        wins: 0,
        draws: 0,
        losses: 0,
      ),
    );

    // Find existing final game
    MatchModel? existingFinal;
    try {
      existingFinal = _allGames.firstWhere(
        (game) => game.roundName?.toLowerCase() == 'final' && game.id != null,
      );
    } catch (e) {
      existingFinal = null;
    }

    return FinalMatch(
      team1: team1,
      team2: team2,
      game: existingFinal,
    );
  }

  /// Initialize provider by fetching games and teams
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        _fetchGames(),
        _fetchTeams(),
      ]);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
      debugPrint('Error initializing LeagueGamesProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh games and teams
  Future<void> refresh() async {
    await initialize();
  }

  Future<void> _fetchGames() async {
    try {
      _allGames = await MatchService.getMatchesByLeague(leagueId);
    } catch (e) {
      debugPrint('Error fetching games: $e');
      rethrow;
    }
  }

  Future<void> _fetchTeams() async {
    try {
      final league = await LeagueService.getLeagueById(leagueId);
      if (league != null) {
        _leagueTeams = league.teams;
      }
    } catch (e) {
      debugPrint('Error fetching teams: $e');
      rethrow;
    }
  }
}

/// Model for team standings
class TeamStanding {
  final String teamId;
  final String teamName;
  String teamLogo; // Non-final to allow updates from match data
  int wins;
  int draws;
  int losses;

  TeamStanding({
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
    required this.wins,
    required this.draws,
    required this.losses,
  });

  int get points => (wins * 3) + draws;
}

/// Model for semi-final match
class SemiFinalMatch {
  final TeamStanding team1;
  final TeamStanding team2;
  final MatchModel? game;

  SemiFinalMatch({
    required this.team1,
    required this.team2,
    this.game,
  });
}

/// Model for final match
class FinalMatch {
  final TeamStanding? team1; // null means TBD
  final TeamStanding? team2; // null means TBD
  final MatchModel? game;

  FinalMatch({
    this.team1,
    this.team2,
    this.game,
  });
}

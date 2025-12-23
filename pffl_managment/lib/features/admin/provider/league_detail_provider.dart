import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_detail_models.dart';

class LeagueDetailProvider extends ChangeNotifier {
  int _selectedTabIndex = 0;
  LeagueGameModel? _editingGame;
  bool _isEditing = false;

  String? _leagueId;
  List<MatchModel> _allMatches = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Team expansion state
  final Map<String, bool> _teamExpansionState = {};

  int get selectedTabIndex => _selectedTabIndex;
  LeagueGameModel? get editingGame => _editingGame;
  bool get isEditing => _isEditing;
  String? get leagueId => _leagueId;
  List<MatchModel> get allMatches => _allMatches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize(String leagueId) async {
    _leagueId = leagueId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allMatches = await MatchService.getMatchesByLeague(leagueId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_leagueId != null) {
      await initialize(_leagueId!);
    }
  }

  void selectTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void startEditingGame(LeagueGameModel game) {
    _editingGame = game;
    _isEditing = true;
    notifyListeners();
  }

  void stopEditingGame() {
    _editingGame = null;
    _isEditing = false;
    notifyListeners();
  }

  void updateEditingGame(LeagueGameModel updatedGame) {
    _editingGame = updatedGame;
    notifyListeners();
  }

  bool isTeamExpanded(String teamId) {
    return _teamExpansionState[teamId] ?? false;
  }

  void toggleTeamExpansion(String teamId) {
    _teamExpansionState[teamId] = !(_teamExpansionState[teamId] ?? false);
    notifyListeners();
  }

  // Data for upcoming games section - shows next 3 matches by date
  List<MatchModel> getUpcomingGames() {
    if (_allMatches.isEmpty) return [];

    final now = DateTime.now();

    // Filter matches that have a future date
    final upcomingMatches = _allMatches
        .where((m) => m.matchDateTime != null && m.matchDateTime!.isAfter(now))
        .toList();

    // Sort by date (ascending - nearest first)
    upcomingMatches.sort((a, b) {
      if (a.matchDateTime == null) return 1;
      if (b.matchDateTime == null) return -1;
      return a.matchDateTime!.compareTo(b.matchDateTime!);
    });

    // Return exactly 3 matches (or fewer if not available)
    return upcomingMatches.take(3).toList();
  }

  // Data for leaderboard
  List<LeagueTeamStandingModel> getLeaderboard() {
    final Map<String, _TeamStatsBuilder> statsMap = _aggregateTeamStats();
    final standingList = statsMap.values.toList();
    _sortStandings(standingList);
    return _mapStandingsToModels(standingList);
  }

  Map<String, _TeamStatsBuilder> _aggregateTeamStats() {
    final Map<String, _TeamStatsBuilder> statsMap = {};
    for (final m in _allMatches) {
      if (m.status != MatchStatus.completed) continue;
      if (m.homeTeamId == null || m.awayTeamId == null) continue;
      _updateStats(statsMap, m);
    }
    return statsMap;
  }

  void _updateStats(Map<String, _TeamStatsBuilder> statsMap, MatchModel m) {
    statsMap.putIfAbsent(
      m.homeTeamId!,
      () => _TeamStatsBuilder(name: m.homeTeam, logo: m.homeTeamLogo),
    );
    statsMap.putIfAbsent(
      m.awayTeamId!,
      () => _TeamStatsBuilder(name: m.awayTeam, logo: m.awayTeamLogo),
    );

    final home = statsMap[m.homeTeamId!]!;
    final away = statsMap[m.awayTeamId!]!;

    final homeScore = m.homeScore ?? 0;
    final awayScore = m.awayScore ?? 0;

    home.matchesPlayed++;
    away.matchesPlayed++;
    home.pointsScored += homeScore;
    home.pointsAgainst += awayScore;
    away.pointsScored += awayScore;
    away.pointsAgainst += homeScore;

    if (homeScore > awayScore) {
      home.wins++;
      away.losses++;
    } else if (homeScore < awayScore) {
      away.wins++;
      home.losses++;
    } else {
      home.draws++;
      away.draws++;
    }
  }

  void _sortStandings(List<_TeamStatsBuilder> list) {
    list.sort((a, b) {
      final pA = (a.wins * 3) + a.draws;
      final pB = (b.wins * 3) + b.draws;
      if (pA != pB) return pB.compareTo(pA);
      final pdA = a.pointsScored - a.pointsAgainst;
      final pdB = b.pointsScored - b.pointsAgainst;
      return pdB.compareTo(pdA);
    });
  }

  List<LeagueTeamStandingModel> _mapStandingsToModels(
    List<_TeamStatsBuilder> list,
  ) {
    return list.asMap().entries.map((entry) {
      final i = entry.key;
      final s = entry.value;
      return LeagueTeamStandingModel(
        rank: i + 1,
        teamName: s.name,
        teamLogo: s.logo,
        matchesPlayed: s.matchesPlayed,
        wins: s.wins,
        draws: s.draws,
        losses: s.losses,
        pointsScored: s.pointsScored,
        pointsAgainst: s.pointsAgainst,
      );
    }).toList();
  }

  // Data for key players
  List<LeagueKeyPlayerModel> getKeyPlayers() {
    final Map<String, _PlayerStatsBuilder> playerMap = _aggregatePlayerStats();
    final sortedPlayers = playerMap.entries.toList()
      ..sort((a, b) => b.value.touchdowns.compareTo(a.value.touchdowns));
    return _mapPlayersToModels(sortedPlayers);
  }

  Map<String, _PlayerStatsBuilder> _aggregatePlayerStats() {
    final Map<String, _PlayerStatsBuilder> playerMap = {};
    for (final m in _allMatches) {
      if (m.homeTeamStats != null) {
        _updatePlayerStats(playerMap, m.homeTeamStats!.playerStats);
      }
      if (m.awayTeamStats != null) {
        _updatePlayerStats(playerMap, m.awayTeamStats!.playerStats);
      }
    }
    return playerMap;
  }

  void _updatePlayerStats(
    Map<String, _PlayerStatsBuilder> map,
    List<dynamic> playerStats,
  ) {
    for (final p in playerStats) {
      map.putIfAbsent(
        p.playerId,
        () => _PlayerStatsBuilder(name: p.playerName, image: p.image),
      );
      map[p.playerId]!.touchdowns += (p.tds as num).toInt();
    }
  }

  List<LeagueKeyPlayerModel> _mapPlayersToModels(
    List<MapEntry<String, _PlayerStatsBuilder>> sortedPlayers,
  ) {
    final List<ColorPair> colors = [
      ColorPair(const Color(0xFF1E3A8A), const Color(0xFF3B82F6)),
      ColorPair(const Color(0xFF1E293B), const Color(0xFF334155)),
      ColorPair(const Color(0xFF7E22CE), const Color(0xFFA855F7)),
      ColorPair(const Color(0xFF0D9488), const Color(0xFF14B8A6)),
    ];

    return sortedPlayers.take(4).toList().asMap().entries.map((entry) {
      final i = entry.key;
      final pair = entry.value;
      final color = colors[i % colors.length];
      return LeagueKeyPlayerModel(
        id: pair.key,
        name: pair.value.name,
        avatarUrl: pair.value.image,
        statValue: pair.value.touchdowns,
        statLabel: 'TDs',
        gradientStart: color.start,
        gradientEnd: color.end,
      );
    }).toList();
  }

  // Data for team stats (Points Scored)
  List<LeagueTeamStatModel> getTeamStats() {
    final Map<String, _TeamStatsBuilder> statsMap = _aggregatePointsScored();
    final sortedTeams = statsMap.values.toList()
      ..sort((a, b) => b.pointsScored.compareTo(a.pointsScored));
    return _mapTeamStatsToModels(sortedTeams);
  }

  Map<String, _TeamStatsBuilder> _aggregatePointsScored() {
    final Map<String, _TeamStatsBuilder> statsMap = {};
    for (final m in _allMatches) {
      if (m.status != MatchStatus.completed) continue;
      if (m.homeTeamId == null || m.awayTeamId == null) continue;

      statsMap.putIfAbsent(
        m.homeTeamId!,
        () => _TeamStatsBuilder(name: m.homeTeam, logo: m.homeTeamLogo),
      );
      statsMap.putIfAbsent(
        m.awayTeamId!,
        () => _TeamStatsBuilder(name: m.awayTeam, logo: m.awayTeamLogo),
      );

      statsMap[m.homeTeamId!]!.pointsScored += m.homeScore ?? 0;
      statsMap[m.awayTeamId!]!.pointsScored += m.awayScore ?? 0;
    }
    return statsMap;
  }

  List<LeagueTeamStatModel> _mapTeamStatsToModels(
    List<_TeamStatsBuilder> sortedTeams,
  ) {
    final List<Color> bgColors = [
      const Color(0xFF4C1D95),
      const Color(0xFF7F1D1D),
      const Color(0xFF0D9488),
      const Color(0xFFCA8A04),
    ];

    return sortedTeams.take(4).toList().asMap().entries.map((entry) {
      final i = entry.key;
      final t = entry.value;
      final color = bgColors[i % bgColors.length];
      return LeagueTeamStatModel(
        teamName: t.name,
        teamLogo: t.logo,
        statValue: t.pointsScored.toString(),
        statLabel: 'PS',
        backgroundColor: color,
      );
    }).toList();
  }
}

class _TeamStatsBuilder {
  final String name;
  final String logo;
  int matchesPlayed = 0;
  int wins = 0;
  int draws = 0;
  int losses = 0;
  int pointsScored = 0;
  int pointsAgainst = 0;

  _TeamStatsBuilder({required this.name, required this.logo});
}

class _PlayerStatsBuilder {
  final String name;
  final String image;
  int touchdowns = 0;

  _PlayerStatsBuilder({required this.name, required this.image});
}

class ColorPair {
  final Color start;
  final Color end;
  ColorPair(this.start, this.end);
}

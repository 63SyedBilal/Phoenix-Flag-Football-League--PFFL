import 'package:flutter/material.dart';
import 'package:pffl_managment/features/stat_keeper/models/game_stat_model.dart';
import 'package:pffl_managment/features/stat_keeper/models/team_stat_model.dart';
import 'package:pffl_managment/features/stat_keeper/repositories/stat_keeper_repository.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatStatsProvider extends ChangeNotifier {
  // All stats storage
  final List<GameStatModel> _allStats = [];

  // Current tab index (0: All, 1: Draft, 2: Approved)
  int _currentTabIndex = 0;

  // Search query
  String _searchQuery = '';

  // Selected match
  String? _selectedMatchId;
  List<MatchModel> _assignedMatches = [];

  // Loading states
  bool _isLoading = false;
  bool _isSubmitting = false;

  // Getters
  int get currentTabIndex => _currentTabIndex;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get selectedMatchId => _selectedMatchId;
  List<MatchModel> get assignedMatches => _assignedMatches;

  // Filtered lists
  List<GameStatModel> get allStats {
    // Show consolidated match summaries in All Stats
    return _filterStats(
      _allStats
          .where(
            (stat) =>
                stat.status == StatStatus.approved ||
                stat.status == StatStatus.all,
          )
          .toList(),
    );
  }

  List<GameStatModel> get draftStats {
    // Show individual draft records in Draft Stats
    return _filterStats(
      _allStats.where((stat) => stat.status == StatStatus.draft).toList(),
    );
  }

  List<GameStatModel> get approvedStats {
    // Show only approved match summaries
    return _filterStats(
      _allStats.where((stat) => stat.status == StatStatus.approved).toList(),
    );
  }

  List<GameStatModel> get currentTabStats {
    switch (_currentTabIndex) {
      case 0:
        return allStats;
      case 1:
        return draftStats;
      case 2:
        return approvedStats;
      default:
        return allStats;
    }
  }

  StatStatsProvider();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  List<GameStatModel> _filterStats(List<GameStatModel> stats) {
    if (_searchQuery.isEmpty) return stats;

    return stats.where((stat) {
      final query = _searchQuery.toLowerCase();
      return stat.leagueName.toLowerCase().contains(query) ||
          stat.team1Name.toLowerCase().contains(query) ||
          stat.team2Name.toLowerCase().contains(query);
    }).toList();
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedMatchId(String? matchId) {
    _selectedMatchId = matchId;
    if (matchId != null) {
      loadStats(matchId);
    } else {
      _allStats.clear();
      notifyListeners();
    }
  }

  Future<void> fetchAssignedMatches() async {
    _setLoading(true);
    try {
      final matches = await StatKeeperRepository.getAssignedMatches();
      _assignedMatches = matches;
      if (_selectedMatchId == null && matches.isNotEmpty) {
        _selectedMatchId = matches.first.id;
        loadStats(_selectedMatchId!);
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching matches: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadStats(String matchId) async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('userId');

      // 1. Fetch consolidated match stats (from Match doc)
      final matchStat = await StatKeeperRepository.getMatchStats(matchId);

      // 2. Fetch individual draft records for current user (from Stat records)
      final draftStatsList = await StatKeeperRepository.getMatchStatsList(
        matchId: matchId,
        status: 'DRAFT',
        createdBy: currentUserId,
      );

      _allStats.clear();

      // Add official match stat
      if (matchStat != null) {
        _allStats.add(matchStat);
      }

      // Add individual draft records
      for (var item in draftStatsList) {
        _allStats.add(_parseStatItem(item));
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading stats: $e');
    } finally {
      _setLoading(false);
    }
  }

  GameStatModel _parseStatItem(dynamic item) {
    final stats = item['stats'] ?? {};
    final player = item['playerId'] ?? {};
    final team = item['teamId'] ?? {};
    final league = item['leagueId'] ?? {};

    final statusStr = item['status']?.toString().toUpperCase() ?? 'DRAFT';
    StatStatus status = StatStatus.draft;
    if (statusStr == 'APPROVED') status = StatStatus.approved;
    if (statusStr == 'PENDING_APPROVAL') status = StatStatus.all;

    return GameStatModel(
      id: item['_id'] ?? '',
      leagueName: league['leagueName'] ?? 'League',
      team1Name: team['teamName'] ?? 'Team',
      team1Logo: '',
      team2Name: '',
      team2Logo: '',
      date: DateTime.now(),
      time: '',
      status: status,
      team1Stats: TeamStatModel(
        teamName: team['teamName'] ?? 'Team',
        teamLogo: '',
        catches: stats['catches'] ?? 0,
        catchesYards: stats['catchYards'] ?? 0,
        rushes: stats['rushes'] ?? 0,
        rushesYards: stats['rushYards'] ?? 0,
        passAttempts: stats['passAttempts'] ?? 0,
        passYards: stats['passYards'] ?? 0,
        completions: stats['completions'] ?? 0,
        tds: stats['touchdowns'] ?? 0,
        flagPull: stats['flagPull'] ?? 0,
        sack: stats['sack'] ?? 0,
        interceptions: stats['interceptions'] ?? 0,
        safety: stats['safeties'] ?? 0,
        conversionPoints: stats['extraPoints'] ?? 0,
        playerStats: [
          PlayerStatModel(
            playerId: player['_id'] ?? '',
            playerName:
                '${player['firstName'] ?? ''} ${player['lastName'] ?? ''}'
                    .trim(),
            catches: stats['catches'] ?? 0,
            catchesYards: stats['catchYards'] ?? 0,
            rushes: stats['rushes'] ?? 0,
            rushesYards: stats['rushYards'] ?? 0,
            passAttempts: stats['passAttempts'] ?? 0,
            passYards: stats['passYards'] ?? 0,
            completions: stats['completions'] ?? 0,
            tds: stats['touchdowns'] ?? 0,
            flagPull: stats['flagPull'] ?? 0,
            sack: stats['sack'] ?? 0,
            interceptions: stats['interceptions'] ?? 0,
            safety: stats['safeties'] ?? 0,
            conversionPoints: stats['extraPoints'] ?? 0,
          ),
        ],
      ),
      team2Stats: TeamStatModel(teamName: '', teamLogo: ''),
    );
  }

  Future<void> submitForApproval() async {
    if (_selectedMatchId == null) return;

    _setSubmitting(true);
    try {
      await StatKeeperRepository.submitStatsForApproval(_selectedMatchId!);
      await loadStats(_selectedMatchId!);
    } catch (e) {
      print('Error submitting stats: $e');
    } finally {
      _setSubmitting(false);
    }
  }

  Future<void> refreshStats() async {
    if (_selectedMatchId != null) {
      await loadStats(_selectedMatchId!);
    }
  }

  // Legacy method fix for draft_stats_tab.dart
  Future<void> approveStat(String statId) async {
    // No-op or call submitForApproval if intended for single stat (though system is match-wide)
  }
}

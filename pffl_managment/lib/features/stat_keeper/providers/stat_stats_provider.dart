import 'package:flutter/material.dart';
import 'package:pffl_managment/features/stat_keeper/models/game_stat_model.dart';
import 'package:pffl_managment/features/stat_keeper/models/team_stat_model.dart';

class StatStatsProvider extends ChangeNotifier {
  // All stats storage
  final List<GameStatModel> _allStats = [];

  // Current tab index (0: All, 1: Draft, 2: Approved)
  int _currentTabIndex = 0;

  // Search query
  String _searchQuery = '';

  // Loading state
  bool _isLoading = false;

  // Getters
  int get currentTabIndex => _currentTabIndex;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  // Filtered lists
  List<GameStatModel> get allStats {
    return _filterStats(_allStats);
  }

  List<GameStatModel> get draftStats {
    return _filterStats(
      _allStats.where((stat) => stat.status == StatStatus.draft).toList(),
    );
  }

  List<GameStatModel> get approvedStats {
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

  StatStatsProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    _allStats.addAll([
      // Draft stats
      GameStatModel(
        id: '1',
        leagueName: 'The Rugby Championship',
        team1Name: 'RC',
        team1Logo: 'assets/images/image 12.png',
        team2Name: 'STA',
        team2Logo: 'assets/images/image 14.png',
        date: DateTime(2025, 8, 11),
        time: '01:05 AM PKT',
        status: StatStatus.draft,
        isAssignedToMe: false,
        isCompleted: false,
        team1Stats: TeamStatModel(
          teamName: 'RC',
          teamLogo: 'assets/images/image 12.png',
          catches: 14,
          catchesYards: 235,
          rushes: 8,
          rushesYards: 155,
          passAttempts: 25,
          passYards: 312,
          completions: 15,
          tds: 11,
          flagPull: 28,
          sack: 2,
          interceptions: 4,
          safety: 1,
          conversionPoints: 11,
        ),
        team2Stats: TeamStatModel(
          teamName: 'STA',
          teamLogo: 'assets/images/image 14.png',
          catches: 14,
          catchesYards: 235,
          rushes: 8,
          rushesYards: 155,
          passAttempts: 25,
          passYards: 312,
          completions: 15,
          tds: 11,
          flagPull: 28,
          sack: 2,
          interceptions: 4,
          safety: 1,
          conversionPoints: 11,
        ),
      ),
      // Approved stats
      GameStatModel(
        id: '2',
        leagueName: 'Six Nations',
        team1Name: 'GEO',
        team1Logo: 'assets/images/image 12.png',
        team2Name: 'STB',
        team2Logo: 'assets/images/image 14.png',
        date: DateTime(2025, 8, 11),
        time: '02:15 AM PKT',
        status: StatStatus.approved,
        isAssignedToMe: false,
        isCompleted: true,
        team1Stats: TeamStatModel(
          teamName: 'GEO',
          teamLogo: 'assets/images/image 12.png',
        ),
        team2Stats: TeamStatModel(
          teamName: 'STB',
          teamLogo: 'assets/images/image 14.png',
        ),
      ),
      GameStatModel(
        id: '3',
        leagueName: 'World Cup Qualifier',
        team1Name: 'WQ',
        team1Logo: 'assets/images/image 12.png',
        team2Name: 'STC',
        team2Logo: 'assets/images/image 14.png',
        date: DateTime(2025, 8, 11),
        time: '03:30 AM PKT',
        status: StatStatus.approved,
        isAssignedToMe: false,
        isCompleted: true,
        team1Stats: TeamStatModel(
          teamName: 'WQ',
          teamLogo: 'assets/images/image 12.png',
        ),
        team2Stats: TeamStatModel(
          teamName: 'STC',
          teamLogo: 'assets/images/image 14.png',
        ),
      ),
      // All stats (for All Stats tab)
      GameStatModel(
        id: '4',
        leagueName: 'The Rugby Championship',
        team1Name: 'RC',
        team1Logo: 'assets/images/image 12.png',
        team2Name: 'STA',
        team2Logo: 'assets/images/image 14.png',
        date: DateTime(2025, 8, 11),
        time: '01:05 AM PKT',
        status: StatStatus.all,
        isAssignedToMe: true,
        isCompleted: false,
        team1Stats: TeamStatModel(
          teamName: 'RC',
          teamLogo: 'assets/images/image 12.png',
        ),
        team2Stats: TeamStatModel(
          teamName: 'STA',
          teamLogo: 'assets/images/image 14.png',
        ),
      ),
      GameStatModel(
        id: '5',
        leagueName: 'European League',
        team1Name: 'EL',
        team1Logo: 'assets/images/image 12.png',
        team2Name: 'STD',
        team2Logo: 'assets/images/image 14.png',
        date: DateTime(2025, 8, 11),
        time: '04:45 AM PKT',
        status: StatStatus.all,
        isAssignedToMe: false,
        isCompleted: true,
        team1Stats: TeamStatModel(
          teamName: 'EL',
          teamLogo: 'assets/images/image 12.png',
        ),
        team2Stats: TeamStatModel(
          teamName: 'STD',
          teamLogo: 'assets/images/image 14.png',
        ),
      ),
    ]);
  }

  void _setLoading(bool value) {
    _isLoading = value;
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

  void addDraftStat(GameStatModel stat) {
    _allStats.add(stat.copyWith(status: StatStatus.draft));
    notifyListeners();
  }

  Future<void> approveStat(String statId) async {
    _setLoading(true);
    try {
      final index = _allStats.indexWhere((stat) => stat.id == statId);
      if (index != -1) {
        _allStats[index] = _allStats[index].copyWith(
          status: StatStatus.approved,
          isCompleted: true,
        );
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  void deleteStat(String statId) {
    _allStats.removeWhere((stat) => stat.id == statId);
    notifyListeners();
  }

  Future<void> refreshStats() async {
    _setLoading(true);
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 1));
    } finally {
      _setLoading(false);
    }
  }
}

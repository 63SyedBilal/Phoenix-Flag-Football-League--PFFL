import 'package:flutter/material.dart';
import 'package:pffl_managment/features/stat_keeper/services/approved_stats_service.dart';

/// Model for approved stat entry
class ApprovedStatModel {
  final String id;
  final String matchId;
  final String leagueId;
  final String leagueName;
  final String teamId;
  final String teamName;
  final String playerId;
  final String playerName;
  final Map<String, dynamic> stats;
  final DateTime createdAt;
  final String createdBy;

  ApprovedStatModel({
    required this.id,
    required this.matchId,
    required this.leagueId,
    required this.leagueName,
    required this.teamId,
    required this.teamName,
    required this.playerId,
    required this.playerName,
    required this.stats,
    required this.createdAt,
    required this.createdBy,
  });

  factory ApprovedStatModel.fromJson(Map<String, dynamic> json) {
    return ApprovedStatModel(
      id: json['_id']?.toString() ?? '',
      matchId: json['matchId']?.toString() ?? '',
      leagueId: json['leagueId'] is Map
          ? json['leagueId']['_id']?.toString() ?? ''
          : json['leagueId']?.toString() ?? '',
      leagueName: json['leagueId'] is Map
          ? json['leagueId']['leagueName']?.toString() ?? 'Unknown League'
          : 'Unknown League',
      teamId: json['teamId'] is Map
          ? json['teamId']['_id']?.toString() ?? ''
          : json['teamId']?.toString() ?? '',
      teamName: json['teamId'] is Map
          ? json['teamId']['teamName']?.toString() ?? 'Unknown Team'
          : 'Unknown Team',
      playerId: json['playerId'] is Map
          ? json['playerId']['_id']?.toString() ?? ''
          : json['playerId']?.toString() ?? '',
      playerName: json['playerId'] is Map
          ? '${json['playerId']['firstName'] ?? ''} ${json['playerId']['lastName'] ?? ''}'
                .trim()
          : 'Unknown Player',
      stats: json['stats'] as Map<String, dynamic>? ?? {},
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      createdBy: json['createdBy']?.toString() ?? '',
    );
  }

  // Helper getters for common stats
  int get catches => (stats['catches'] as num?)?.toInt() ?? 0;
  int get catchYards => (stats['catchYards'] as num?)?.toInt() ?? 0;
  int get rushes => (stats['rushes'] as num?)?.toInt() ?? 0;
  int get rushYards => (stats['rushYards'] as num?)?.toInt() ?? 0;
  int get touchdowns => (stats['touchdowns'] as num?)?.toInt() ?? 0;
  int get passAttempts => (stats['passAttempts'] as num?)?.toInt() ?? 0;
  int get passYards => (stats['passYards'] as num?)?.toInt() ?? 0;
  int get completions => (stats['completions'] as num?)?.toInt() ?? 0;
  int get flagPull => (stats['flagPull'] as num?)?.toInt() ?? 0;
  int get sack => (stats['sack'] as num?)?.toInt() ?? 0;
  int get interceptions => (stats['interceptions'] as num?)?.toInt() ?? 0;
  int get safeties => (stats['safeties'] as num?)?.toInt() ?? 0;
  int get extraPoints => (stats['extraPoints'] as num?)?.toInt() ?? 0;
}

/// Provider for managing approved stats across all leagues
class ApprovedStatsProvider extends ChangeNotifier {
  List<ApprovedStatModel> _approvedStats = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'All Leagues';

  List<ApprovedStatModel> get approvedStats => _approvedStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;

  // Get unique leagues from approved stats
  List<String> get availableLeagues {
    final leagues = _approvedStats
        .map((stat) => stat.leagueName)
        .toSet()
        .toList();
    leagues.sort();
    return ['All Leagues', ...leagues];
  }

  // Get filtered stats based on selected league
  List<ApprovedStatModel> get filteredStats {
    if (_selectedFilter == 'All Leagues') {
      return _approvedStats;
    }
    return _approvedStats
        .where((stat) => stat.leagueName == _selectedFilter)
        .toList();
  }

  // Get stats grouped by league
  Map<String, List<ApprovedStatModel>> get statsByLeague {
    final Map<String, List<ApprovedStatModel>> grouped = {};
    for (final stat in _approvedStats) {
      if (!grouped.containsKey(stat.leagueName)) {
        grouped[stat.leagueName] = [];
      }
      grouped[stat.leagueName]!.add(stat);
    }
    return grouped;
  }

  // Get stats grouped by player
  Map<String, List<ApprovedStatModel>> get statsByPlayer {
    final Map<String, List<ApprovedStatModel>> grouped = {};
    for (final stat in filteredStats) {
      final key = '${stat.playerName} (${stat.teamName})';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(stat);
    }
    return grouped;
  }

  /// Load all approved stats
  Future<void> loadApprovedStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final statsData = await ApprovedStatsService.getAllApprovedStats();
      _approvedStats = statsData
          .map((data) => ApprovedStatModel.fromJson(data))
          .toList();

      // Sort by creation date (newest first)
      _approvedStats.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _errorMessage = null;
    } catch (e) {
      _approvedStats = [];
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set the league filter
  void setLeagueFilter(String leagueName) {
    if (_selectedFilter != leagueName) {
      _selectedFilter = leagueName;
      notifyListeners();
    }
  }

  /// Refresh approved stats
  Future<void> refreshStats() => loadApprovedStats();

  /// Calculate total stats for a player across all their approved stats
  Map<String, int> calculatePlayerTotals(String playerKey) {
    final playerStats = statsByPlayer[playerKey] ?? [];
    final totals = <String, int>{};

    for (final stat in playerStats) {
      totals['catches'] = (totals['catches'] ?? 0) + stat.catches;
      totals['catchYards'] = (totals['catchYards'] ?? 0) + stat.catchYards;
      totals['rushes'] = (totals['rushes'] ?? 0) + stat.rushes;
      totals['rushYards'] = (totals['rushYards'] ?? 0) + stat.rushYards;
      totals['touchdowns'] = (totals['touchdowns'] ?? 0) + stat.touchdowns;
      totals['passAttempts'] =
          (totals['passAttempts'] ?? 0) + stat.passAttempts;
      totals['passYards'] = (totals['passYards'] ?? 0) + stat.passYards;
      totals['completions'] = (totals['completions'] ?? 0) + stat.completions;
      totals['flagPull'] = (totals['flagPull'] ?? 0) + stat.flagPull;
      totals['sack'] = (totals['sack'] ?? 0) + stat.sack;
      totals['interceptions'] =
          (totals['interceptions'] ?? 0) + stat.interceptions;
      totals['safeties'] = (totals['safeties'] ?? 0) + stat.safeties;
      totals['extraPoints'] = (totals['extraPoints'] ?? 0) + stat.extraPoints;
    }

    return totals;
  }
}


import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/league_service.dart';

/// Model for league summary data
class LeagueSummary {
  final String leagueId;
  final String leagueName;
  final String? logo;
  final int totalTeams;
  final int totalMatches;
  final DateTime startDate;
  final DateTime endDate;
  final String matchFormat;
  final String leagueStatus;
  final double perPlayerFee;
  final CaptainTeamInfo? captainTeam;

  LeagueSummary({
    required this.leagueId,
    required this.leagueName,
    this.logo,
    required this.totalTeams,
    required this.totalMatches,
    required this.startDate,
    required this.endDate,
    required this.matchFormat,
    required this.leagueStatus,
    required this.perPlayerFee,
    this.captainTeam,
  });

  factory LeagueSummary.fromJson(Map<String, dynamic> json) {
    return LeagueSummary(
      leagueId: json['leagueId'] ?? '',
      leagueName: json['leagueName'] ?? '',
      logo: json['logo'],
      totalTeams: json['totalTeams'] ?? 0,
      totalMatches: json['totalMatches'] ?? 0,
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      matchFormat: json['matchFormat'] ?? '5v5',
      leagueStatus: json['leagueStatus'] ?? 'upcoming',
      perPlayerFee: (json['perPlayerFee'] ?? 0).toDouble(),
      captainTeam: json['captainTeam'] != null
          ? CaptainTeamInfo.fromJson(json['captainTeam'])
          : null,
    );
  }
}

/// Model for captain's team information
class CaptainTeamInfo {
  final String teamId;
  final String teamName;
  final int playerCount;
  final int? position;

  CaptainTeamInfo({
    required this.teamId,
    required this.teamName,
    required this.playerCount,
    this.position,
  });

  factory CaptainTeamInfo.fromJson(Map<String, dynamic> json) {
    return CaptainTeamInfo(
      teamId: json['teamId'] ?? '',
      teamName: json['teamName'] ?? '',
      playerCount: json['playerCount'] ?? 0,
      position: json['position'],
    );
  }
}

/// Provider for managing league summary data
class LeagueSummaryProvider extends ChangeNotifier {
  /// Map to cache league summary by leagueId
  final Map<String, LeagueSummary> _summaryCache = {};

  /// Map to track loading state by leagueId
  final Map<String, bool> _loadingStatus = {};

  /// Map to track error messages by leagueId
  final Map<String, String?> _errorMessages = {};

  /// Get league summary data
  /// Returns cached value if available, otherwise fetches from API
  Future<LeagueSummary?> getLeagueSummary(String leagueId) async {
    // Return cached value if available
    if (_summaryCache.containsKey(leagueId)) {
      return _summaryCache[leagueId];
    }

    // Set loading state
    _loadingStatus[leagueId] = true;
    _errorMessages[leagueId] = null;
    notifyListeners();

    try {
      final response = await LeagueService.getLeagueSummary(leagueId);

      if (response['success'] == true && response['data'] != null) {
        final summary = LeagueSummary.fromJson(response['data']);
        _summaryCache[leagueId] = summary;
        _loadingStatus[leagueId] = false;
        notifyListeners();
        return summary;
      } else {
        throw Exception(response['message'] ?? 'Failed to get league summary');
      }
    } catch (e) {
      debugPrint('❌ Error getting league summary: $e');
      _errorMessages[leagueId] = e.toString();
      _loadingStatus[leagueId] = false;
      notifyListeners();
      return null;
    }
  }

  /// Get cached summary without API call
  LeagueSummary? getCachedSummary(String leagueId) {
    return _summaryCache[leagueId];
  }

  /// Check if summary is being loaded
  bool isLoading(String leagueId) {
    return _loadingStatus[leagueId] == true;
  }

  /// Get error message for summary fetch
  String? getError(String leagueId) {
    return _errorMessages[leagueId];
  }

  /// Clear cache for a specific league
  void clearCache(String leagueId) {
    _summaryCache.remove(leagueId);
    _loadingStatus.remove(leagueId);
    _errorMessages.remove(leagueId);
    notifyListeners();
  }

  /// Clear all cached data
  void clearAllCache() {
    _summaryCache.clear();
    _loadingStatus.clear();
    _errorMessages.clear();
    notifyListeners();
  }

  /// Refresh summary for a specific league
  Future<LeagueSummary?> refreshSummary(String leagueId) async {
    clearCache(leagueId);
    return await getLeagueSummary(leagueId);
  }
}

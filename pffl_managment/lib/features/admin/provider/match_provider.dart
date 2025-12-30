import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/core/services/notification_service.dart';
import 'package:pffl_managment/core/services/league_service.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';

/// Provider for managing match creation with Round-Robin validation
/// Handles duplicate match detection, max matches limit, and time slot clashes
class MatchProvider extends ChangeNotifier {
  // State
  List<MatchModel> _matches = [];
  String? _errorText;
  bool _isLoading = false;
  String? _leagueId;
  int? _totalTeams;
  String? _leagueName;

  // Getters
  List<MatchModel> get matches => List.unmodifiable(_matches);
  String? get errorText => _errorText;
  bool get isLoading => _isLoading;
  int? get totalTeams => _totalTeams;
  String? get leagueName => _leagueName;
  String? get leagueId => _leagueId;

  /// Initialize provider with league ID
  Future<void> initialize(String leagueId) async {
    _leagueId = leagueId;
    _errorText = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch league details to get team count and name
      final league = await LeagueService.getLeagueById(leagueId);
      if (league != null) {
        _totalTeams = league.teams.length;
        _leagueName = league.leagueName;
      }

      // Fetch existing matches for this league
      await _loadMatches();
    } catch (e) {
      _errorText = 'Failed to initialize: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all matches for the league
  Future<void> _loadMatches() async {
    if (_leagueId == null) return;

    try {
      _matches = await MatchService.getMatchesByLeague(_leagueId!);
      _errorText = null;
    } catch (e) {
      _errorText = 'Failed to load matches: ${e.toString()}';
      _matches = [];
    }
    notifyListeners();
  }

  /// Calculate maximum allowed matches for round-robin
  /// Formula: n(n-1)/2 where n is number of teams
  int _calculateMaxMatches() {
    if (_totalTeams == null || _totalTeams! < 2) return 0;
    return (_totalTeams! * (_totalTeams! - 1)) ~/ 2;
  }

  /// Check if two teams have already played against each other
  /// Returns true if duplicate match exists (in any order)
  bool _isDuplicateMatch(String teamOneId, String teamTwoId) {
    return _matches.any((match) {
      final homeId = match.homeTeamId ?? '';
      final awayId = match.awayTeamId ?? '';

      // Check both orders: A vs B and B vs A
      return (homeId == teamOneId && awayId == teamTwoId) ||
          (homeId == teamTwoId && awayId == teamOneId);
    });
  }

  /// Check if a team has a time clash with existing matches
  /// A clash occurs if: newStart < existingEnd AND newEnd > existingStart
  bool _hasTimeClash({
    required String teamId,
    required DateTime newStartTime,
    required DateTime newEndTime,
  }) {
    return _matches.any((match) {
      // Skip if this match doesn't involve the team
      if (match.homeTeamId != teamId && match.awayTeamId != teamId) {
        return false;
      }

      // Skip if match doesn't have valid date/time
      if (match.matchDateTime == null) return false;

      // Calculate existing match end time (assume 1 hour duration)
      final existingStartTime = match.matchDateTime!;
      final existingEndTime = existingStartTime.add(const Duration(hours: 1));

      // Check for time overlap
      // Clash if: newStart < existingEnd AND newEnd > existingStart
      return newStartTime.isBefore(existingEndTime) &&
          newEndTime.isAfter(existingStartTime);
    });
  }

  /// Add a new match with all validations
  /// Returns true if match was created successfully, false otherwise
  Future<bool> addMatch({
    required String teamOneId,
    required String teamOneName,
    required String teamTwoId,
    required String teamTwoName,
    required DateTime matchDate,
    required TimeOfDay matchTime,
    String? venue,
    String? refereeId,
    String? statKeeperId,
    String? roundName,
    String? format,
  }) async {
    // Clear previous error
    _errorText = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Validation 1: Check if league is initialized
      if (_leagueId == null || _leagueId!.isEmpty) {
        _errorText = 'League not initialized';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validation 2: Check if teams are different
      if (teamOneId == teamTwoId) {
        _errorText = 'Team A and Team B must be different';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validation 3: Check for duplicate match (Round-Robin rule)
      if (_isDuplicateMatch(teamOneId, teamTwoId)) {
        _errorText = 'These teams have already played against each other';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validation 4: Check maximum matches limit
      final maxMatches = _calculateMaxMatches();
      if (_matches.length >= maxMatches) {
        _errorText =
            'Maximum matches limit reached. League stage is completed.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validation 5: Check time slot clashes
      // Combine date and time
      final matchDateTime = DateTime(
        matchDate.year,
        matchDate.month,
        matchDate.day,
        matchTime.hour,
        matchTime.minute,
      );

      // Assume match duration is 1 hour (can be made configurable)
      final matchEndTime = matchDateTime.add(const Duration(hours: 1));

      // Check clash for team one
      if (_hasTimeClash(
        teamId: teamOneId,
        newStartTime: matchDateTime,
        newEndTime: matchEndTime,
      )) {
        _errorText = 'This team already has a match in this time slot';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check clash for team two
      if (_hasTimeClash(
        teamId: teamTwoId,
        newStartTime: matchDateTime,
        newEndTime: matchEndTime,
      )) {
        _errorText = 'This team already has a match in this time slot';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // All validations passed - Create the match
      final timeStr =
          '${matchTime.hour.toString().padLeft(2, '0')}:${matchTime.minute.toString().padLeft(2, '0')}';

      final matchData = {
        'leagueId': _leagueId,
        'teamA': teamOneId,
        'teamAName': teamOneName,
        'teamB': teamTwoId,
        'teamBName': teamTwoName,
        'format': format ?? '5v5',
        'gameDate': matchDateTime.toIso8601String(),
        'gameTime': timeStr,
        'venue': venue ?? '',
        'roundName': roundName ?? 'Group Stage',
        'gameNumber': '',
        'status': 'upcoming',
        'teamAInitialSide': 'offense',
        'teamBInitialSide': 'defense',
        if (refereeId != null) 'refereeId': refereeId,
        if (statKeeperId != null) 'statKeeperId': statKeeperId,
      };

      // Create match via API
      final createdMatch = await MatchService.createMatch(matchData);

      // Add to local list
      _matches.add(createdMatch);
      _errorText = null;

      // Send notifications to referee and statkeeper (only after successful creation)
      await _sendNotifications(
        match: createdMatch,
        teamOneName: teamOneName,
        teamTwoName: teamTwoName,
        matchDate: matchDate,
        matchTime: matchTime,
        refereeId: refereeId,
        statKeeperId: statKeeperId,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorText = 'Failed to create match: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Send notifications to referee and statkeeper
  Future<void> _sendNotifications({
    required MatchModel match,
    required String teamOneName,
    required String teamTwoName,
    required DateTime matchDate,
    required TimeOfDay matchTime,
    String? refereeId,
    String? statKeeperId,
  }) async {
    // Format date and time for notification message
    final dateStr =
        '${matchDate.day}/${matchDate.month}/${matchDate.year}';
    final timeStr =
        '${matchTime.hour.toString().padLeft(2, '0')}:${matchTime.minute.toString().padLeft(2, '0')}';
    final endTime = matchTime.replacing(
      hour: (matchTime.hour + 1) % 24,
      minute: matchTime.minute,
    );
    final endTimeStr =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    final leagueNameStr = _leagueName ?? 'the league';

    // Notification message template
    final messageTemplate =
        '$teamOneName vs $teamTwoName\nDate: $dateStr\nTime: $timeStr - $endTimeStr\nLeague: $leagueNameStr';

    // Send notification to referee
    if (refereeId != null && match.id != null) {
      try {
        await NotificationService.sendNotification(
          receiverId: refereeId,
          type: 'GAME_ASSIGNED',
          message: messageTemplate,
          leagueId: _leagueId,
          matchId: match.id,
        );
        debugPrint('✅ Notification sent to referee: $refereeId');
      } catch (e) {
        debugPrint('⚠️ Failed to send notification to referee: $e');
        // Don't fail match creation if notification fails
      }
    }

    // Send notification to statkeeper
    if (statKeeperId != null && match.id != null) {
      try {
        await NotificationService.sendNotification(
          receiverId: statKeeperId,
          type: 'GAME_ASSIGNED',
          message: messageTemplate,
          leagueId: _leagueId,
          matchId: match.id,
        );
        debugPrint('✅ Notification sent to statkeeper: $statKeeperId');
      } catch (e) {
        debugPrint('⚠️ Failed to send notification to statkeeper: $e');
        // Don't fail match creation if notification fails
      }
    }
  }

  /// Refresh matches from backend
  Future<void> refreshMatches() async {
    await _loadMatches();
  }

  /// Clear error message
  void clearError() {
    _errorText = null;
    notifyListeners();
  }
}


import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/core/services/league_service.dart'
    show TeamModel, LeagueService;
import 'package:pffl_managment/core/services/user_service.dart' show UserModel;
import 'package:pffl_managment/core/services/notification_service.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';

class UpcomingGamesProvider extends ChangeNotifier {
  MatchModel? _editingMatch;
  String? _selectedTeamA;
  String? _selectedTeamB;
  String? _selectedTeamAId;
  String? _selectedTeamBId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedVenue;
  String? _selectedRefereeId;
  String? _selectedStatKeeperId;
  String? _selectedRoundName;
  String? _leagueId;
  String? _leagueFormat;
  DateTime? _leagueStartDate;
  DateTime? _leagueEndDate;

  // Available options from backend
  List<TeamModel> _teams = [];
  List<UserModel> _referees = [];
  List<UserModel> _statKeepers = [];
  bool _isLoadingTeams = false;
  bool _isLoadingReferees = false;
  bool _isLoadingStatKeepers = false;
  String? _errorMessage;

  // Game stages
  static const List<String> _availableStages = [
    'Final',
    'Semi-Final',
    'Quarter-Final',
    'Group Stage',
  ];

  final List<String> _venues = [
    'Select Venue',
    'Main Stadium',
    'Training Ground A',
    'Training Ground B',
    'City Arena',
    'Community Field',
  ];

  // Getters
  MatchModel? get editingMatch => _editingMatch;
  String? get selectedTeamA => _selectedTeamA;
  String? get selectedTeamB => _selectedTeamB;
  String? get selectedTeamAId => _selectedTeamAId;
  String? get selectedTeamBId => _selectedTeamBId;
  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get selectedTime => _selectedTime;
  String? get selectedVenue => _selectedVenue;
  String? get selectedRefereeId => _selectedRefereeId;
  String? get selectedStatKeeperId => _selectedStatKeeperId;
  String? get selectedRoundName => _selectedRoundName;
  String? get leagueId => _leagueId;
  DateTime? get leagueStartDate => _leagueStartDate;
  DateTime? get leagueEndDate => _leagueEndDate;
  List<TeamModel> get availableTeams => _teams;
  List<UserModel> get availableReferees => _referees;
  List<UserModel> get availableStatKeepers => _statKeepers;
  List<String> get availableStages => _availableStages;
  List<String> get availableVenues => _venues;
  bool get isLoadingTeams => _isLoadingTeams;
  bool get isLoadingReferees => _isLoadingReferees;
  bool get isLoadingStatKeepers => _isLoadingStatKeepers;
  String? get errorMessage => _errorMessage;

  /// Initialize provider with league information
  Future<void> initializeWithLeague(LeagueCreationModel league) async {
    _leagueId = league.id;
    _leagueFormat = league.format;
    _leagueStartDate = league.startDate;
    _leagueEndDate = league.endDate;

    // Fetch teams, referees, and stat keepers
    await Future.wait([
      fetchTeamsForLeague(league.id),
      fetchReferees(),
      fetchStatKeepers(),
    ]);
  }

  /// Refresh all data (teams, referees, stat keepers) for the current league
  /// This ensures that recently accepted invitations are reflected in the UI
  Future<void> refreshData() async {
    if (_leagueId == null || _leagueId!.isEmpty) {
      debugPrint('⚠️ Cannot refresh data: No league ID set');
      return;
    }

    debugPrint('🔄 Refreshing all data for league: $_leagueId');

    // Clear error message
    _errorMessage = null;
    notifyListeners();

    // Fetch fresh data from backend
    await Future.wait([
      fetchTeamsForLeague(_leagueId!),
      fetchReferees(),
      fetchStatKeepers(),
    ]);

    debugPrint('✅ Data refresh completed');
  }

  /// Initialize provider without league (for editing matches outside league context)
  Future<void> initializeWithoutLeague() async {
    _leagueId = null;
    _leagueStartDate = null;
    _leagueEndDate = null;

    // Fetch teams, referees, and stat keepers without league filter
    await Future.wait([
      fetchTeamsForLeague(''),
      fetchReferees(),
      fetchStatKeepers(),
    ]);
  }

  /// Fetch teams for a specific league
  /// Only returns teams that were invited/added to the league during league creation
  Future<void> fetchTeamsForLeague(String leagueId) async {
    _isLoadingTeams = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (leagueId.isEmpty) {
        // No league ID, use empty list
        debugPrint('⚠️ Empty league ID provided, returning empty teams list');
        _teams = [];
        _isLoadingTeams = false;
        notifyListeners();
        return;
      }

      debugPrint('📡 Fetching teams for league ID: $leagueId');

      // Fetch league details which includes populated teams
      final league = await LeagueService.getLeagueById(leagueId);

      if (league == null) {
        debugPrint('❌ League not found for ID: $leagueId');
        _teams = [];
        _errorMessage = 'League not found';
        _isLoadingTeams = false;
        notifyListeners();
        return;
      }

      debugPrint('✅ League fetched: ${league.leagueName}');
      debugPrint('📊 Teams count in league: ${league.teams.length}');

      if (league.teams.isNotEmpty) {
        // Use teams from the league (only teams invited/added during league creation)
        _teams = league.teams;
        debugPrint(
          '✅ Loaded ${_teams.length} teams from league: ${league.leagueName}',
        );
        for (var team in _teams) {
          debugPrint('   - Team: ${team.teamName} (ID: ${team.id})');
        }
      } else {
        // League has no teams yet - this is not an error, just empty state
        _teams = [];
        debugPrint('ℹ️ League has no teams assigned yet');
        debugPrint(
          '   - Teams will appear when invited in Step 4 of league creation',
        );
        // Don't show error - just let the dropdown be empty
        // User can still create the league and add teams later
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching teams for league: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      _teams = [];
      _errorMessage = 'Failed to load teams for this league: ${e.toString()}';
    } finally {
      _isLoadingTeams = false;
      notifyListeners();
    }
  }

  /// Fetch referees assigned to the league
  /// Only shows referees who were previously invited and assigned during league creation
  Future<void> fetchReferees() async {
    _isLoadingReferees = true;
    notifyListeners();

    try {
      if (_leagueId == null || _leagueId!.isEmpty) {
        // No league ID, use empty list
        debugPrint(
          '⚠️ Empty league ID provided, returning empty referees list',
        );
        _referees = [];
        _isLoadingReferees = false;
        notifyListeners();
        return;
      }

      debugPrint('📡 Fetching referees for league ID: $_leagueId');

      // Fetch league details which includes populated referees (only those assigned to league)
      final league = await LeagueService.getLeagueById(_leagueId!);

      if (league == null) {
        debugPrint('❌ League not found for ID: $_leagueId');
        _referees = [];
        _errorMessage = 'League not found';
        _isLoadingReferees = false;
        notifyListeners();
        return;
      }

      debugPrint('✅ League fetched: ${league.leagueName}');
      debugPrint('📊 Referees count in league: ${league.referees.length}');

      if (league.referees.isNotEmpty) {
        // Use referees from the league (only referees invited and assigned during league creation)
        _referees = league.referees;
        debugPrint(
          '✅ Loaded ${_referees.length} referees from league: ${league.leagueName}',
        );
        for (var referee in _referees) {
          debugPrint(
            '   - Referee: ${referee.displayName} (ID: ${referee.id})',
          );
        }
      } else {
        // League has no referees yet - this is not an error, just empty state
        _referees = [];
        debugPrint('ℹ️ League has no referees assigned yet');
        debugPrint(
          '   - Referees will appear when they accept invitation in Step 2 of league creation',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching referees for league: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      _referees = [];
      _errorMessage =
          'Failed to load referees for this league: ${e.toString()}';
    } finally {
      _isLoadingReferees = false;
      notifyListeners();
    }
  }

  /// Fetch stat keepers assigned to the league
  /// Only shows stat keepers who were previously invited and assigned during league creation
  Future<void> fetchStatKeepers() async {
    _isLoadingStatKeepers = true;
    notifyListeners();

    try {
      if (_leagueId == null || _leagueId!.isEmpty) {
        // No league ID, use empty list
        debugPrint(
          '⚠️ Empty league ID provided, returning empty stat keepers list',
        );
        _statKeepers = [];
        _isLoadingStatKeepers = false;
        notifyListeners();
        return;
      }

      debugPrint('📡 Fetching stat keepers for league ID: $_leagueId');

      // Fetch league details which includes populated stat keepers (only those assigned to league)
      final league = await LeagueService.getLeagueById(_leagueId!);

      if (league == null) {
        debugPrint('❌ League not found for ID: $_leagueId');
        _statKeepers = [];
        _errorMessage = 'League not found';
        _isLoadingStatKeepers = false;
        notifyListeners();
        return;
      }

      debugPrint('✅ League fetched: ${league.leagueName}');
      debugPrint(
        '📊 Stat keepers count in league: ${league.statKeepers.length}',
      );

      if (league.statKeepers.isNotEmpty) {
        // Use stat keepers from the league (only stat keepers invited and assigned during league creation)
        _statKeepers = league.statKeepers;
        debugPrint(
          '✅ Loaded ${_statKeepers.length} stat keepers from league: ${league.leagueName}',
        );
        for (var statKeeper in _statKeepers) {
          debugPrint(
            '   - Stat Keeper: ${statKeeper.displayName} (ID: ${statKeeper.id})',
          );
        }
      } else {
        // League has no stat keepers yet - this is not an error, just empty state
        _statKeepers = [];
        debugPrint('ℹ️ League has no stat keepers assigned yet');
        debugPrint(
          '   - Stat keepers will appear when they accept invitation in Step 3 of league creation',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching stat keepers for league: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      _statKeepers = [];
      _errorMessage =
          'Failed to load stat keepers for this league: ${e.toString()}';
    } finally {
      _isLoadingStatKeepers = false;
      notifyListeners();
    }
  }

  /// Load match for editing
  void loadMatch(MatchModel match) {
    _editingMatch = match;
    _selectedTeamA = match.homeTeam;
    _selectedTeamB = match.awayTeam;

    // Find team IDs from available teams (only if teams are loaded)
    if (_teams.isNotEmpty) {
      final teamA = _teams.firstWhere(
        (t) => t.teamName == match.homeTeam || t.enterCode == match.homeTeam,
        orElse: () => _teams.first,
      );
      final teamB = _teams.firstWhere(
        (t) => t.teamName == match.awayTeam || t.enterCode == match.awayTeam,
        orElse: () => _teams.length > 1 ? _teams[1] : _teams.first,
      );
      _selectedTeamAId = teamA.id;
      _selectedTeamBId = teamB.id;
    } else {
      // Teams not loaded yet, will be set when teams are fetched
      _selectedTeamAId = null;
      _selectedTeamBId = null;
    }

    // Parse date and time
    if (match.matchDateTime != null) {
      _selectedDate = match.matchDateTime;
      _selectedTime = TimeOfDay.fromDateTime(match.matchDateTime!);
    } else {
      // Try to parse from date string (dd/MM format)
      try {
        final parts = match.date.split('/');
        if (parts.length == 2) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final now = DateTime.now();
          _selectedDate = DateTime(now.year, month, day);
        } else {
          _selectedDate = DateTime.now();
        }
      } catch (e) {
        _selectedDate = DateTime.now();
      }
      _selectedTime = TimeOfDay.now();
    }

    _selectedVenue = match.venue ?? _venues.first;
    _selectedRefereeId = match.refereeId;
    _selectedStatKeeperId = match.statKeeperId;
    _selectedRoundName = match.roundName ?? 'Group Stage';
    notifyListeners();
  }

  void updateTeamA(String? teamId) {
    _selectedTeamAId = teamId;
    if (_teams.isNotEmpty && teamId != null) {
      final team = _teams.firstWhere(
        (t) => t.id == teamId,
        orElse: () => _teams.first,
      );
      _selectedTeamA = team.teamName;
    }
    notifyListeners();
  }

  void updateTeamB(String? teamId) {
    _selectedTeamBId = teamId;
    if (_teams.isNotEmpty && teamId != null) {
      final team = _teams.firstWhere(
        (t) => t.id == teamId,
        orElse: () => _teams.length > 1 ? _teams[1] : _teams.first,
      );
      _selectedTeamB = team.teamName;
    }
    notifyListeners();
  }

  Future<void> updateDate(DateTime date) async {
    // Validate date is within league range (only if league is set)
    if (_leagueStartDate != null && _leagueEndDate != null) {
      if (date.isBefore(_leagueStartDate!) || date.isAfter(_leagueEndDate!)) {
        throw Exception(
          'Game date must be between ${_formatDate(_leagueStartDate!)} and ${_formatDate(_leagueEndDate!)}',
        );
      }
    }

    // Validate time if both date and time are set
    if (_selectedTime != null && _leagueId != null) {
      await _validateGameTime(date, _selectedTime!, _editingMatch?.id);
    }

    _selectedDate = date;
    notifyListeners();
  }

  Future<void> updateTime(TimeOfDay time) async {
    // Validate time if both date and time are set
    if (_selectedDate != null && _leagueId != null) {
      await _validateGameTime(_selectedDate!, time, _editingMatch?.id);
    }

    _selectedTime = time;
    notifyListeners();
  }

  void updateVenue(String? venue) {
    _selectedVenue = venue;
    notifyListeners();
  }

  void updateReferee(String? refereeId) {
    _selectedRefereeId = refereeId;
    notifyListeners();
  }

  void updateStatKeeper(String? statKeeperId) {
    _selectedStatKeeperId = statKeeperId;
    notifyListeners();
  }

  void updateRoundName(String? roundName) {
    _selectedRoundName = roundName;
    notifyListeners();
  }

  /// Validate game time and date constraints
  /// - Maximum 4 games per day
  /// - No time conflicts with existing games
  Future<void> _validateGameTime(
    DateTime date,
    TimeOfDay time,
    String? excludeMatchId,
  ) async {
    if (_leagueId == null) return;

    try {
      // Fetch all games for the league
      final allGames = await MatchService.getMatchesByLeague(_leagueId!);

      // Filter games on the same date (excluding the current match if editing)
      final gamesOnSameDate = allGames.where((game) {
        if (game.id == excludeMatchId) return false;
        if (game.matchDateTime == null) return false;

        return game.matchDateTime!.year == date.year &&
            game.matchDateTime!.month == date.month &&
            game.matchDateTime!.day == date.day;
      }).toList();

      // Check maximum 4 games per day
      if (gamesOnSameDate.length >= 4) {
        throw Exception('Maximum 4 games can be scheduled per day');
      }

      // Check for time conflicts
      final selectedTimeMinutes = time.hour * 60 + time.minute;
      for (final game in gamesOnSameDate) {
        if (game.matchDateTime != null) {
          final gameTimeMinutes =
              game.matchDateTime!.hour * 60 + game.matchDateTime!.minute;

          // Consider games at the same time or within 30 minutes as conflicting
          final timeDifference = (selectedTimeMinutes - gameTimeMinutes).abs();
          if (timeDifference < 30) {
            throw Exception(
              'Game time conflicts with existing game on this date',
            );
          }
        }
      }
    } catch (e) {
      // Re-throw validation errors
      if (e.toString().contains('Maximum 4 games') ||
          e.toString().contains('conflicts')) {
        rethrow;
      }
      // For other errors (like network issues), log but don't block
      print('Error validating game time: $e');
    }
  }

  /// Validate all required fields are filled
  Future<bool> validateFields() async {
    if (_leagueId == null) {
      _errorMessage = 'League ID is required';
      notifyListeners();
      return false;
    }

    // Check if teams are available before validating selection
    if (_teams.isEmpty) {
      _errorMessage =
          'No teams in this league yet. Please invite teams first from the League settings.';
      notifyListeners();
      return false;
    }

    if (_selectedTeamAId == null || _selectedTeamBId == null) {
      _errorMessage = 'Both teams must be selected';
      notifyListeners();
      return false;
    }
    if (_selectedTeamAId == _selectedTeamBId) {
      _errorMessage = 'Team A and Team B must be different';
      notifyListeners();
      return false;
    }
    if (_selectedDate == null) {
      _errorMessage = 'Game date is required';
      notifyListeners();
      return false;
    }
    if (_selectedTime == null) {
      _errorMessage = 'Game time is required';
      notifyListeners();
      return false;
    }
    // Only validate date range if league is set
    if (_leagueStartDate != null && _leagueEndDate != null) {
      if (_selectedDate!.isBefore(_leagueStartDate!) ||
          _selectedDate!.isAfter(_leagueEndDate!)) {
        _errorMessage =
            'Game date must be within league date range (${_formatDate(_leagueStartDate!)} - ${_formatDate(_leagueEndDate!)})';
        notifyListeners();
        return false;
      }
    }

    // Validate time constraints
    try {
      await _validateGameTime(
        _selectedDate!,
        _selectedTime!,
        _editingMatch?.id,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Create a new match
  Future<MatchModel> createMatch() async {
    if (!await validateFields()) {
      throw Exception(_errorMessage ?? 'Validation failed');
    }

    try {
      // Format time as HH:mm
      final timeStr =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      // Combine date and time for gameDate
      final gameDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final matchData = {
        'leagueId': _leagueId,
        'teamA': _selectedTeamAId,
        'teamAName': _selectedTeamA ?? '',
        'teamB': _selectedTeamBId,
        'teamBName': _selectedTeamB ?? '',
        'format': _leagueFormat ?? '5v5',
        'gameDate': gameDateTime.toIso8601String(),
        'gameTime': timeStr,
        'venue': _selectedVenue ?? '',
        'roundName': _selectedRoundName ?? 'Group Stage',
        'gameNumber': '',
        'status': 'upcoming',
        'teamAInitialSide': 'offense',
        'teamBInitialSide': 'defense',
        if (_selectedRefereeId != null) 'refereeId': _selectedRefereeId,
        if (_selectedStatKeeperId != null)
          'statKeeperId': _selectedStatKeeperId,
      };

      final createdMatch = await MatchService.createMatch(matchData);

      // Send notifications to assigned referee and StatKeeper
      await _sendAssignmentNotifications(createdMatch);

      _errorMessage = null;
      notifyListeners();
      return createdMatch;
    } catch (e) {
      _errorMessage = 'Failed to create match: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Update an existing match
  Future<MatchModel> updateMatch() async {
    if (_editingMatch == null || _editingMatch!.id == null) {
      throw Exception('No match selected for editing');
    }

    if (!await validateFields()) {
      throw Exception(_errorMessage ?? 'Validation failed');
    }

    try {
      // Format time as HH:mm
      final timeStr =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      // Combine date and time for gameDate
      final gameDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final matchData = {
        'teamA': _selectedTeamAId,
        'teamAName': _selectedTeamA ?? '',
        'teamB': _selectedTeamBId,
        'teamBName': _selectedTeamB ?? '',
        'gameDate': gameDateTime.toIso8601String(),
        'gameTime': timeStr,
        'venue': _selectedVenue ?? '',
        'roundName': _selectedRoundName ?? 'Group Stage',
        'gameNumber': _editingMatch!.gameNumber ?? '',
        if (_selectedRefereeId != null) 'refereeId': _selectedRefereeId,
        if (_selectedStatKeeperId != null)
          'statKeeperId': _selectedStatKeeperId,
      };

      final updatedMatch = await MatchService.updateMatch(
        _editingMatch!.id!,
        matchData,
      );

      // Send notifications for new assignments (only if assignments changed)
      await _sendAssignmentNotifications(updatedMatch, isUpdate: true);

      _errorMessage = null;
      notifyListeners();
      return updatedMatch;
    } catch (e) {
      _errorMessage = 'Failed to update match: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Save match (create or update)
  Future<void> saveMatch() async {
    if (_editingMatch != null && _editingMatch!.id != null) {
      await updateMatch();
    } else {
      await createMatch();
    }
  }

  /// Reset provider state
  void reset() {
    _editingMatch = null;
    _selectedTeamA = null;
    _selectedTeamB = null;
    _selectedTeamAId = null;
    _selectedTeamBId = null;
    _selectedDate = null;
    _selectedTime = null;
    _selectedVenue = null;
    _selectedRefereeId = null;
    _selectedStatKeeperId = null;
    _selectedRoundName = null;
    _errorMessage = null;
    notifyListeners();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Send assignment notifications to referee and StatKeeper
  Future<void> _sendAssignmentNotifications(
    MatchModel match, {
    bool isUpdate = false,
  }) async {
    try {
      final gameInfo = '${match.homeTeam} vs ${match.awayTeam}';
      final dateStr = _formatDate(match.matchDateTime ?? DateTime.now());
      final timeStr = match.time.isNotEmpty ? ' at ${match.time}' : '';
      final venueStr = (match.venue?.isNotEmpty ?? false)
          ? ' at ${match.venue}'
          : '';

      // Send notification to referee if assigned
      if (match.refereeId != null && match.refereeId!.isNotEmpty) {
        // Check if this is a new assignment (for updates)
        bool shouldNotifyReferee = true;
        if (isUpdate && _editingMatch != null) {
          shouldNotifyReferee = _editingMatch!.refereeId != match.refereeId;
        }

        if (shouldNotifyReferee) {
          final refereeMessage = isUpdate
              ? 'You have been assigned as referee for updated game: $gameInfo on $dateStr$timeStr$venueStr'
              : 'You have been assigned as referee for game: $gameInfo on $dateStr$timeStr$venueStr';

          final refereeNotificationSent =
              await NotificationService.sendNotification(
                receiverId: match.refereeId!,
                type: 'GAME_ASSIGNMENT_REFEREE',
                message: refereeMessage,
                leagueId: match.leagueId,
              );

          if (refereeNotificationSent) {
            debugPrint('✅ Referee assignment notification sent successfully');
          } else {
            debugPrint('⚠️ Failed to send referee assignment notification');
          }
        }
      }

      // Send notification to StatKeeper if assigned
      if (match.statKeeperId != null && match.statKeeperId!.isNotEmpty) {
        // Check if this is a new assignment (for updates)
        bool shouldNotifyStatKeeper = true;
        if (isUpdate && _editingMatch != null) {
          shouldNotifyStatKeeper =
              _editingMatch!.statKeeperId != match.statKeeperId;
        }

        if (shouldNotifyStatKeeper) {
          final statKeeperMessage = isUpdate
              ? 'You have been assigned as stat keeper for updated game: $gameInfo on $dateStr$timeStr$venueStr'
              : 'You have been assigned as stat keeper for game: $gameInfo on $dateStr$timeStr$venueStr';

          final statKeeperNotificationSent =
              await NotificationService.sendNotification(
                receiverId: match.statKeeperId!,
                type: 'GAME_ASSIGNMENT_STATKEEPER',
                message: statKeeperMessage,
                leagueId: match.leagueId,
              );

          if (statKeeperNotificationSent) {
            debugPrint(
              '✅ StatKeeper assignment notification sent successfully',
            );
          } else {
            debugPrint('⚠️ Failed to send StatKeeper assignment notification');
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error sending assignment notifications: $e');
      // Don't throw error - assignment notifications are not critical for match creation
    }
  }
}

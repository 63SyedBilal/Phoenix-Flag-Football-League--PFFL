import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/core/services/league_service.dart'
    show TeamModel;
    // TODO: LeagueService will be used when backend team fetching is implemented
import 'package:pffl_managment/core/services/user_service.dart'
    show UserService, UserModel;
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

  // TODO: TEMPORARY - Dummy teams for development/testing
  // In the future, teams will be fetched from the backend API
  // Teams will be created by captains during team creation process
  // This list should be removed once backend team fetching is fully implemented
  // NOTE: Using valid MongoDB ObjectId format (24 hex characters) for dummy IDs
  // so backend validation doesn't fail. These teams don't exist in database.
  static List<TeamModel> _getDummyTeams() {
    return [
      TeamModel(
        id: '507f1f77bcf86cd799439011', // Valid ObjectId format
        teamName: 'Shadow Wolves',
        enterCode: 'SW',
        location: 'City Arena',
        skillLevel: 'intermediate',
      ),
      TeamModel(
        id: '507f1f77bcf86cd799439012', // Valid ObjectId format
        teamName: 'Iron Rangers',
        enterCode: 'IR',
        location: 'Main Stadium',
        skillLevel: 'advanced',
      ),
      TeamModel(
        id: '507f1f77bcf86cd799439013', // Valid ObjectId format
        teamName: 'Eagle Eye',
        enterCode: 'EE',
        location: 'Training Ground A',
        skillLevel: 'beginner',
      ),
      TeamModel(
        id: '507f1f77bcf86cd799439014', // Valid ObjectId format
        teamName: 'Thunder Strike',
        enterCode: 'TS',
        location: 'City Arena',
        skillLevel: 'professional',
      ),
      TeamModel(
        id: '507f1f77bcf86cd799439015', // Valid ObjectId format
        teamName: 'Mystic Dragons',
        enterCode: 'MD',
        location: 'Training Ground B',
        skillLevel: 'intermediate',
      ),
    ];
  }

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
  /// TODO: In the future, teams will be fetched from the backend API
  /// Teams will be created by captains during team creation process
  /// For now, using dummy teams to allow the flow to continue
  Future<void> initializeWithLeague(LeagueCreationModel league) async {
    _leagueId = league.id;
    _leagueStartDate = league.startDate;
    _leagueEndDate = league.endDate;
    
    // Fetch teams, referees, and stat keepers
    // TODO: Replace with actual backend API calls when ready
    // Teams will be fetched from backend in the future
    await Future.wait([
      fetchTeamsForLeague(league.id), // Currently returns dummy teams
      fetchReferees(),
      fetchStatKeepers(),
    ]);
  }

  /// Initialize provider without league (for editing matches outside league context)
  /// TODO: In the future, teams will be fetched from the backend API
  /// Teams will be created by captains during team creation process
  Future<void> initializeWithoutLeague() async {
    _leagueId = null;
    _leagueStartDate = null;
    _leagueEndDate = null;
    
    // Fetch teams, referees, and stat keepers without league filter
    // TODO: Replace with actual backend API call when ready
    // For now, using dummy teams to allow the flow to continue
    await Future.wait([
      fetchTeamsForLeague(''), // Empty string will use dummy teams
      fetchReferees(),
      fetchStatKeepers(),
    ]);
  }

  /// Fetch teams for a specific league
  /// TODO: In the future, teams will be fetched from the backend API
  /// Teams will be created by captains during team creation process
  /// For now, using dummy teams to allow the flow to continue
  Future<void> fetchTeamsForLeague(String leagueId) async {
    _isLoadingTeams = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with actual backend API call
      // final allTeams = await LeagueService.getTeamsByLeague(leagueId);
      // _teams = allTeams;
      
      // TEMPORARY: Using dummy teams until backend team fetching is implemented
      // Teams will be fetched from backend in the future
      // Teams will be created by captains during team creation
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
      _teams = _getDummyTeams();
      
      // Uncomment below when backend is ready:
      // final allTeams = await LeagueService.getAllTeams();
      // Filter teams that belong to this league
      // Note: We'll need to check if team is in league.teams array
      // For now, we'll use all teams and let backend validate
      // _teams = allTeams;
    } catch (e) {
      // If backend fetch fails, fall back to dummy teams
      // TODO: Remove this fallback once backend is fully implemented
      print('Error fetching teams from backend, using dummy teams: $e');
      _teams = _getDummyTeams();
    } finally {
      _isLoadingTeams = false;
      notifyListeners();
    }
  }

  /// Fetch referees (free agents can be referees)
  Future<void> fetchReferees() async {
    _isLoadingReferees = true;
    notifyListeners();

    try {
      _referees = await UserService.getFreeAgents();
    } catch (e) {
      print('Error fetching referees: $e');
      _referees = [];
    } finally {
      _isLoadingReferees = false;
      notifyListeners();
    }
  }

  /// Fetch stat keepers
  Future<void> fetchStatKeepers() async {
    _isLoadingStatKeepers = true;
    notifyListeners();

    try {
      _statKeepers = await UserService.getStatKeepers();
    } catch (e) {
      print('Error fetching stat keepers: $e');
      _statKeepers = [];
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

  void updateDate(DateTime date) {
    // Validate date is within league range (only if league is set)
    if (_leagueStartDate != null && _leagueEndDate != null) {
      if (date.isBefore(_leagueStartDate!) || date.isAfter(_leagueEndDate!)) {
        throw Exception(
          'Game date must be between ${_formatDate(_leagueStartDate!)} and ${_formatDate(_leagueEndDate!)}',
        );
      }
    }
    _selectedDate = date;
    notifyListeners();
  }

  void updateTime(TimeOfDay time) {
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

  /// Validate all required fields are filled
  bool validateFields() {
    if (_leagueId == null) {
      _errorMessage = 'League ID is required';
      notifyListeners();
      return false;
    }
    
    // Check if teams are available before validating selection
    if (_teams.isEmpty) {
      _errorMessage = 'No teams available. Please wait for teams to load.';
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
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Create a new match
  Future<MatchModel> createMatch() async {
    if (!validateFields()) {
      throw Exception(_errorMessage ?? 'Validation failed');
    }

    try {
      // Format time as HH:mm
      final timeStr = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

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
        'gameDate': gameDateTime.toIso8601String(),
        'gameTime': timeStr,
        'venue': _selectedVenue ?? '',
        'roundName': _selectedRoundName ?? 'Group Stage',
        'gameNumber': '',
        'status': 'upcoming',
        if (_selectedRefereeId != null) 'refereeId': _selectedRefereeId,
        if (_selectedStatKeeperId != null) 'statKeeperId': _selectedStatKeeperId,
      };

      final createdMatch = await MatchService.createMatch(matchData);
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

    if (!validateFields()) {
      throw Exception(_errorMessage ?? 'Validation failed');
    }

    try {
      // Format time as HH:mm
      final timeStr = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

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
        if (_selectedRefereeId != null) 'refereeId': _selectedRefereeId,
        if (_selectedStatKeeperId != null) 'statKeeperId': _selectedStatKeeperId,
      };

      final updatedMatch =
          await MatchService.updateMatch(_editingMatch!.id!, matchData);
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
}

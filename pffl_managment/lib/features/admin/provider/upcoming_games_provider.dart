import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/services/league_service.dart'
    show TeamModel;
import 'package:pffl_managment/core/services/user_service.dart' show UserModel;
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'upcoming_games_fetch_helper.dart';
import 'upcoming_games_validation_helper.dart';
import 'upcoming_games_action_handler.dart';

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

  List<TeamModel> _teams = [];
  List<UserModel> _referees = [];
  List<UserModel> _statKeepers = [];
  bool _isLoadingTeams = false;
  bool _isLoadingReferees = false;
  bool _isLoadingStatKeepers = false;
  String? _errorMessage;

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

  Future<void> initializeWithLeague(LeagueCreationModel league) async {
    _leagueId = league.id;
    _leagueFormat = league.format;
    _leagueStartDate = league.startDate;
    _leagueEndDate = league.endDate;
    await refreshData();
  }

  Future<void> refreshData() async {
    if (_leagueId == null || _leagueId!.isEmpty) return;
    _isLoadingTeams = _isLoadingReferees = _isLoadingStatKeepers = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await UpcomingGamesFetchHelper.fetchAllRequiredData(
        _leagueId!,
      );
      _teams = data['teams'];
      _referees = data['referees'];
      _statKeepers = data['statKeepers'];
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoadingTeams = _isLoadingReferees = _isLoadingStatKeepers = false;
      notifyListeners();
    }
  }

  Future<void> initializeWithoutLeague() async {
    _leagueId = null;
    _leagueStartDate = null;
    _leagueEndDate = null;
    _isLoadingTeams = _isLoadingReferees = _isLoadingStatKeepers = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _teams = [];
      // Maybe fetch all referees/statkeepers?
      _referees = await UpcomingGamesFetchHelper.fetchReferees('');
      _statKeepers = await UpcomingGamesFetchHelper.fetchStatKeepers('');
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoadingTeams = _isLoadingReferees = _isLoadingStatKeepers = false;
      notifyListeners();
    }
  }

  void loadMatch(MatchModel match) {
    _editingMatch = match;
    _selectedTeamA = match.homeTeam;
    _selectedTeamB = match.awayTeam;
    if (_teams.isNotEmpty) {
      _selectedTeamAId = _teams.any((t) => t.id == match.homeTeamId)
          ? match.homeTeamId
          : null;
      _selectedTeamBId = _teams.any((t) => t.id == match.awayTeamId)
          ? match.awayTeamId
          : null;
    }
    _selectedDate = match.matchDateTime ?? DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate!);
    _selectedVenue = match.venue ?? _venues.first;
    _selectedRefereeId = match.refereeId;
    _selectedStatKeeperId = match.statKeeperId;
    _selectedRoundName = match.roundName ?? 'Group Stage';
    notifyListeners();
  }

  void updateTeamA(String? id) {
    _selectedTeamAId = id;
    _selectedTeamA = _teams.firstWhere((t) => t.id == id).teamName;
    notifyListeners();
  }

  void updateTeamB(String? id) {
    _selectedTeamBId = id;
    _selectedTeamB = _teams.firstWhere((t) => t.id == id).teamName;
    notifyListeners();
  }

  Future<void> updateDate(DateTime date) async {
    if (_selectedTime != null && _leagueId != null) {
      await UpcomingGamesValidationHelper.validateGameTime(
        leagueId: _leagueId!,
        date: date,
        time: _selectedTime!,
        excludeMatchId: _editingMatch?.id,
      );
    }
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> updateTime(TimeOfDay time) async {
    if (_selectedDate != null && _leagueId != null) {
      await UpcomingGamesValidationHelper.validateGameTime(
        leagueId: _leagueId!,
        date: _selectedDate!,
        time: time,
        excludeMatchId: _editingMatch?.id,
      );
    }
    _selectedTime = time;
    notifyListeners();
  }

  void updateVenue(String? v) {
    _selectedVenue = v;
    notifyListeners();
  }

  void updateReferee(String? id) {
    _selectedRefereeId = id;
    notifyListeners();
  }

  void updateStatKeeper(String? id) {
    _selectedStatKeeperId = id;
    notifyListeners();
  }

  void updateRoundName(String? r) {
    _selectedRoundName = r;
    notifyListeners();
  }

  Future<bool> validateFields() async {
    if (_leagueId == null) {
      _errorMessage = 'League ID is required';
      notifyListeners();
      return false;
    }
    if (_selectedTeamAId == null || _selectedTeamBId == null) {
      _errorMessage = 'Both teams must be selected';
      notifyListeners();
      return false;
    }
    if (_selectedDate == null || _selectedTime == null) {
      _errorMessage = 'Date and time are required';
      notifyListeners();
      return false;
    }
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  Future<MatchModel> createMatch() async {
    if (!await validateFields()) throw Exception(_errorMessage);
    final match = await UpcomingGamesActionHandler.createMatch(
      leagueId: _leagueId!,
      leagueFormat: _leagueFormat,
      teamAId: _selectedTeamAId!,
      teamAName: _selectedTeamA!,
      teamBId: _selectedTeamBId!,
      teamBName: _selectedTeamB!,
      date: _selectedDate!,
      time: _selectedTime!,
      venue: _selectedVenue,
      refereeId: _selectedRefereeId,
      statKeeperId: _selectedStatKeeperId,
      roundName: _selectedRoundName,
    );
    notifyListeners();
    return match;
  }

  Future<MatchModel> updateMatch() async {
    if (!await validateFields()) throw Exception(_errorMessage);
    if (_editingMatch == null) throw Exception('No match selected');
    final match = await UpcomingGamesActionHandler.updateMatch(
      matchId: _editingMatch!.id!,
      editingMatch: _editingMatch!,
      teamAId: _selectedTeamAId!,
      teamAName: _selectedTeamA!,
      teamBId: _selectedTeamBId!,
      teamBName: _selectedTeamB!,
      date: _selectedDate!,
      time: _selectedTime!,
      venue: _selectedVenue,
      refereeId: _selectedRefereeId,
      statKeeperId: _selectedStatKeeperId,
      roundName: _selectedRoundName,
      gameNumber: _editingMatch!.gameNumber,
    );
    notifyListeners();
    return match;
  }

  Future<void> saveMatch() async {
    if (_editingMatch != null) {
      await updateMatch();
    } else {
      await createMatch();
    }
  }

  void reset() {
    _editingMatch = null;
    _selectedTeamA = _selectedTeamB = _selectedTeamAId = _selectedTeamBId =
        null;
    _selectedDate = _selectedTime = _selectedVenue = _selectedRefereeId =
        _selectedStatKeeperId = _selectedRoundName = _errorMessage = null;
    notifyListeners();
  }
}

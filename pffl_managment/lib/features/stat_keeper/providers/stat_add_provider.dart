import 'package:flutter/material.dart';
import 'package:pffl_managment/features/stat_keeper/repositories/stat_keeper_repository_fixed.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/stat_keeper/models/player_model.dart';
import 'package:pffl_managment/features/stat_keeper/models/team_model.dart';
import 'package:pffl_managment/features/stat_keeper/providers/stat_stats_provider.dart';

class StatAddProvider extends ChangeNotifier {
  // Match context
  String? _matchId;

  // Selected values
  String? _selectedTeamId;
  String? _selectedPlayerId;

  // Available data
  List<MatchModel> _assignedMatches = [];
  List<StatKeeperTeamModel> _teams = [];
  List<StatKeeperPlayerModel> _players = [];

  // Text controllers for stat inputs
  final TextEditingController catchesController = TextEditingController();
  final TextEditingController catchesYardsController = TextEditingController();
  final TextEditingController rushesController = TextEditingController();
  final TextEditingController rushesYardsController = TextEditingController();
  final TextEditingController passAttemptsController = TextEditingController();
  final TextEditingController passYardsController = TextEditingController();
  final TextEditingController completionsController = TextEditingController();
  final TextEditingController tdsController = TextEditingController();
  final TextEditingController flagPullController = TextEditingController();
  final TextEditingController sackController = TextEditingController();
  final TextEditingController intController = TextEditingController();
  final TextEditingController safetyController = TextEditingController();
  final TextEditingController conversionPointsController =
      TextEditingController();

  // Loading states
  bool _isLoading = false;
  bool _isLoadingMatches = false;
  bool _isLoadingTeams = false;
  bool _isLoadingPlayers = false;

  // Read-only state
  bool _isReadOnly = false;

  // Getters
  String? get selectedMatchId => _matchId;
  String? get selectedTeam => _selectedTeamId;
  String? get selectedPlayer => _selectedPlayerId;
  bool get isLoading => _isLoading;
  bool get isLoadingMatches => _isLoadingMatches;
  bool get isLoadingTeams => _isLoadingTeams;
  bool get isLoadingPlayers => _isLoadingPlayers;
  bool get isReadOnly => _isReadOnly;

  // Computed getters for dropdown data
  List<MatchModel> get assignedMatches => _assignedMatches;
  List<String> get matchOptions => _assignedMatches.map((m) {
    return '${m.homeTeam} vs ${m.awayTeam} (${m.date})';
  }).toList();

  List<String> get teams => _teams.map((team) => team.name).toList();
  List<String> get players => _players.map((player) => player.name).toList();

  void initialize(String? matchId) {
    if (matchId != null) {
      _matchId = matchId;
      _loadSpecificMatch(matchId);
    } else {
      loadAssignedMatches();
    }
  }

  Future<void> _loadSpecificMatch(String matchId) async {
    _isLoadingMatches = true;
    notifyListeners();
    try {
      final matches = await StatKeeperRepositoryFixed.getAssignedMatches();
      _assignedMatches = matches;
      final match = matches.firstWhere((m) => m.id == matchId);
      _isReadOnly = match.status == 'completed';
      loadTeams();
    } catch (e) {
    } finally {
      _isLoadingMatches = false;
      notifyListeners();
    }
  }

  Future<void> loadAssignedMatches() async {
    _isLoadingMatches = true;
    notifyListeners();
    try {
      _assignedMatches = await StatKeeperRepositoryFixed.getAssignedMatches();
    } catch (e) {
      _assignedMatches = [];
    } finally {
      _isLoadingMatches = false;
      notifyListeners();
    }
  }

  void setSelectedMatch(String matchOption) {
    try {
      final match = _assignedMatches.firstWhere(
        (m) => '${m.homeTeam} vs ${m.awayTeam} (${m.date})' == matchOption,
      );
      _matchId = match.id;
      _isReadOnly = match.status == 'completed';
      _selectedTeamId = null;
      _selectedPlayerId = null;
      _teams = [];
      _players = [];
      loadTeams();
      notifyListeners();
    } catch (e) {
    }
  }

  Future<void> loadTeams() async {
    if (_matchId == null) return;
    _isLoadingTeams = true;
    notifyListeners();
    try {
      _teams = await StatKeeperRepositoryFixed.getMatchTeams(_matchId!);
    } catch (e) {
      _teams = [];
    } finally {
      _isLoadingTeams = false;
      notifyListeners();
    }
  }

  Future<void> loadPlayers() async {
    if (_selectedTeamId == null || _matchId == null) {
      _players = [];
      notifyListeners();
      return;
    }
    _isLoadingPlayers = true;
    notifyListeners();
    try {
      final teamPlayers = await StatKeeperRepositoryFixed.getMatchTeamPlayers(
        _matchId!,
        _selectedTeamId!,
      );
      _players = teamPlayers;
    } catch (e) {
      _players = [];
    } finally {
      _isLoadingPlayers = false;
      notifyListeners();
    }
  }

  void setSelectedTeam(String teamName) {
    if (_isReadOnly) return;
    final team = _teams.firstWhere((t) => t.name == teamName);
    _selectedTeamId = team.id;
    _selectedPlayerId = null;
    loadPlayers();
    notifyListeners();
  }

  void setSelectedPlayer(String playerName) {
    if (_isReadOnly) return;
    final player = _players.firstWhere((p) => p.name == playerName);
    _selectedPlayerId = player.id;
    notifyListeners();
  }

  Future<void> updateNow(BuildContext context) async {
    if (_isReadOnly) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot edit stats for an approved/completed match'),
        ),
      );
      return;
    }

    if (_matchId == null || _selectedTeamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a game and a team')),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      final catches = int.tryParse(catchesController.text) ?? 0;
      final catchesYards = int.tryParse(catchesYardsController.text) ?? 0;
      final rushes = int.tryParse(rushesController.text) ?? 0;
      final rushesYards = int.tryParse(rushesYardsController.text) ?? 0;
      final passAttempts = int.tryParse(passAttemptsController.text) ?? 0;
      final passYards = int.tryParse(passYardsController.text) ?? 0;
      final completions = int.tryParse(completionsController.text) ?? 0;
      final tds = int.tryParse(tdsController.text) ?? 0;
      final flagPull = int.tryParse(flagPullController.text) ?? 0;
      final sack = int.tryParse(sackController.text) ?? 0;
      final interceptions = int.tryParse(intController.text) ?? 0;
      final safety = int.tryParse(safetyController.text) ?? 0;
      final conversionPoints =
          int.tryParse(conversionPointsController.text) ?? 0;

      await StatKeeperRepositoryFixed.addMatchStatsFixed(
        matchId: _matchId!,
        teamId: _selectedTeamId!,
        playerId: _selectedPlayerId,
        catches: catches,
        catchesYards: catchesYards,
        rushes: rushes,
        rushesYards: rushesYards,
        passAttempts: passAttempts,
        passYards: passYards,
        completions: completions,
        tds: tds,
        flagPull: flagPull,
        sack: sack,
        interceptions: interceptions,
        safety: safety,
        conversionPoints: conversionPoints,
      );

      // FIX 1: Refresh stats in other providers after successful update
      await _refreshStatsProviders(context);

      clearForm();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stats updated successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating stats: ${e.toString()}')),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh stats providers after adding new stats
  Future<void> _refreshStatsProviders(BuildContext context) async {
    try {
      // Find and refresh StatStatsProvider if it exists in the widget tree
      final statStatsProvider = Provider.of<StatStatsProvider>(
        context,
        listen: false,
      );

      // Force refresh the stats for the current match
      if (_matchId != null) {
        await statStatsProvider.forceRefreshForMatch(_matchId!);
      }
    } catch (e) {
      // StatStatsProvider might not be available in current context
    }
  }

  void clearForm() {
    // Retain selectedTeamId to allow sequential entry for multiple players (Req #1)
    _selectedPlayerId = null;
    _players = [];
    catchesController.text = '0';
    catchesYardsController.text = '0';
    rushesController.text = '0';
    rushesYardsController.text = '0';
    passAttemptsController.text = '0';
    passYardsController.text = '0';
    completionsController.text = '0';
    tdsController.text = '0';
    flagPullController.text = '0';
    sackController.text = '0';
    intController.text = '0';
    safetyController.text = '0';
    conversionPointsController.text = '0';
    notifyListeners();
  }

  bool validateInputs() {
    if (_selectedTeamId == null || _isReadOnly) {
      return false;
    }
    return true; // Simplified for now
  }

  @override
  void dispose() {
    catchesController.dispose();
    catchesYardsController.dispose();
    rushesController.dispose();
    rushesYardsController.dispose();
    passAttemptsController.dispose();
    passYardsController.dispose();
    completionsController.dispose();
    tdsController.dispose();
    flagPullController.dispose();
    sackController.dispose();
    intController.dispose();
    safetyController.dispose();
    conversionPointsController.dispose();
    super.dispose();
  }
}


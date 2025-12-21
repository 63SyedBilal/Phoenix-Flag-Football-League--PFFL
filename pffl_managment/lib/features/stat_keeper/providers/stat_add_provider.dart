import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/stat_keeper/models/player_model.dart';
import 'package:pffl_managment/features/stat_keeper/models/team_model.dart';
import 'package:pffl_managment/features/stat_keeper/providers/stat_stats_provider.dart';
import 'package:pffl_managment/features/stat_keeper/repositories/stat_keeper_repository.dart';

class StatAddProvider extends ChangeNotifier {
  // Match context
  String? _matchId;

  // Selected values
  String? _selectedTeamId;
  String? _selectedPlayerId;

  // Available data
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

  // Loading state
  bool _isLoading = false;
  bool _isLoadingTeams = false;
  bool _isLoadingPlayers = false;

  // Getters
  String? get selectedTeam => _selectedTeamId;
  String? get selectedPlayer => _selectedPlayerId;
  bool get isLoading => _isLoading;
  bool get isLoadingTeams => _isLoadingTeams;
  bool get isLoadingPlayers => _isLoadingPlayers;

  // Computed getters for dropdown data
  List<String> get teams => _teams.map((team) => team.name).toList();
  List<String> get players => _players.map((player) => player.name).toList();

  // Get team ID from selected team name
  String? get selectedTeamId => _selectedTeamId;

  // Get player ID from selected player name
  String? get selectedPlayerId => _selectedPlayerId;

  // Initialize with match ID
  void initialize(String matchId) {
    _matchId = matchId;
    loadTeams();
  }

  Future<void> loadTeams() async {
    if (_matchId == null) return;

    _isLoadingTeams = true;
    notifyListeners();

    try {
      _teams = await StatKeeperRepository.getMatchTeams(_matchId!);
    } catch (e) {
      debugPrint('Error loading teams: $e');
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
      // Get players for the selected team from match data
      final teamPlayers = await StatKeeperRepository.getMatchTeamPlayers(_matchId!, _selectedTeamId!);
      _players = teamPlayers;
    } catch (e) {
      _players = [];
    } finally {
      _isLoadingPlayers = false;
      notifyListeners();
    }
  }


  void setSelectedTeam(String teamName) {
    final team = _teams.firstWhere((t) => t.name == teamName);
    _selectedTeamId = team.id;
    // Reset player when team changes
    _selectedPlayerId = null;
    loadPlayers();
    notifyListeners();
  }

  void setSelectedPlayer(String playerName) {
    final player = _players.firstWhere((p) => p.name == playerName);
    _selectedPlayerId = player.id;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> updateNow(BuildContext context) async {
    if (_matchId == null || _selectedTeamId == null) {
      // Show validation error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a team')),
      );
      return;
    }

    _setLoading(true);
    try {
      // Get stat values
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
      final conversionPoints = int.tryParse(conversionPointsController.text) ?? 0;

      // Get player name if selected
      String? playerName;
      if (_selectedPlayerId != null) {
        final player = _players.firstWhere((p) => p.id == _selectedPlayerId);
        playerName = player.name;
      }

      // Add stats via repository
      final gameStat = await StatKeeperRepository.addMatchStats(
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

      // Add to stats provider for local management
      final statsProvider = Provider.of<StatStatsProvider>(
        context,
        listen: false,
      );
      statsProvider.addDraftStat(gameStat);

      // Clear form
      clearForm();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            _selectedPlayerId != null
                ? 'Stats added to ${playerName ?? 'player'}'
                : 'Stats added to team'
          )),
        );
      }
    } catch (e) {
      debugPrint('Error updating stats: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating stats: ${e.toString()}')),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  void resetToDefault() {
    // Reset all stat inputs to 0
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

  void clearForm() {
    _selectedTeamId = null;
    _selectedPlayerId = null;
    _players = []; // Clear players when team is deselected
    resetToDefault();
    notifyListeners();
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

  // Validation methods
  bool validateInputs() {
    if (_selectedTeamId == null) {
      return false;
    }

    // Check if at least one stat field has a value > 0
    final hasStats = (int.tryParse(catchesController.text) ?? 0) > 0 ||
        (int.tryParse(catchesYardsController.text) ?? 0) > 0 ||
        (int.tryParse(rushesController.text) ?? 0) > 0 ||
        (int.tryParse(rushesYardsController.text) ?? 0) > 0 ||
        (int.tryParse(passAttemptsController.text) ?? 0) > 0 ||
        (int.tryParse(passYardsController.text) ?? 0) > 0 ||
        (int.tryParse(completionsController.text) ?? 0) > 0 ||
        (int.tryParse(tdsController.text) ?? 0) > 0 ||
        (int.tryParse(flagPullController.text) ?? 0) > 0 ||
        (int.tryParse(sackController.text) ?? 0) > 0 ||
        (int.tryParse(intController.text) ?? 0) > 0 ||
        (int.tryParse(safetyController.text) ?? 0) > 0 ||
        (int.tryParse(conversionPointsController.text) ?? 0) > 0;

    return hasStats;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/stat_keeper/models/player_model.dart';
import 'package:pffl_managment/features/stat_keeper/models/team_model.dart';
import 'package:pffl_managment/features/stat_keeper/repositories/stat_keeper_repository_fixed.dart';
import 'package:pffl_managment/features/stat_keeper/providers/stat_stats_provider.dart';

/// Fixed StatAddProvider with proper error handling and API endpoint fixes
class StatAddProviderFixed extends ChangeNotifier {
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

  // Error handling
  String? _errorMessage;
  bool _hasError = false;

  // Getters
  String? get selectedMatchId => _matchId;
  String? get selectedTeam => _selectedTeamId;
  String? get selectedPlayer => _selectedPlayerId;
  bool get isLoading => _isLoading;
  bool get isLoadingMatches => _isLoadingMatches;
  bool get isLoadingTeams => _isLoadingTeams;
  bool get isLoadingPlayers => _isLoadingPlayers;
  bool get isReadOnly => _isReadOnly;
  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;

  // Computed getters for dropdown data
  List<MatchModel> get assignedMatches => _assignedMatches;
  List<String> get matchOptions => _assignedMatches.map((m) {
    return '${m.homeTeam} vs ${m.awayTeam} (${m.date})';
  }).toList();

  List<String> get teams => _teams.map((team) => team.name).toList();
  List<String> get players => _players.map((player) => player.name).toList();

  void initialize(String? matchId) {
    _clearError();
    if (matchId != null) {
      _matchId = matchId;
      _loadSpecificMatch(matchId);
    } else {
      loadAssignedMatches();
    }
  }

  void _clearError() {
    _errorMessage = null;
    _hasError = false;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _hasError = true;
    notifyListeners();
  }

  Future<void> _loadSpecificMatch(String matchId) async {
    _isLoadingMatches = true;
    _clearError();
    notifyListeners();

    try {
      final matches = await StatKeeperRepositoryFixed.getAssignedMatches();
      _assignedMatches = matches;
      final match = matches.firstWhere((m) => m.id == matchId);
      _isReadOnly = match.status == 'completed';
      loadTeams();
    } catch (e) {
      debugPrint('Error loading specific match: $e');
      _setError('Failed to load match details: ${e.toString()}');
    } finally {
      _isLoadingMatches = false;
      notifyListeners();
    }
  }

  Future<void> loadAssignedMatches() async {
    _isLoadingMatches = true;
    _clearError();
    notifyListeners();

    try {
      _assignedMatches = await StatKeeperRepositoryFixed.getAssignedMatches();
    } catch (e) {
      debugPrint('Error loading assigned matches: $e');
      _assignedMatches = [];
      _setError('Failed to load assigned matches: ${e.toString()}');
    } finally {
      _isLoadingMatches = false;
      notifyListeners();
    }
  }

  void setSelectedMatch(String matchOption) {
    try {
      _clearError();
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
      debugPrint('Error selecting match: $e');
      _setError('Failed to select match: ${e.toString()}');
    }
  }

  Future<void> loadTeams() async {
    if (_matchId == null) return;

    _isLoadingTeams = true;
    _clearError();
    notifyListeners();

    try {
      _teams = await StatKeeperRepositoryFixed.getMatchTeams(_matchId!);
    } catch (e) {
      debugPrint('Error loading teams: $e');
      _teams = [];
      _setError('Failed to load teams: ${e.toString()}');
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
    _clearError();
    notifyListeners();

    try {
      final teamPlayers = await StatKeeperRepositoryFixed.getMatchTeamPlayers(
        _matchId!,
        _selectedTeamId!,
      );
      _players = teamPlayers;
    } catch (e) {
      _players = [];
      _setError('Failed to load players: ${e.toString()}');
    } finally {
      _isLoadingPlayers = false;
      notifyListeners();
    }
  }

  void setSelectedTeam(String teamName) {
    if (_isReadOnly) return;

    try {
      _clearError();
      final team = _teams.firstWhere((t) => t.name == teamName);
      _selectedTeamId = team.id;
      _selectedPlayerId = null;
      loadPlayers();
      notifyListeners();
    } catch (e) {
      debugPrint('Error selecting team: $e');
      _setError('Failed to select team: ${e.toString()}');
    }
  }

  void setSelectedPlayer(String playerName) {
    if (_isReadOnly) return;

    try {
      _clearError();
      final player = _players.firstWhere((p) => p.name == playerName);
      _selectedPlayerId = player.id;
      notifyListeners();
    } catch (e) {
      debugPrint('Error selecting player: $e');
      _setError('Failed to select player: ${e.toString()}');
    }
  }

  /// FIXED: Enhanced updateNow with comprehensive error handling
  Future<void> updateNowFixed(BuildContext context) async {
    if (_isReadOnly) {
      _showErrorSnackBar(
        context,
        'Cannot edit stats for an approved/completed match',
      );
      return;
    }

    // Validate inputs
    final validationError = _validateInputs();
    if (validationError != null) {
      _showErrorSnackBar(context, validationError);
      return;
    }

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      // Parse input values with validation
      final statsData = _parseStatsFromInputs();

      print('📊 [UPDATE STATS DEBUG] Starting stats update...');
      print('📊 [UPDATE STATS DEBUG] Match ID: $_matchId');
      print('📊 [UPDATE STATS DEBUG] Team ID: $_selectedTeamId');
      print('📊 [UPDATE STATS DEBUG] Player ID: $_selectedPlayerId');
      print('📊 [UPDATE STATS DEBUG] Stats: $statsData');

      await StatKeeperRepositoryFixed.addMatchStatsFixed(
        matchId: _matchId!,
        teamId: _selectedTeamId!,
        playerId: _selectedPlayerId,
        catches: statsData['catches']!,
        catchesYards: statsData['catchesYards']!,
        rushes: statsData['rushes']!,
        rushesYards: statsData['rushesYards']!,
        passAttempts: statsData['passAttempts']!,
        passYards: statsData['passYards']!,
        completions: statsData['completions']!,
        tds: statsData['tds']!,
        flagPull: statsData['flagPull']!,
        sack: statsData['sack']!,
        interceptions: statsData['interceptions']!,
        safety: statsData['safety']!,
        conversionPoints: statsData['conversionPoints']!,
      );

      // Refresh other providers after successful update
      await _refreshStatsProviders(context);

      clearForm();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Stats updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      print('✅ [UPDATE STATS DEBUG] Stats update completed successfully');
    } catch (e) {
      final errorMessage = 'Failed to update stats: ${e.toString()}';
      debugPrint('❌ [UPDATE STATS DEBUG] Error: $errorMessage');

      _setError(errorMessage);

      if (context.mounted) {
        _showErrorSnackBar(context, errorMessage);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? _validateInputs() {
    if (_matchId == null || _matchId!.isEmpty) {
      return 'Please select a game';
    }

    if (_selectedTeamId == null || _selectedTeamId!.isEmpty) {
      return 'Please select a team';
    }

    if (_selectedPlayerId == null || _selectedPlayerId!.isEmpty) {
      return 'Please select a player';
    }

    if (_isReadOnly) {
      return 'Cannot edit stats for completed matches';
    }

    return null; // No validation errors
  }

  Map<String, int> _parseStatsFromInputs() {
    return {
      'catches': int.tryParse(catchesController.text) ?? 0,
      'catchesYards': int.tryParse(catchesYardsController.text) ?? 0,
      'rushes': int.tryParse(rushesController.text) ?? 0,
      'rushesYards': int.tryParse(rushesYardsController.text) ?? 0,
      'passAttempts': int.tryParse(passAttemptsController.text) ?? 0,
      'passYards': int.tryParse(passYardsController.text) ?? 0,
      'completions': int.tryParse(completionsController.text) ?? 0,
      'tds': int.tryParse(tdsController.text) ?? 0,
      'flagPull': int.tryParse(flagPullController.text) ?? 0,
      'sack': int.tryParse(sackController.text) ?? 0,
      'interceptions': int.tryParse(intController.text) ?? 0,
      'safety': int.tryParse(safetyController.text) ?? 0,
      'conversionPoints': int.tryParse(conversionPointsController.text) ?? 0,
    };
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $message'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Refresh stats providers after adding new stats
  Future<void> _refreshStatsProviders(BuildContext context) async {
    try {
      final statStatsProvider = Provider.of<StatStatsProvider>(
        context,
        listen: false,
      );

      if (_matchId != null) {
        await statStatsProvider.forceRefreshForMatch(_matchId!);
      }
    } catch (e) {
      debugPrint('StatStatsProvider not available for refresh: $e');
    }
  }

  void clearForm() {
    // Retain selectedTeamId to allow sequential entry for multiple players
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
    _clearError();
    notifyListeners();
  }

  bool validateInputs() {
    return _validateInputs() == null;
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

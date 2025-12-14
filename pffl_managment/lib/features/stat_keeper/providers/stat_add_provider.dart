import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/stat_keeper_navigation_provider.dart';
import 'package:pffl_managment/features/stat_keeper/models/game_stat_model.dart';
import 'package:pffl_managment/features/stat_keeper/models/team_stat_model.dart';
import 'package:pffl_managment/features/stat_keeper/providers/stat_stats_provider.dart';

class StatAddProvider extends ChangeNotifier {
  // Selected values
  String? _selectedTeam;
  String? _selectedPlayer;

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

  // Mock data for dropdowns
  final List<String> teams = [
    'Team Alpha',
    'Team Beta',
    'Team Gamma',
    'Team Delta',
  ];

  final List<String> players = [
    'John Doe',
    'Jane Smith',
    'Mike Johnson',
    'Sarah Williams',
  ];

  // Getters
  String? get selectedTeam => _selectedTeam;
  String? get selectedPlayer => _selectedPlayer;
  bool get isLoading => _isLoading;

  void setSelectedTeam(String team) {
    _selectedTeam = team;
    // Reset player when team changes
    _selectedPlayer = null;
    notifyListeners();
  }

  void setSelectedPlayer(String player) {
    _selectedPlayer = player;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> saveAsDraft(BuildContext context) async {
    _setLoading(true);
    try {
      final statsProvider = Provider.of<StatStatsProvider>(
        context,
        listen: false,
      );
      final navigationProvider = Provider.of<StatKeeperNavigationProvider>(
        context,
        listen: false,
      );

      // Create stat model
      final newStat = GameStatModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        leagueName: 'New League Game',
        team1Name: _selectedTeam ?? 'Team A',
        team1Logo: 'assets/images/image 13.png',
        team2Name: 'Opponent',
        team2Logo: 'assets/images/image 14.png',
        date: DateTime.now(),
        time: '12:00 PM',
        status: StatStatus.draft,
        team1Stats: TeamStatModel(
          teamName: _selectedTeam ?? 'Team A',
          teamLogo: 'assets/images/image 13.png',
          catches: int.tryParse(catchesController.text) ?? 0,
          catchesYards: int.tryParse(catchesYardsController.text) ?? 0,
          rushes: int.tryParse(rushesController.text) ?? 0,
          rushesYards: int.tryParse(rushesYardsController.text) ?? 0,
          passAttempts: int.tryParse(passAttemptsController.text) ?? 0,
          passYards: int.tryParse(passYardsController.text) ?? 0,
          completions: int.tryParse(completionsController.text) ?? 0,
          tds: int.tryParse(tdsController.text) ?? 0,
          flagPull: int.tryParse(flagPullController.text) ?? 0,
          sack: int.tryParse(sackController.text) ?? 0,
          interceptions: int.tryParse(intController.text) ?? 0,
          safety: int.tryParse(safetyController.text) ?? 0,
          conversionPoints: int.tryParse(conversionPointsController.text) ?? 0,
        ),
        team2Stats: TeamStatModel(
          teamName: 'Opponent',
          teamLogo: 'assets/images/image 14.png',
        ),
      );

      // Add to stats provider
      statsProvider.addDraftStat(newStat);

      // Clear form
      clearForm();

      // Navigate to Stats tab (index 3) and set sub-tab to Drafts (index 1)
      navigationProvider.setIndex(3);
      statsProvider.setTabIndex(1);
    } catch (e) {
      debugPrint('Error saving stat: $e');
    } finally {
      _setLoading(false);
    }
  }

  void clearForm() {
    _selectedTeam = null;
    _selectedPlayer = null;
    catchesController.clear();
    catchesYardsController.clear();
    rushesController.clear();
    rushesYardsController.clear();
    passAttemptsController.clear();
    passYardsController.clear();
    completionsController.clear();
    tdsController.clear();
    flagPullController.clear();
    sackController.clear();
    intController.clear();
    safetyController.clear();
    conversionPointsController.clear();
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
}

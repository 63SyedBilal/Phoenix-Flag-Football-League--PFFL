import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_detail_models.dart';

class LeagueDetailProvider extends ChangeNotifier {
  int _selectedTabIndex = 0;
  LeagueGameModel? _editingGame;
  bool _isEditing = false;
  
  // Team expansion state
  final Map<String, bool> _teamExpansionState = {};

  int get selectedTabIndex => _selectedTabIndex;
  LeagueGameModel? get editingGame => _editingGame;
  bool get isEditing => _isEditing;

  void selectTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void startEditingGame(LeagueGameModel game) {
    _editingGame = game;
    _isEditing = true;
    notifyListeners();
  }

  void stopEditingGame() {
    _editingGame = null;
    _isEditing = false;
    notifyListeners();
  }

  void updateEditingGame(LeagueGameModel updatedGame) {
    _editingGame = updatedGame;
    notifyListeners();
  }
  
  bool isTeamExpanded(String teamId) {
    return _teamExpansionState[teamId] ?? false;
  }

  void toggleTeamExpansion(String teamId) {
    _teamExpansionState[teamId] = !(_teamExpansionState[teamId] ?? false);
    notifyListeners();
  }

  // Mock data for upcoming games
  List<LeagueGameModel> getUpcomingGames() {
    return [
      LeagueGameModel(
        id: '1',
        team1Name: 'RC',
        team1Logo: '',
        team2Name: 'STA',
        team2Logo: '',
        gameDateTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
      ),
      LeagueGameModel(
        id: '2',
        team1Name: 'GEO',
        team1Logo: '',
        team2Name: 'STB',
        team2Logo: '',
        gameDateTime: DateTime.now().add(const Duration(days: 2, hours: 2)),
      ),
      LeagueGameModel(
        id: '3',
        team1Name: 'RC',
        team1Logo: '',
        team2Name: 'STA',
        team2Logo: '',
        gameDateTime: DateTime.now().add(const Duration(days: 3, hours: 3)),
      ),
    ];
  }

  // Mock data for leaderboard
  List<LeagueTeamStandingModel> getLeaderboard() {
    return [
      LeagueTeamStandingModel(
        rank: 1,
        teamName: 'Shadow Wolves',
        teamLogo: '',
        wins: 6,
        draws: 0,
        losses: 0,
      ),
      LeagueTeamStandingModel(
        rank: 2,
        teamName: 'Iron Rangers',
        teamLogo: '',
        wins: 4,
        draws: 0,
        losses: 2,
      ),
      LeagueTeamStandingModel(
        rank: 3,
        teamName: 'Metro Kings',
        teamLogo: '',
        wins: 2,
        draws: 0,
        losses: 4,
      ),
      LeagueTeamStandingModel(
        rank: 4,
        teamName: 'Blaze Squad',
        teamLogo: '',
        wins: 0,
        draws: 0,
        losses: 6,
      ),
      LeagueTeamStandingModel(
        rank: 5,
        teamName: 'Metro Kings',
        teamLogo: '',
        wins: 0,
        draws: 0,
        losses: 6,
      ),
      LeagueTeamStandingModel(
        rank: 6,
        teamName: 'Iron Rangers',
        teamLogo: '',
        wins: 4,
        draws: 0,
        losses: 2,
      ),
    ];
  }

  // Mock data for key players
  List<LeagueKeyPlayerModel> getKeyPlayers() {
    return [
      LeagueKeyPlayerModel(
        id: '1',
        name: 'Andrew Brooks',
        avatarUrl: '',
        statValue: 12,
        statLabel: 'TDs',
        gradientStart: const Color(0xFF1E3A8A), // Dark blue
        gradientEnd: const Color(0xFF3B82F6),
      ),
      LeagueKeyPlayerModel(
        id: '2',
        name: 'Malik Carter',
        avatarUrl: '',
        statValue: 9,
        statLabel: 'TDs',
        gradientStart: const Color(0xFF1E293B), // Dark navy/black
        gradientEnd: const Color(0xFF334155),
      ),
    ];
  }

  // Mock data for team stats
  List<LeagueTeamStatModel> getTeamStats() {
    return [
      LeagueTeamStatModel(
        teamName: 'Shadow Wolves',
        teamLogo: '',
        statValue: '266',
        statLabel: 'PS',
        backgroundColor: const Color(0xFF4C1D95),
      ),
      LeagueTeamStatModel(
        teamName: 'Iron Rangers',
        teamLogo: '',
        statValue: '284',
        statLabel: 'PS',
        backgroundColor: const Color(0xFF7F1D1D),
      ),
    ];
  }
}
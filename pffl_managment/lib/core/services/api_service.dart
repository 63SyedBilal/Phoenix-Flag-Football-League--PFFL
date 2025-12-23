import 'dart:math';
import 'package:pffl_managment/core/models/game_model.dart';

class ApiService {
  // Singleton instance
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Simulate network delay
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1000)));
  }

  // Get upcoming matches for a user
  Future<List<GameModel>> getUpcomingMatches(String userId, String userRole) async {
    await _simulateNetworkDelay();
    
    // Generate mock data based on user role
    return _generateMockMatches(userRole);
  }

  // Get "My Games" for a user
  Future<List<GameModel>> getMyGames(String userId, String userRole) async {
    await _simulateNetworkDelay();
    
    // Filter mock data to show only user's games
    final allMatches = _generateMockMatches(userRole);
    return allMatches.where((match) => match.isMyGame).toList();
  }

  // Generate mock match data with 10 teams
  List<GameModel> _generateMockMatches(String userRole) {
    // Team names for a 10-team league
    final teamNames = ['Eagles', 'Falcons', 'Hawks', 'Ravens', 'Wolves', 'Lions', 'Tigers', 'Bears', 'Panthers', 'Jaguars'];
    final leagueNames = ['Premier League', 'Championship Cup', 'Elite Tournament', 'Grand Prix', 'Super Bowl'];
    
    // Generate 10 matches
    List<GameModel> matches = [];
    final random = Random();
    
    for (int i = 0; i < 10; i++) {
      final team1Index = random.nextInt(teamNames.length);
      int team2Index;
      do {
        team2Index = random.nextInt(teamNames.length);
      } while (team2Index == team1Index);
      
      final leagueName = leagueNames[random.nextInt(leagueNames.length)];
      
      matches.add(
        GameModel(
          id: '${i + 1}',
          leagueName: leagueName,
          team1Name: teamNames[team1Index].substring(0, 2).toUpperCase(),
          team1Logo: 'assets/images/image 12.png',
          team2Name: teamNames[team2Index].substring(0, 2).toUpperCase(),
          team2Logo: 'assets/images/image 14.png',
          date: DateTime(2025, 12, 5 + i),
          time: '${(random.nextInt(12) + 1).toString().padLeft(2, '0')}:${(random.nextInt(60)).toString().padLeft(2, '0')} ${random.nextBool() ? 'AM' : 'PM'} PKT',
          isFeePaid: random.nextBool(),
          isMyGame: _isMyGame(userRole, i),
        ),
      );
    }
    
    return matches;
  }
  
  // Determine if a match is the user's game based on role and index
  bool _isMyGame(String userRole, int index) {
    switch (userRole) {
      case 'player':
      case 'captain':
        return index % 3 == 0; // Every 3rd game is user's game
      case 'referee':
      case 'statkeeper':
        return index % 4 == 0; // Every 4th game is user's game
      case 'freeagent':
        return index % 5 == 0; // Every 5th game is user's game
      default:
        return false;
    }
  }

  // Refresh matches (simulates pull-to-refresh)
  Future<List<GameModel>> refreshMatches(String userId, String userRole) async {
    await _simulateNetworkDelay();
    return _generateMockMatches(userRole);
  }
}

import 'package:flutter/material.dart';
import '../model/game_model.dart';

class CaptainGamesProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime(
    2025,
    2,
    12,
  ); // Default to one of the dates in the design

  // Mock data to match the design
  final List<GameModel> _allGames = [
    GameModel(
      id: '1',
      leagueName: 'The Rugby Championship',
      team1Name: 'RC',
      team1Logo: 'assets/images/team_rc.png', // Placeholder
      team2Name: 'STA',
      team2Logo: 'assets/images/team_sta.png', // Placeholder
      date: DateTime(2025, 2, 12),
      time: '01:05 AM PKT',
      isFeePaid: false,
      isMyGame: true,
    ),
    GameModel(
      id: '2',
      leagueName: 'Six Nations',
      team1Name: 'GEO',
      team1Logo: 'assets/images/team_geo.png', // Placeholder
      team2Name: 'STB',
      team2Logo: 'assets/images/team_stb.png', // Placeholder
      date: DateTime(2025, 2, 12),
      time: '02:15 AM PKT',
      isFeePaid: true, // Fee paid, so no button
      isMyGame: false,
    ),
    GameModel(
      id: '3',
      leagueName: 'The Rugby Championship',
      team1Name: 'RC',
      team1Logo: 'assets/images/team_rc.png', // Placeholder
      team2Name: 'STA',
      team2Logo: 'assets/images/team_sta.png', // Placeholder
      date: DateTime(2025, 2, 12),
      time: '01:05 AM PKT',
      isFeePaid: false,
      isMyGame: true,
    ),
    GameModel(
      id: '4',
      leagueName: 'European League',
      team1Name: 'EL',
      team1Logo: 'assets/images/team_el.png', // Placeholder
      team2Name: 'STD',
      team2Logo: 'assets/images/team_std.png', // Placeholder
      date: DateTime(2025, 2, 12),
      time: '04:45 AM PKT',
      isFeePaid: true,
      isMyGame: false,
    ),
  ];

  DateTime get selectedDate => _selectedDate;

  List<GameModel> get games {
    return _allGames.where((game) {
      return game.date.year == _selectedDate.year &&
          game.date.month == _selectedDate.month &&
          game.date.day == _selectedDate.day;
    }).toList();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void payLeagueFee(String gameId) {
    // Find the game and mark as paid (mock logic)
    final index = _allGames.indexWhere((g) => g.id == gameId);
    if (index != -1) {
      // Create a copy with updated status since fields are final
      final game = _allGames[index];
      _allGames[index] = GameModel(
        id: game.id,
        leagueName: game.leagueName,
        team1Name: game.team1Name,
        team1Logo: game.team1Logo,
        team2Name: game.team2Name,
        team2Logo: game.team2Logo,
        date: game.date,
        time: game.time,
        isFeePaid: true,
        isMyGame: game.isMyGame,
      );
      notifyListeners();
    }
  }
}

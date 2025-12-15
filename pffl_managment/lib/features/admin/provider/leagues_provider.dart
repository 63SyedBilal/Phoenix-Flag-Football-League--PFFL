import 'package:flutter/foundation.dart';
import 'package:pffl_managment/core/models/league_model.dart';

class LeaguesProvider extends ChangeNotifier {
  String _selectedLeague = 'The Rugby Championship';
  bool _hasNotifications = true;

  String get selectedLeague => _selectedLeague;
  bool get hasNotifications => _hasNotifications;

  // Available leagues
  List<LeagueModel> get leagues => [
    LeagueModel(id: '1', name: 'The Rugby Championship'),
    LeagueModel(id: '2', name: 'Six Nations'),
    LeagueModel(id: '3', name: 'Rugby World Cup'),
    LeagueModel(id: '4', name: 'Super Rugby'),
  ];

  // Matches for selected league
  List<LeagueMatchModel> get matches {
    return [
      LeagueMatchModel(
        matchType: 'Final - Match 12 of 12',
        date: 'Thu 31 Oct',
        homeTeam: TeamModel(
          name: 'Argentina',
          flagUrl: 'https://flagcdn.com/w320/ar.png',
          score: 27,
          isWinner: false,
        ),
        awayTeam: TeamModel(
          name: 'South Africa',
          flagUrl: 'https://flagcdn.com/w320/za.png',
          score: 29,
          isWinner: true,
        ),
      ),
      LeagueMatchModel(
        matchType: 'Quarter - Final - Match 10 of 12',
        date: 'Sun 29 Oct',
        homeTeam: TeamModel(
          name: 'Argentina',
          flagUrl: 'https://flagcdn.com/w320/ar.png',
          score: 30,
          isWinner: false,
        ),
        awayTeam: TeamModel(
          name: 'South Africa',
          flagUrl: 'https://flagcdn.com/w320/za.png',
          score: 31,
          isWinner: true,
        ),
      ),
      LeagueMatchModel(
        matchType: 'Semi - Final - Match 8 of 12',
        date: 'Sat 28 Oct',
        homeTeam: TeamModel(
          name: 'New Zealand',
          flagUrl: 'https://flagcdn.com/w320/nz.png',
          score: 25,
          isWinner: false,
        ),
        awayTeam: TeamModel(
          name: 'England',
          flagUrl: 'https://flagcdn.com/w320/gb-eng.png',
          score: 27,
          isWinner: true,
        ),
      ),
    ];
  }

  void selectLeague(String leagueName) {
    _selectedLeague = leagueName;
    notifyListeners();
  }

  void toggleNotifications() {
    _hasNotifications = !_hasNotifications;
    notifyListeners();
  }

  void loadMoreMatches() {
    debugPrint('Loading more matches...');
    // Add logic to load more matches
  }
}

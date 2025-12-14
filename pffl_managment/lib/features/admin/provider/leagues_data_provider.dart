import 'package:flutter/foundation.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';

class EnhancedLeaguesProvider extends ChangeNotifier {
  // Store created leagues
  List<LeagueCreationModel> _createdLeagues = [];
  
  // Selected league for detail view
  String _selectedLeague = 'The Rugby Championship';
  bool _hasNotifications = true;

  // Getters
  List<LeagueCreationModel> get createdLeagues => _createdLeagues;
  String get selectedLeague => _selectedLeague;
  bool get hasNotifications => _hasNotifications;
  int get leaguesCount => _createdLeagues.length;

  // Add a newly created league
  void addLeague(LeagueCreationModel leagueCreation) {
    _createdLeagues.add(leagueCreation);
    notifyListeners();
  }

  // Select a league
  void selectLeague(String leagueName) {
    _selectedLeague = leagueName;
    notifyListeners();
  }

  // Toggle notifications
  void toggleNotifications() {
    _hasNotifications = !_hasNotifications;
    notifyListeners();
  }

  // Load more matches (fake service)
  void loadMoreMatches() {
    debugPrint('Loading more matches...');
    // Add logic to load more matches
  }
}
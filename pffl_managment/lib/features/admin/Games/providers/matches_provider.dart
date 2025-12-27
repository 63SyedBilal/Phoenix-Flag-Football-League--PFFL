import 'package:flutter/foundation.dart';
import 'package:pffl_managment/core/models/filter_model.dart';
import 'package:pffl_managment/features/admin/Games/models/match_model.dart';

class MatchesProvider extends ChangeNotifier {
  String _selectedFilter = 'all';
  bool _hasNotifications = true;
  DateTime? _selectedDate;

  String get selectedFilter => _selectedFilter;
  bool get hasNotifications => _hasNotifications;
  DateTime? get selectedDate => _selectedDate;

  // Filter options
  List<FilterModel> get filters => [
    FilterModel(id: 'all', label: 'All Matches'),
    FilterModel(id: 'six_nations', label: 'Six Nations'),
    FilterModel(id: 'world_cup', label: 'Rugby World Cup'),
    FilterModel(id: 'super_rugby', label: 'Super Rugby'),
  ];

  // All matches data
  List<MatchModel> get allMatches => [
    MatchModel(
      leagueName: 'The Rugby Championship',
      homeTeam: 'RC',
      homeTeamLogo:
          'https://api.dicebear.com/7.x/shapes/png?seed=RC&backgroundColor=db1f35',
      awayTeam: 'STA',
      awayTeamLogo:
          'https://api.dicebear.com/7.x/shapes/png?seed=STA&backgroundColor=f59e0b',
      date: '08/11',
      time: '01:05 AM PKT',
    ),
    MatchModel(
      leagueName: 'Six Nations',
      homeTeam: 'GEO',
      homeTeamLogo:
          'https://api.dicebear.com/7.x/shapes/png?seed=GEO&backgroundColor=3b82f6',
      awayTeam: 'STB',
      awayTeamLogo:
          'https://api.dicebear.com/7.x/shapes/png?seed=STB&backgroundColor=10b981',
      date: '08/11',
      time: '02:15 AM PKT',
    ),
    MatchModel(
      leagueName: 'World Cup Qualifiers',
      homeTeam: 'WQ',
      homeTeamLogo:
          'https://api.dicebear.com/7.x/shapes/png?seed=WQ&backgroundColor=db1f35',
      awayTeam: 'STC',
      awayTeamLogo:
          'https://api.dicebear.com/7.x/shapes/png?seed=STC&backgroundColor=f59e0b',
      date: '08/11',
      time: '03:30 AM PKT',
    ),
    MatchModel(
      leagueName: 'European League',
      homeTeam: 'EL',
      homeTeamLogo:
          'https://api.dicebear.com/7.x/shapes/png?seed=EL&backgroundColor=3b82f6',
      awayTeam: 'STD',
      awayTeamLogo:
          'https://api.dicebear.com/7.x/shapes/png?seed=STD&backgroundColor=10b981',
      date: '09/11',
      time: '04:45 AM PKT',
    ),
    MatchModel(
      leagueName: 'Champions Cup',
      homeTeam: 'CC',
      homeTeamLogo:
          'https://api.dicebear.com/7.x/shapes/png?seed=CC&backgroundColor=db1f35',
      awayTeam: 'STE',
      awayTeamLogo:
          'https://api.dicebear.com/7.x/shapes/png?seed=STE&backgroundColor=f59e0b',
      date: '09/11',
      time: '05:00 AM PKT',
    ),
    MatchModel(
      leagueName: 'International Test Match',
      homeTeam: 'ITM',
      homeTeamLogo:
          'https://api.dicebear.com/7.x/shapes/png?seed=ITM&backgroundColor=3b82f6',
      awayTeam: 'STF',
      awayTeamLogo:
          'https://api.dicebear.com/7.x/shapes/png?seed=STF&backgroundColor=10b981',
      date: '10/11',
      time: '06:00 AM PKT',
    ),
  ];

  // Filtered matches based on selected filter and date
  List<MatchModel> get filteredMatches {
    List<MatchModel> matches = allMatches;

    // Apply league filter
    if (_selectedFilter != 'all') {
      if (_selectedFilter == 'six_nations') {
        matches = matches
            .where((match) => match.leagueName.contains('Six Nations'))
            .toList();
      } else if (_selectedFilter == 'world_cup') {
        matches = matches
            .where((match) => match.leagueName.contains('World Cup'))
            .toList();
      } else if (_selectedFilter == 'super_rugby') {
        matches = matches
            .where(
              (match) =>
                  match.leagueName.contains('Super Rugby') ||
                  match.leagueName.contains('Rugby Championship'),
            )
            .toList();
      }
    }

    // Apply date filter
    if (_selectedDate != null) {
      final formattedDate =
          '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}';
      matches = matches.where((match) => match.date == formattedDate).toList();
    }

    return matches;
  }

  void selectFilter(String filterId) {
    _selectedFilter = filterId;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void toggleNotifications() {
    _hasNotifications = !_hasNotifications;
    notifyListeners();
  }
}

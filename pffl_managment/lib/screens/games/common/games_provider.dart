import 'package:flutter/foundation.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:intl/intl.dart';

/// Provider for managing games screen state with role-based filtering
class GamesProvider extends ChangeNotifier {
  final String userRole;
  String _selectedFilter = 'all';

  // Captain-specific properties
  final String? assignedLeague;
  final bool isLeagueFeeUnpaid;

  GamesProvider({
    required this.userRole,
    this.assignedLeague,
    this.isLeagueFeeUnpaid = false,
  });

  String get selectedFilter => _selectedFilter;

  /// Get available filters based on user role
  List<Map<String, String>> get availableFilters {
    if (userRole == 'admin') {
      // Admin sees league filters
      return [
        {'id': 'all', 'label': 'All Games'},
        {'id': 'six_nations', 'label': 'Six Nations'},
        {'id': 'world_cup', 'label': 'Rugby World Cup'},
        {'id': 'super_rugby', 'label': 'Super Rugby'},
      ];
    } else {
      // Other roles see date filters
      return _getDateFilters();
    }
  }

  /// Generate date filters from available matches
  List<Map<String, String>> _getDateFilters() {
    final dates = <String>{};
    for (var match in allMatches) {
      dates.add(match.date);
    }

    final sortedDates = dates.toList()..sort();
    final filters = <Map<String, String>>[
      {'id': 'all', 'label': 'All'},
    ];

    for (var date in sortedDates) {
      // Convert date format from "08/11" to "February 12"
      try {
        final parts = date.split('/');
        if (parts.length == 2) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final dateObj = DateTime(DateTime.now().year, month, day);
          final formattedDate = DateFormat('MMMM d').format(dateObj);
          filters.add({'id': date, 'label': formattedDate});
        }
      } catch (e) {
        // If parsing fails, use original date
        filters.add({'id': date, 'label': date});
      }
    }

    return filters;
  }

  /// All matches data (mock data for now)
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

  /// Get filtered matches based on selected filter and user role
  List<MatchModel> get filteredMatches {
    if (_selectedFilter == 'all') {
      // For stat keeper and referee roles, show only assigned games
      if (userRole == 'stat keeper') {
        return allMatches.where((match) => _isAssignedToStatKeeper(match)).toList();
      } else if (userRole == 'referee') {
        return allMatches.where((match) => _isAssignedToReferee(match)).toList();
      }
      return allMatches;
    }

    if (userRole == 'admin') {
      // Admin filters by league
      return _filterByLeague(_selectedFilter);
    } else {
      // Other roles filter by date
      return _filterByDate(_selectedFilter);
    }
  }

  /// Check if a match is assigned to the current stat keeper
  bool _isAssignedToStatKeeper(MatchModel match) {
    // In a real implementation, this would check against actual stat keeper assignments
    // For now, we'll simulate by checking specific conditions
    return match.leagueName.contains('Rugby Championship') || 
           match.leagueName.contains('Six Nations');
  }

  /// Check if a match is assigned to the current referee
  bool _isAssignedToReferee(MatchModel match) {
    // In a real implementation, this would check against actual referee assignments
    // For now, we'll simulate by checking specific conditions
    return match.leagueName.contains('World Cup') || 
           match.leagueName.contains('European League');
  }

  List<MatchModel> _filterByLeague(String leagueId) {
    switch (leagueId) {
      case 'six_nations':
        return allMatches
            .where((match) => match.leagueName.contains('Six Nations'))
            .toList();
      case 'world_cup':
        return allMatches
            .where((match) => match.leagueName.contains('World Cup'))
            .toList();
      case 'super_rugby':
        return allMatches
            .where(
              (match) =>
                  match.leagueName.contains('Super Rugby') ||
                  match.leagueName.contains('Rugby Championship'),
            )
            .toList();
      default:
        return allMatches;
    }
  }

  List<MatchModel> _filterByDate(String date) {
    return allMatches.where((match) => match.date == date).toList();
  }

  void selectFilter(String filterId) {
    _selectedFilter = filterId;
    notifyListeners();
  }

  /// Check if user can edit games
  bool get canEdit {
    return userRole == 'admin' || userRole == 'captain';
  }

  /// Check if should show payment prompt (Captain with unpaid fee)
  bool get shouldShowPaymentPrompt {
    return userRole == 'captain' && isLeagueFeeUnpaid;
  }
}
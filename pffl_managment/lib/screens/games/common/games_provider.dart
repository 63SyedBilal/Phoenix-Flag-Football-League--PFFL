import 'package:flutter/foundation.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/core/services/league_service.dart' show LeagueService, LeagueModel;
import 'package:intl/intl.dart';

/// Provider for managing games screen state with role-based filtering
class GamesProvider extends ChangeNotifier {
  final String userRole;
  String _selectedFilter = 'all';

  // Captain-specific properties
  final String? assignedLeague;
  final bool isLeagueFeeUnpaid;

  // State management
  List<LeagueModel> _leagues = [];
  List<MatchModel> _allMatches = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedTeamId;
  
  // Helper method to safely notify listeners
  void _safeNotifyListeners() {
    if (!hasListeners) return; // Check if disposed
    try {
      notifyListeners();
    } catch (e) {
      // Provider was disposed, ignore
      debugPrint('GamesProvider: Cannot notify listeners (disposed)');
    }
  }

  GamesProvider({
    required this.userRole,
    this.assignedLeague,
    this.isLeagueFeeUnpaid = false,
  });

  // Getters
  String get selectedFilter => _selectedFilter;
  List<LeagueModel> get leagues => List.unmodifiable(_leagues);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedTeamId => _selectedTeamId;

  /// Get available filters based on user role
  List<Map<String, String>> get availableFilters {
    if (userRole == 'admin') {
      // Admin sees league filters - dynamically generated from fetched leagues
      final filters = <Map<String, String>>[
        {'id': 'all', 'label': 'All Games'},
      ];
      
      // Add filters for each league
      for (var league in _leagues) {
        filters.add({
          'id': league.id,
          'label': league.leagueName,
        });
      }
      
      return filters;
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

  /// All matches data - fetched from backend
  List<MatchModel> get allMatches => List.unmodifiable(_allMatches);

  /// Get filtered matches based on selected filter and user role
  List<MatchModel> get filteredMatches {
    var filtered = allMatches;

    // Apply role-based filtering first
    if (userRole == 'stat keeper') {
      filtered = filtered.where((match) => _isAssignedToStatKeeper(match)).toList();
    } else if (userRole == 'referee') {
      filtered = filtered.where((match) => _isAssignedToReferee(match)).toList();
    }

    // Apply league filter (for admin)
    if (userRole == 'admin' && _selectedFilter != 'all') {
      filtered = filtered.where((match) => match.leagueId == _selectedFilter).toList();
    }

    // Apply date filter (for non-admin roles)
    if (userRole != 'admin' && _selectedFilter != 'all') {
      filtered = _filterByDate(_selectedFilter, filtered);
    }

    // Apply team filter (if set)
    if (_selectedTeamId != null && _selectedTeamId!.isNotEmpty) {
      filtered = filtered.where((match) => 
        match.homeTeamId == _selectedTeamId || match.awayTeamId == _selectedTeamId
      ).toList();
    }

    return filtered;
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

  List<MatchModel> _filterByDate(String date, List<MatchModel> matches) {
    return matches.where((match) => match.date == date).toList();
  }

  void selectFilter(String filterId) {
    _selectedFilter = filterId;
    _safeNotifyListeners();
  }

  /// Select team for filtering
  void selectTeam(String? teamId) {
    _selectedTeamId = teamId;
    _safeNotifyListeners();
  }

  /// Clear team filter
  void clearTeamFilter() {
    _selectedTeamId = null;
    _safeNotifyListeners();
  }

  /// Fetch all leagues from backend
  Future<void> fetchLeagues() async {
    try {
      final leagues = await LeagueService.getAllLeagues();
      _leagues = leagues;
      debugPrint('✅ Fetched ${leagues.length} leagues');
    } catch (e) {
      debugPrint('❌ Error fetching leagues: $e');
      _errorMessage = 'Failed to load leagues: ${e.toString()}';
    }
  }

  /// Fetch all matches from backend
  Future<void> fetchAllMatches() async {
    try {
      final matches = await MatchService.getAllMatches();
      _allMatches = matches;
      debugPrint('✅ Fetched ${matches.length} matches');
    } catch (e) {
      debugPrint('❌ Error fetching matches: $e');
      _errorMessage = 'Failed to load matches: ${e.toString()}';
    }
  }

  /// Initialize provider by fetching leagues and matches
  Future<void> initialize() async {
    if (_isLoading) return; // Prevent multiple simultaneous initializations
    
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      // Fetch leagues and matches in parallel
      await Future.wait([
        fetchLeagues(),
        fetchAllMatches(),
      ]);
      _errorMessage = null;
    } catch (e) {
      debugPrint('❌ Error initializing GamesProvider: $e');
      _errorMessage = 'Failed to load data: ${e.toString()}';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await initialize();
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
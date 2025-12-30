import 'package:flutter/foundation.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/core/services/league_service.dart'
    show LeagueService, LeagueModel;
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
  final String? userId; // Current user's ID
  String? _errorMessage;
  String? _selectedTeamId;

  // Helper method to safely notify listeners
  void _safeNotifyListeners() {
    if (!hasListeners) return; // Check if disposed
    try {
      notifyListeners();
    } catch (e) {
      // Provider was disposed, ignore
    }
  }

  GamesProvider({
    required this.userRole,
    this.userId,
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
    final role = userRole.toLowerCase().replaceAll(' ', '');
    if (role == 'admin' || role == 'superadmin') {
      // Admin sees league filters - dynamically generated from fetched leagues
      final filters = <Map<String, String>>[
        {'id': 'all', 'label': 'All Games'},
      ];

      // Add filters for each league
      for (var league in _leagues) {
        filters.add({'id': league.id, 'label': league.leagueName});
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
    final role = userRole.toLowerCase().replaceAll(' ', '');

    // Apply role-based filtering first
    if (role == 'statkeeper') {
      filtered = filtered
          .where((match) => _isAssignedToStatKeeper(match))
          .toList();
    } else if (role == 'referee') {
      filtered = filtered
          .where((match) => _isAssignedToReferee(match))
          .toList();
    }

    // Apply league filter (for admin/superadmin)
    if ((role == 'admin' || role == 'superadmin') && _selectedFilter != 'all') {
      filtered = filtered
          .where((match) => match.leagueId == _selectedFilter)
          .toList();
    }

    // Apply date filter (for non-admin roles)
    if (role != 'admin' && role != 'superadmin' && _selectedFilter != 'all') {
      filtered = _filterByDate(_selectedFilter, filtered);
    }

    // Apply team filter (if set)
    if (_selectedTeamId != null && _selectedTeamId!.isNotEmpty) {
      filtered = filtered
          .where(
            (match) =>
                match.homeTeamId == _selectedTeamId ||
                match.awayTeamId == _selectedTeamId,
          )
          .toList();
    }

    // Sort by date and time (matchDateTime)
    final sorted = List<MatchModel>.from(filtered);
    sorted.sort((a, b) {
      if (a.matchDateTime == null && b.matchDateTime == null) return 0;
      if (a.matchDateTime == null) return 1;
      if (b.matchDateTime == null) return -1;
      return a.matchDateTime!.compareTo(b.matchDateTime!);
    });

    return sorted;
  }

  /// Check if a match is assigned to the current stat keeper
  bool _isAssignedToStatKeeper(MatchModel match) {
    if (userId == null || userId!.isEmpty) return false;

    // Standardize IDs for comparison
    final currentUserId = userId!.trim();
    final matchStatKeeperId = match.statKeeperId?.toString().trim();

    return matchStatKeeperId == currentUserId;
  }

  /// Check if a match is assigned to the current referee
  bool _isAssignedToReferee(MatchModel match) {
    if (userId == null || userId!.isEmpty) return false;

    // Standardize IDs for comparison
    final currentUserId = userId!.trim();
    final matchRefereeId = match.refereeId?.toString().trim();

    return matchRefereeId == currentUserId;
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
    } catch (e) {
      _errorMessage = 'Failed to load leagues: ${e.toString()}';
    }
  }

  /// Fetch all matches from backend
  Future<void> fetchAllMatches() async {
    try {
      final matches = await MatchService.getAllMatches();
      _allMatches = matches;
    } catch (e) {
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
      await Future.wait([fetchLeagues(), fetchAllMatches()]);
      _errorMessage = null;
    } catch (e) {
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
    final role = userRole.toLowerCase().replaceAll(' ', '');
    return role == 'admin' || role == 'superadmin';
  }

  /// Check if should show payment prompt (Captain with unpaid fee)
  bool get shouldShowPaymentPrompt {
    return userRole == 'captain' && isLeagueFeeUnpaid;
  }
}


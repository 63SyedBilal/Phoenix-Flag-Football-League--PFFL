import 'package:flutter/foundation.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/core/services/league_service.dart'
    show LeagueService, LeagueModel;

/// Provider for managing Free Agent active leagues selection
class FreeAgentActiveLeaguesProvider extends ChangeNotifier {
  // Store all leagues from backend
  List<LeagueCreationModel> _allLeagues = [];

  // Selected league IDs
  Set<String> _selectedLeagueIds = {};

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<LeagueCreationModel> get allLeagues => _allLeagues;
  Set<String> get selectedLeagueIds => _selectedLeagueIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasSelectedLeagues => _selectedLeagueIds.isNotEmpty;

  /// Get only active leagues (filtered)
  List<LeagueCreationModel> get activeLeagues {
    return _allLeagues.where((league) {
      final status = league.status.toLowerCase();
      return status == 'active';
    }).toList();
  }

  /// Get selected leagues as LeagueCreationModel list
  List<LeagueCreationModel> get selectedLeagues {
    return _allLeagues.where((league) {
      return _selectedLeagueIds.contains(league.id);
    }).toList();
  }

  /// Check if a league is selected
  bool isLeagueSelected(String leagueId) {
    return _selectedLeagueIds.contains(leagueId);
  }

  /// Toggle league selection
  void toggleLeagueSelection(String leagueId) {
    if (_selectedLeagueIds.contains(leagueId)) {
      _selectedLeagueIds.remove(leagueId);
    } else {
      _selectedLeagueIds.add(leagueId);
    }
    notifyListeners();
  }

  /// Clear all selections
  void clearSelection() {
    _selectedLeagueIds.clear();
    notifyListeners();
  }

  /// Fetch all leagues from backend and filter for active ones
  Future<void> fetchActiveLeagues() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final leagues = await LeagueService.getAllLeagues();
      _allLeagues = leagues
          .map((league) => _convertToLeagueCreationModel(league))
          .toList();
      _errorMessage = null;

      debugPrint('✅ Fetched ${leagues.length} leagues from backend');
      debugPrint('✅ Active leagues: ${activeLeagues.length}');
    } catch (e) {
      debugPrint('❌ Error fetching leagues: $e');
      _errorMessage = 'Failed to load leagues: ${e.toString()}';
      _allLeagues = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh leagues list
  Future<void> refreshLeagues() async {
    await fetchActiveLeagues();
  }

  /// Convert LeagueModel to LeagueCreationModel
  LeagueCreationModel _convertToLeagueCreationModel(LeagueModel league) {
    return LeagueCreationModel(
      id: league.id,
      leagueName: league.leagueName,
      teamLogo: league.logo ?? '',
      selectedPlayerIds: [],
      captainId: '',
      registrationFee: league.perPlayerLeagueFee,
      createdAt: league.startDate,
      status: league.status == 'active' ? 'Active' : league.status,
      format: league.format,
      startDate: league.startDate,
      endDate: league.endDate,
    );
  }
}

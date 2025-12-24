import 'package:flutter/foundation.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/core/services/league_service.dart';

class EnhancedLeaguesProvider extends ChangeNotifier {
  // Store leagues from backend
  List<LeagueCreationModel> _allLeagues = [];
  bool _isLoadingLeagues = false;
  String? _errorMessage;

  // Selected league for detail view
  String _selectedLeague = 'The Rugby Championship';
  bool _hasNotifications = true;

  // Getters
  List<LeagueCreationModel> get allLeagues => _allLeagues;
  List<LeagueCreationModel> get createdLeagues =>
      _allLeagues; // For backward compatibility
  String get selectedLeague => _selectedLeague;
  bool get hasNotifications => _hasNotifications;
  int get leaguesCount => _allLeagues.length;
  bool get isLoadingLeagues => _isLoadingLeagues;
  String? get errorMessage => _errorMessage;

  /// Fetch all leagues from backend
  Future<void> fetchAllLeagues() async {
    if (_isLoadingLeagues) return;

    _isLoadingLeagues = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final leagues = await LeagueService.getAllLeagues();
      _allLeagues = leagues
          .map((league) => _convertToLeagueCreationModel(league))
          .toList();

      // Sort: Newest created leagues first
      _allLeagues.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _errorMessage = null;
    } catch (e) {
      debugPrint('Error fetching leagues: $e');
      _errorMessage = 'Failed to load leagues: ${e.toString()}';
      _allLeagues = [];
    } finally {
      _isLoadingLeagues = false;
      notifyListeners();
    }
  }

  /// Refresh leagues list
  Future<void> refreshLeagues() async {
    await fetchAllLeagues();
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
      createdAt: league.createdAt ?? league.startDate,
      status: league.status == 'active' ? 'Active' : 'Pending',
      format: league.format,
      startDate: league.startDate,
      endDate: league.endDate,
    );
  }

  // Add a newly created league (for backward compatibility)
  void addLeague(LeagueCreationModel leagueCreation) {
    _allLeagues.add(leagueCreation);
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

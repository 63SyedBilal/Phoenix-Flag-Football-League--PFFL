import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/user_service.dart';
import 'package:pffl_managment/core/services/league_service.dart';
import 'package:pffl_managment/features/admin/providers/league_officials_provider.dart';

/// Provider for adding officials (referees and free agents) to a league
class AddOfficialProvider extends ChangeNotifier {
  final String leagueId;
  final String officialType;
  
  List<OfficialUser> _referees = [];
  List<OfficialUser> _statKeepers = [];
  List<OfficialUser> _freeAgents = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  int _selectedTabIndex = 0; // 0 = Referee/Stat Keeper, 1 = Free Agent
  
  // Track invitation sent status by user ID
  final Set<String> _invitationSent = {};

  AddOfficialProvider({
    required this.leagueId,
    required this.officialType,
  });

  // Getters
  List<OfficialUser> get referees => List.unmodifiable(_referees);
  List<OfficialUser> get statKeepers => List.unmodifiable(_statKeepers);
  List<OfficialUser> get freeAgents => List.unmodifiable(_freeAgents);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int get selectedTabIndex => _selectedTabIndex;
  
  bool isInvitationSent(String userId) => _invitationSent.contains(userId);
  
  // Get the appropriate list based on officialType
  List<OfficialUser> get _officialsList {
    if (officialType.toLowerCase() == 'referee') {
      return _referees;
    } else if (officialType.toLowerCase() == 'stat keeper') {
      return _statKeepers;
    }
    return _referees; // Default
  }
  
  // Filtered lists based on search
  List<OfficialUser> get filteredOfficials {
    final list = _officialsList;
    if (_searchQuery.isEmpty) return list;
    final query = _searchQuery.toLowerCase();
    return list.where((user) => 
      user.name.toLowerCase().contains(query) ||
      (user.email.toLowerCase().contains(query))
    ).toList();
  }
  
  List<OfficialUser> get filteredFreeAgents {
    if (_searchQuery.isEmpty) return _freeAgents;
    final query = _searchQuery.toLowerCase();
    return _freeAgents.where((user) => 
      user.name.toLowerCase().contains(query) ||
      (user.email.toLowerCase().contains(query))
    ).toList();
  }

  /// Initialize provider by fetching officials and free agents
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch based on officialType
      if (officialType.toLowerCase() == 'referee') {
        await Future.wait([
          _fetchReferees(),
          _fetchFreeAgents(),
        ]);
      } else if (officialType.toLowerCase() == 'stat keeper') {
        await Future.wait([
          _fetchStatKeepers(),
          _fetchFreeAgents(),
        ]);
      } else {
        // Default: fetch both referees and stat keepers
        await Future.wait([
          _fetchReferees(),
          _fetchStatKeepers(),
          _fetchFreeAgents(),
        ]);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load officials: ${e.toString()}';
      debugPrint('Error initializing AddOfficialProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  Future<void> _fetchReferees() async {
    try {
      final apiUsers = await UserService.getReferees();
      _referees = apiUsers.map((user) => _mapToOfficialUser(user)).toList();
      debugPrint('✅ Fetched ${_referees.length} referees');
    } catch (e) {
      debugPrint('Error fetching referees: $e');
      _referees = [];
      rethrow;
    }
  }

  Future<void> _fetchStatKeepers() async {
    try {
      final apiUsers = await UserService.getStatKeepers();
      _statKeepers = apiUsers.map((user) => _mapToOfficialUser(user)).toList();
      debugPrint('✅ Fetched ${_statKeepers.length} stat keepers');
    } catch (e) {
      debugPrint('Error fetching stat keepers: $e');
      _statKeepers = [];
      rethrow;
    }
  }

  Future<void> _fetchFreeAgents() async {
    try {
      final apiUsers = await UserService.getFreeAgents();
      _freeAgents = apiUsers.map((user) => _mapToOfficialUser(user)).toList();
      debugPrint('✅ Fetched ${_freeAgents.length} free agents');
    } catch (e) {
      debugPrint('Error fetching free agents: $e');
      _freeAgents = [];
      rethrow;
    }
  }

  /// Map API UserModel to OfficialUser
  OfficialUser _mapToOfficialUser(UserModel apiUser) {
    return OfficialUser(
      id: apiUser.id,
      name: apiUser.displayName,
      email: apiUser.email,
      imageUrl: null,
    );
  }

  /// Send invitation to user for this league
  Future<bool> sendInvitation(String userId, String role) async {
    try {
      bool success = false;
      
      // Determine role based on officialType and user role
      if (officialType.toLowerCase() == 'referee') {
        // For referee tab, invite as referee
        success = await LeagueService.inviteRefereeToLeague(leagueId, userId);
      } else if (officialType.toLowerCase() == 'stat keeper') {
        // For stat keeper tab, invite as stat keeper
        success = await LeagueService.inviteStatKeeperToLeague(leagueId, userId);
      }

      if (success) {
        _invitationSent.add(userId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error sending invitation: $e');
      return false;
    }
  }
}

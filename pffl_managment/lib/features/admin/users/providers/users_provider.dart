import 'package:flutter/foundation.dart';
import 'package:pffl_managment/core/models/filter_model.dart';
import 'package:pffl_managment/core/models/user_model.dart';
import 'package:pffl_managment/core/services/user_service.dart' as user_service;
import 'package:pffl_managment/core/services/league_service.dart' show LeagueService, LeagueModel, TeamModel;
import 'dart:async';

class UsersProvider extends ChangeNotifier {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  bool _hasNotifications = true;
  Timer? _searchDebounceTimer;

  // State management
  List<UserModel> _allUsers = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Cached data for mapping
  List<Map<String, dynamic>> _profiles = [];
  List<TeamModel> _teams = [];
  List<LeagueModel> _leagues = [];

  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  bool get hasNotifications => _hasNotifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filter options
  List<UserFilterModel> get filters => [
    UserFilterModel(id: 'all', label: 'All Users'),
    UserFilterModel(id: 'players', label: 'Players'),
    UserFilterModel(id: 'captains', label: 'Captains'),
    UserFilterModel(id: 'referees', label: 'Referees'),
    UserFilterModel(id: 'stat_keepers', label: 'Stat Keepers'),
  ];

  // All users data - fetched from backend
  List<UserModel> get allUsers => List.unmodifiable(_allUsers);

  // Filtered and searched users with enhanced search capabilities
  List<UserModel> get filteredUsers {
    var users = allUsers;

    // Apply filter
    if (_selectedFilter != 'all') {
      users = users.where((user) {
        switch (_selectedFilter) {
          case 'players':
            return user.role == UserRole.player;
          case 'captains':
            return user.role == UserRole.captain;
          case 'referees':
            return user.role == UserRole.referee;
          case 'stat_keepers':
            return user.role == UserRole.statKeeper;
          default:
            return true;
        }
      }).toList();
    }

    // Apply enhanced search with multiple criteria
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      final queryTerms = query.split(' ');

      users = users.where((user) {
        // Search in name
        final nameMatch = user.name.toLowerCase().contains(query);

        // Search in email
        final emailMatch = user.email.toLowerCase().contains(query);

        // Search in team
        final teamMatch = user.team.toLowerCase().contains(query);

        // Partial matching for multi-word queries
        bool partialMatch = false;
        if (queryTerms.length > 1) {
          partialMatch = queryTerms.every(
            (term) =>
                user.name.toLowerCase().contains(term) ||
                user.email.toLowerCase().contains(term) ||
                user.team.toLowerCase().contains(term),
          );
        }

        return nameMatch || emailMatch || teamMatch || partialMatch;
      }).toList();
    }

    return users;
  }

  void selectFilter(String filterId) {
    _selectedFilter = filterId;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;

    // Cancel the previous timer if it exists
    _searchDebounceTimer?.cancel();

    // Set a new timer to debounce the search
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      notifyListeners();
    });
  }

  void toggleNotifications() {
    _hasNotifications = !_hasNotifications;
    notifyListeners();
  }

  void inviteUser() {
    debugPrint('Invite user button clicked');
    // Add invite logic here
  }

  void showUserMenu(UserModel user) {
    debugPrint('Show menu for user: ${user.name}');
    // Add menu logic here
  }

  /// Map backend user data to UI UserModel
  UserModel _mapBackendToUIModel(
    user_service.UserModel backendUser,
    Map<String, dynamic>? profile,
    List<TeamModel> teams,
    List<LeagueModel> leagues,
  ) {
    // Get name
    final name = backendUser.fullName;

    // Map role string to UserRole enum
    UserRole role;
    switch (backendUser.role.toLowerCase()) {
      case 'player':
        role = UserRole.player;
        break;
      case 'captain':
        role = UserRole.captain;
        break;
      case 'referee':
        role = UserRole.referee;
        break;
      case 'stat-keeper':
      case 'stat keeper':
      case 'statkeeper':
        role = UserRole.statKeeper;
        break;
      default:
        role = UserRole.player; // Default fallback
    }

    // Get image from profile or generate placeholder
    String imageUrl;
    if (profile != null && profile['image'] != null && profile['image'].toString().isNotEmpty) {
      imageUrl = profile['image'].toString();
    } else {
      // Generate placeholder using dicebear
      imageUrl = 'https://api.dicebear.com/7.x/avataaars/png?seed=${Uri.encodeComponent(name)}&backgroundColor=b6e3f4';
    }

    // Determine team name
    String teamName = '';
    if (role == UserRole.captain) {
      // Find team where this user is captain
      try {
        final team = teams.firstWhere(
          (t) => t.captain != null && 
                 (t.captain!['_id']?.toString() == backendUser.id || 
                  t.captain!['id']?.toString() == backendUser.id),
        );
        teamName = team.teamName;
      } catch (e) {
        // Team not found, leave teamName empty
      }
    } else if (role == UserRole.player) {
      // Find team where this user is in squad5v5, squad7v7, or players
      for (var team in teams) {
        final squad5v5Ids = (team.squad5v5 ?? []).map((p) => p is Map ? (p['_id']?.toString() ?? p['id']?.toString()) : p.toString()).toList();
        final squad7v7Ids = (team.squad7v7 ?? []).map((p) => p is Map ? (p['_id']?.toString() ?? p['id']?.toString()) : p.toString()).toList();
        final playersIds = (team.players ?? []).map((p) => p is Map ? (p['_id']?.toString() ?? p['id']?.toString()) : p.toString()).toList();
        
        if (squad5v5Ids.contains(backendUser.id) || 
            squad7v7Ids.contains(backendUser.id) || 
            playersIds.contains(backendUser.id)) {
          teamName = team.teamName;
          break;
        }
      }
    }

    // Determine status (infer from paymentStatus or default to active)
    UserStatus status = UserStatus.active;
    if (profile != null && profile['paymentStatus'] != null) {
      final paymentStatus = profile['paymentStatus'].toString().toLowerCase();
      if (paymentStatus == 'pending') {
        status = UserStatus.pending;
      } else if (paymentStatus == 'unpaid') {
        status = UserStatus.invited; // Treat unpaid as invited
      }
    }

    return UserModel(
      id: backendUser.id,
      name: name,
      email: backendUser.email,
      role: role,
      team: teamName,
      status: status,
      imageUrl: imageUrl,
    );
  }

  /// Fetch all users, profiles, teams, and leagues from backend
  Future<void> fetchAllUsers() async {
    try {
      debugPrint('🔄 Fetching all users data...');
      
      // Fetch all data in parallel
      final results = await Future.wait([
        user_service.UserService.getAllUsers(),
        user_service.UserService.getAllProfiles(),
        LeagueService.getAllTeams(),
        LeagueService.getAllLeagues(),
      ]);

      final backendUsers = results[0] as List<user_service.UserModel>;
      _profiles = results[1] as List<Map<String, dynamic>>;
      _teams = results[2] as List<TeamModel>;
      _leagues = results[3] as List<LeagueModel>;

      debugPrint('✅ Fetched ${backendUsers.length} users, ${_profiles.length} profiles, ${_teams.length} teams, ${_leagues.length} leagues');

      // Create profile map by userId
      final profileMap = <String, Map<String, dynamic>>{};
      for (var profile in _profiles) {
        final userId = profile['userId']?.toString() ?? 
                      profile['userId']?['_id']?.toString() ?? 
                      profile['userId']?['id']?.toString();
        if (userId != null) {
          profileMap[userId] = profile;
        }
      }

      // Map backend users to UI users
      _allUsers = backendUsers.map((backendUser) {
        final profile = profileMap[backendUser.id];
        return _mapBackendToUIModel(backendUser, profile, _teams, _leagues);
      }).toList();

      debugPrint('✅ Mapped ${_allUsers.length} users to UI format');
      _errorMessage = null;
    } catch (e) {
      debugPrint('❌ Error fetching users: $e');
      _errorMessage = 'Failed to load users: ${e.toString()}';
      _allUsers = [];
    }
  }

  /// Update user role
  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      debugPrint('🔄 Updating user role: userId=$userId, newRole=$newRole');
      
      // Map UI role to backend role string
      String backendRole;
      switch (newRole.toLowerCase()) {
        case 'player':
          backendRole = 'player';
          break;
        case 'captain':
          backendRole = 'captain';
          break;
        case 'referee':
          backendRole = 'referee';
          break;
        case 'stat keeper':
        case 'statkeeper':
        case 'stat-keeper':
          backendRole = 'stat-keeper';
          break;
        default:
          backendRole = newRole;
      }

      final success = await user_service.UserService.updateUserRole(userId, backendRole);
      
      if (success) {
        // Update user in local list
        final userIndex = _allUsers.indexWhere((u) => u.id == userId);
        if (userIndex != -1) {
          final user = _allUsers[userIndex];
          
          // Map new role to UserRole enum
          UserRole newUserRole;
          switch (backendRole.toLowerCase()) {
            case 'player':
              newUserRole = UserRole.player;
              break;
            case 'captain':
              newUserRole = UserRole.captain;
              break;
            case 'referee':
              newUserRole = UserRole.referee;
              break;
            case 'stat-keeper':
            case 'stat keeper':
            case 'statkeeper':
              newUserRole = UserRole.statKeeper;
              break;
            default:
              newUserRole = user.role;
          }

          // Create updated user
          final updatedUser = UserModel(
            id: user.id,
            name: user.name,
            email: user.email,
            role: newUserRole,
            team: user.team,
            status: user.status,
            imageUrl: user.imageUrl,
          );

          _allUsers[userIndex] = updatedUser;
          notifyListeners();
          debugPrint('✅ User role updated successfully');
        }
        return true;
      } else {
        debugPrint('❌ Failed to update user role');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error updating user role: $e');
      return false;
    }
  }

  /// Initialize provider by fetching all data
  Future<void> initialize() async {
    if (_isLoading) return; // Prevent multiple simultaneous initializations
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await fetchAllUsers();
    } catch (e) {
      debugPrint('❌ Error initializing UsersProvider: $e');
      _errorMessage = 'Failed to load users: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await initialize();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }
}

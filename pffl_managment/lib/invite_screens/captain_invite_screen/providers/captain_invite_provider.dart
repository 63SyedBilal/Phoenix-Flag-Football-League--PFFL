import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/profile_service.dart';
import 'package:pffl_managment/core/services/team_service.dart';
import 'package:pffl_managment/core/services/user_service.dart';
import '../models/inviteable_user_model.dart';

/// Provider for managing captain invite screen state and logic
class CaptainInviteProvider extends ChangeNotifier {
  // Tab selection
  String _selectedTab = 'Players';
  
  // Search query
  final TextEditingController _searchController = TextEditingController();
  
  // User lists
  List<InviteableUserModel> _players = [];
  List<InviteableUserModel> _freeAgents = [];
  
  // Team data
  String? _teamId;
  String _selectedFormat = '5v5'; // Default to 5v5
  
  // Loading states
  bool _isLoading = false;
  bool _isLoadingPlayers = false;
  bool _isLoadingFreeAgents = false;
  
  // Error state
  String? _errorMessage;

  // Getters
  String get selectedTab => _selectedTab;
  TextEditingController get searchController => _searchController;
  List<InviteableUserModel> get players => _players;
  List<InviteableUserModel> get freeAgents => _freeAgents;
  String? get teamId => _teamId;
  String get selectedFormat => _selectedFormat;
  bool get isLoading => _isLoading;
  bool get isLoadingPlayers => _isLoadingPlayers;
  bool get isLoadingFreeAgents => _isLoadingFreeAgents;
  String? get errorMessage => _errorMessage;

  CaptainInviteProvider() {
    _searchController.addListener(_onSearchChanged);
    initialize();
  }

  /// Initialize provider - fetch team data and user lists
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch team data first to get teamId
      final teamData = await TeamService.getTeamByCaptain();
      
      if (teamData == null) {
        _errorMessage = 'No team found. Please create a team first.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _teamId = teamData['_id']?.toString() ?? teamData['id']?.toString();
      
      if (_teamId == null || _teamId!.isEmpty) {
        _errorMessage = 'Team ID not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch users based on selected tab
      if (_selectedTab == 'Players') {
        await fetchPlayers(teamData);
      } else {
        await fetchFreeAgents(teamData);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load data: ${e.toString()}';
      print('❌ Error initializing CaptainInviteProvider: $e');
      notifyListeners();
    }
  }

  /// Select tab (Players or Free Agents)
  void selectTab(String tab) {
    if (_selectedTab != tab) {
      _selectedTab = tab;
      _errorMessage = null;
      notifyListeners();

      // Fetch data for the selected tab if not already loaded
      if (tab == 'Players' && _players.isEmpty && !_isLoadingPlayers) {
        _fetchUsersForTab('player');
      } else if (tab == 'Free Agents' && _freeAgents.isEmpty && !_isLoadingFreeAgents) {
        _fetchUsersForTab('free-agent');
      }
    }
  }

  /// Set search query (handled by listener)
  void _onSearchChanged() {
    notifyListeners();
  }

  /// Set format (5v5 or 7v7)
  void setFormat(String format) {
    if (format == '5v5' || format == '7v7') {
      _selectedFormat = format;
      notifyListeners();
    }
  }

  /// Fetch players (role='player')
  Future<void> fetchPlayers(Map<String, dynamic>? teamData) async {
    await _fetchUsersForTab('player', teamData: teamData);
  }

  /// Fetch free agents (role='free-agent')
  Future<void> fetchFreeAgents(Map<String, dynamic>? teamData) async {
    await _fetchUsersForTab('free-agent', teamData: teamData);
  }

  /// Fetch users for a specific tab
  Future<void> _fetchUsersForTab(String role, {Map<String, dynamic>? teamData}) async {
    if (role == 'player') {
      _isLoadingPlayers = true;
    } else {
      _isLoadingFreeAgents = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch users by role
      final users = await UserService.getUsersByRole(role);
      
      // Convert to InviteableUserModel
      List<InviteableUserModel> inviteableUsers = users
          .map((user) => InviteableUserModel.fromUserModel(user))
          .toList();

      // Enrich with profile data
      inviteableUsers = await _enrichUsersWithProfiles(inviteableUsers);

      // Check invited status if team data is available
      if (teamData != null) {
        inviteableUsers = _checkInvitedStatus(inviteableUsers, teamData);
      } else if (_teamId != null) {
        // Fetch team data if not provided
        final teamData = await TeamService.getTeamByCaptain();
        if (teamData != null) {
          inviteableUsers = _checkInvitedStatus(inviteableUsers, teamData);
        }
      }

      // Update the appropriate list
      if (role == 'player') {
        _players = inviteableUsers;
        _isLoadingPlayers = false;
      } else {
        _freeAgents = inviteableUsers;
        _isLoadingFreeAgents = false;
      }

      notifyListeners();
    } catch (e) {
      if (role == 'player') {
        _isLoadingPlayers = false;
      } else {
        _isLoadingFreeAgents = false;
      }
      _errorMessage = 'Failed to fetch ${role == 'player' ? 'players' : 'free agents'}: ${e.toString()}';
      print('❌ Error fetching $role: $e');
      notifyListeners();
    }
  }

  /// Enrich users with profile data (jersey number, position, image)
  Future<List<InviteableUserModel>> _enrichUsersWithProfiles(
    List<InviteableUserModel> users,
  ) async {
    final enrichedUsers = <InviteableUserModel>[];

    for (var user in users) {
      try {
        final profile = await ProfileService.getProfile(user.id);
        if (profile != null) {
          final jerseyNumber = profile['jerseyNumber']?.toString();
          final position = profile['position']?.toString();
          final image = profile['image']?.toString();

          enrichedUsers.add(
            user.copyWith(
              jerseyNumber: jerseyNumber?.isNotEmpty == true ? jerseyNumber : null,
              position: position?.isNotEmpty == true ? position : null,
              imageUrl: image?.isNotEmpty == true ? image : null,
            ),
          );
        } else {
          // No profile found, use original user data
          enrichedUsers.add(user);
        }
      } catch (e) {
        print('⚠️ Error fetching profile for ${user.id}: $e');
        // Continue with original user data if profile fetch fails
        enrichedUsers.add(user);
      }
    }

    return enrichedUsers;
  }

  /// Check if users are already invited (in team squads)
  List<InviteableUserModel> _checkInvitedStatus(
    List<InviteableUserModel> users,
    Map<String, dynamic> teamData,
  ) {
    final squad5v5 = teamData['squad5v5'] as List<dynamic>? ?? [];
    final squad7v7 = teamData['squad7v7'] as List<dynamic>? ?? [];

    // Convert squad arrays to sets of user IDs
    final squad5v5Ids = squad5v5
        .map((id) => id.toString())
        .where((id) => id.isNotEmpty)
        .toSet();
    final squad7v7Ids = squad7v7
        .map((id) => id.toString())
        .where((id) => id.isNotEmpty)
        .toSet();

    // Check if user is in either squad
    return users.map((user) {
      final isInSquad5v5 = squad5v5Ids.contains(user.id);
      final isInSquad7v7 = squad7v7Ids.contains(user.id);
      final isInvited = isInSquad5v5 || isInSquad7v7;

      return user.copyWith(isInvited: isInvited);
    }).toList();
  }

  /// Get filtered users based on selected tab and search query
  List<InviteableUserModel> getFilteredUsers() {
    final users = _selectedTab == 'Players' ? _players : _freeAgents;
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      return users;
    }

    return users.where((user) {
      final name = user.fullName.toLowerCase();
      final email = user.email.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  /// Invite a user to the team
  Future<bool> inviteUser(String userId) async {
    if (_teamId == null || _teamId!.isEmpty) {
      _errorMessage = 'Team ID not found';
      notifyListeners();
      return false;
    }

    // Find user and set inviting state
    final users = _selectedTab == 'Players' ? _players : _freeAgents;
    final userIndex = users.indexWhere((u) => u.id == userId);
    
    if (userIndex == -1) {
      _errorMessage = 'User not found';
      notifyListeners();
      return false;
    }

    // Update inviting state
    if (_selectedTab == 'Players') {
      _players[userIndex] = _players[userIndex].copyWith(isInviting: true);
    } else {
      _freeAgents[userIndex] = _freeAgents[userIndex].copyWith(isInviting: true);
    }
    notifyListeners();

    try {
      // Call API to invite player
      await TeamService.invitePlayer(
        playerId: userId,
        teamId: _teamId!,
        format: _selectedFormat,
      );

      // Update invited state
      if (_selectedTab == 'Players') {
        _players[userIndex] = _players[userIndex].copyWith(
          isInvited: true,
          isInviting: false,
        );
      } else {
        _freeAgents[userIndex] = _freeAgents[userIndex].copyWith(
          isInvited: true,
          isInviting: false,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      // Reset inviting state on error
      if (_selectedTab == 'Players') {
        _players[userIndex] = _players[userIndex].copyWith(isInviting: false);
      } else {
        _freeAgents[userIndex] = _freeAgents[userIndex].copyWith(isInviting: false);
      }

      _errorMessage = 'Failed to invite user: ${e.toString()}';
      print('❌ Error inviting user: $e');
      notifyListeners();
      return false;
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await initialize();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}


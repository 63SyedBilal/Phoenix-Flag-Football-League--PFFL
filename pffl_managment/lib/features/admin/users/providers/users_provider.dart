import 'package:flutter/foundation.dart';
import 'package:pffl_managment/core/models/filter_model.dart';
import 'package:pffl_managment/core/models/user_model.dart';
import 'dart:async';

class UsersProvider extends ChangeNotifier {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  bool _hasNotifications = true;
  Timer? _searchDebounceTimer;

  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  bool get hasNotifications => _hasNotifications;

  // Filter options
  List<UserFilterModel> get filters => [
    UserFilterModel(id: 'all', label: 'All Users'),
    UserFilterModel(id: 'players', label: 'Players'),
    UserFilterModel(id: 'captains', label: 'Captains'),
    UserFilterModel(id: 'referees', label: 'Referees'),
    UserFilterModel(id: 'stat_keepers', label: 'Stat Keepers'),
  ];

  // All users data
  List<UserModel> get allUsers => [
    UserModel(
      id: '1',
      name: 'Marcus Johnson',
      email: 'marcus.j@pffl.com',
      role: UserRole.captain,
      team: 'Phoenix Falcons',
      status: UserStatus.active,
      imageUrl:
          'https://api.dicebear.com/7.x/avataaars/png?seed=Marcus&backgroundColor=b6e3f4',
    ),
    UserModel(
      id: '2',
      name: 'Sarah Mitchell',
      email: 'sarah.m@pffl.com',
      role: UserRole.player,
      team: 'Storm Riders',
      status: UserStatus.active,
      imageUrl:
          'https://api.dicebear.com/7.x/avataaars/png?seed=Sarah&backgroundColor=c0aede',
    ),
    UserModel(
      id: '3',
      name: 'James Richardson',
      email: 'james.r@pffl.com',
      role: UserRole.referee,
      team: '',
      status: UserStatus.active,
      imageUrl:
          'https://api.dicebear.com/7.x/avataaars/png?seed=James&backgroundColor=d1d4f9',
    ),
    UserModel(
      id: '4',
      name: 'Emily Chen',
      email: 'emily.c@pffl.com',
      role: UserRole.statKeeper,
      team: '',
      status: UserStatus.active,
      imageUrl:
          'https://api.dicebear.com/7.x/avataaars/png?seed=Emily&backgroundColor=ffd5dc',
    ),
    UserModel(
      id: '5',
      name: 'David Thompson',
      email: 'david.t@pffl.com',
      role: UserRole.player,
      team: 'Thunder Knights',
      status: UserStatus.invited,
      imageUrl:
          'https://api.dicebear.com/7.x/avataaars/png?seed=David&backgroundColor=ffdfbf',
    ),
    UserModel(
      id: '6',
      name: 'Lisa Anderson',
      email: 'lisa.a@pffl.com',
      role: UserRole.captain,
      team: 'Lightning Strikers',
      status: UserStatus.active,
      imageUrl:
          'https://api.dicebear.com/7.x/avataaars/png?seed=Lisa&backgroundColor=c7ecee',
    ),
    UserModel(
      id: '7',
      name: 'Michael Brown',
      email: 'michael.b@pffl.com',
      role: UserRole.referee,
      team: '',
      status: UserStatus.pending,
      imageUrl:
          'https://api.dicebear.com/7.x/avataaars/png?seed=Michael&backgroundColor=b6e3f4',
    ),
    UserModel(
      id: '8',
      name: 'Jennifer Lee',
      email: 'jennifer.l@pffl.com',
      role: UserRole.statKeeper,
      team: '',
      status: UserStatus.active,
      imageUrl:
          'https://api.dicebear.com/7.x/avataaars/png?seed=Jennifer&backgroundColor=ffeaa7',
    ),
    UserModel(
      id: '9',
      name: 'Robert Wilson',
      email: 'robert.w@pffl.com',
      role: UserRole.player,
      team: 'Phoenix Falcons',
      status: UserStatus.active,
      imageUrl:
          'https://api.dicebear.com/7.x/avataaars/png?seed=Robert&backgroundColor=dfe6e9',
    ),
    UserModel(
      id: '10',
      name: 'Amanda Torres',
      email: 'amanda.t@pffl.com',
      role: UserRole.player,
      team: 'Storm Riders',
      status: UserStatus.invited,
      imageUrl:
          'https://api.dicebear.com/7.x/avataaars/png?seed=Amanda&backgroundColor=fab1a0',
    ),
  ];

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

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }
}

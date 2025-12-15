import 'package:flutter/foundation.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';

/// Provider for managing leagues with role-based access control
class LeagueProvider extends ChangeNotifier {
  final String userRole;

  // Hardcoded existing leagues (simulating database)
  final List<LeagueCreationModel> _existingLeagues = [
    LeagueCreationModel(
      id: '1',
      leagueName: 'Phoenix Winter 2025',
      teamLogo: '',
      selectedPlayerIds: [],
      captainId: '',
      registrationFee: 250,
      createdAt: DateTime.now(),
      status: 'Active',
      format: '5v5',
      startDate: DateTime(2025, 12, 10),
      endDate: DateTime(2026, 2, 25),
    ),
    LeagueCreationModel(
      id: '2',
      leagueName: 'Champions Cup 2025',
      teamLogo: '',
      selectedPlayerIds: [],
      captainId: '',
      registrationFee: 250,
      createdAt: DateTime.now(),
      status: 'Active',
      format: '5v5',
      startDate: DateTime(2025, 12, 10),
      endDate: DateTime(2026, 2, 25),
    ),
    LeagueCreationModel(
      id: '3',
      leagueName: 'Summer League 2025',
      teamLogo: '',
      selectedPlayerIds: [],
      captainId: '',
      registrationFee: 250,
      createdAt: DateTime.now(),
      status: 'Active',
      format: '5v5',
      startDate: DateTime(2025, 12, 10),
      endDate: DateTime(2026, 2, 25),
    ),
    LeagueCreationModel(
      id: '4',
      leagueName: 'Spring Tournament 2026',
      teamLogo: '',
      selectedPlayerIds: [],
      captainId: '',
      registrationFee: 250,
      createdAt: DateTime.now(),
      status: 'Pending',
      format: '5v5',
      startDate: DateTime(2026, 2, 1),
      endDate: DateTime(2026, 2, 25),
    ),
  ];

  // Leagues created by Admin during runtime
  final List<LeagueCreationModel> _createdLeagues = [];

  LeagueProvider({required this.userRole});

  /// Get all leagues (existing + created)
  List<LeagueCreationModel> get allLeagues {
    return [..._existingLeagues, ..._createdLeagues];
  }

  /// Check if user can create/edit leagues
  bool get canEdit => userRole == 'admin';

  /// Create a new league (Admin only)
  void createLeague(LeagueCreationModel league) {
    if (!canEdit) {
      throw Exception('Only Admin can create leagues');
    }
    _createdLeagues.add(league);
    notifyListeners();
  }

  /// Update an existing league (Admin only)
  void updateLeague(String id, LeagueCreationModel updatedLeague) {
    if (!canEdit) {
      throw Exception('Only Admin can update leagues');
    }

    final index = _createdLeagues.indexWhere((league) => league.id == id);
    if (index != -1) {
      _createdLeagues[index] = updatedLeague;
      notifyListeners();
    }
  }

  /// Delete a league (Admin only)
  void deleteLeague(String id) {
    if (!canEdit) {
      throw Exception('Only Admin can delete leagues');
    }

    _createdLeagues.removeWhere((league) => league.id == id);
    notifyListeners();
  }

  /// Get league by ID
  LeagueCreationModel? getLeagueById(String id) {
    try {
      return allLeagues.firstWhere((league) => league.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Filter leagues by status
  List<LeagueCreationModel> getLeaguesByStatus(String status) {
    return allLeagues.where((league) => league.status == status).toList();
  }

  /// Get active leagues
  List<LeagueCreationModel> get activeLeagues {
    return getLeaguesByStatus('Active');
  }

  /// Get pending leagues
  List<LeagueCreationModel> get pendingLeagues {
    return getLeaguesByStatus('Pending');
  }
}

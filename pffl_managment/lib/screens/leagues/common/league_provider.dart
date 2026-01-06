import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/core/services/league_service.dart';

/// Provider for managing leagues with role-based access control
class LeagueProvider extends ChangeNotifier {
  final String userRole;
  List<LeagueModel> _allLeagues = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Leagues created by Admin during runtime
  final List<LeagueCreationModel> _createdLeagues = [];

  LeagueProvider({required this.userRole}) {
    fetchLeagues();
  }

  List<LeagueModel> get allLeagues => _allLeagues;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchLeagues() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allLeagues = await LeagueService.getAllLeagues();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
  LeagueModel? getLeagueById(String id) {
    try {
      return _allLeagues.firstWhere((league) => league.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Filter leagues by status
  List<LeagueModel> getLeaguesByStatus(String status) {
    return _allLeagues.where((league) => league.status == status).toList();
  }

  /// Get active leagues
  List<LeagueModel> get activeLeagues {
    return getLeaguesByStatus('active');
  }

  /// Get pending leagues
  List<LeagueModel> get pendingLeagues {
    return getLeaguesByStatus('pending');
  }
}

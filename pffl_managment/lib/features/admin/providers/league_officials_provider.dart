import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/user_service.dart';
import 'package:pffl_managment/core/services/league_service.dart';
import 'package:pffl_managment/core/services/user_service.dart' as user_service;

/// Provider for managing league officials (referees and statkeepers)
/// Shows only officials assigned/accepted for the league
class LeagueOfficialsProvider extends ChangeNotifier {
  final String leagueId;
  
  List<OfficialUser> _referees = [];
  List<OfficialUser> _statKeepers = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Track invitation sent status by user ID
  final Set<String> _invitationSent = {};

  LeagueOfficialsProvider({required this.leagueId});

  // Getters
  List<OfficialUser> get referees => List.unmodifiable(_referees);
  List<OfficialUser> get statKeepers => List.unmodifiable(_statKeepers);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  bool isInvitationSent(String userId) => _invitationSent.contains(userId);

  /// Initialize provider by fetching league-assigned officials
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final leagueDetail = await LeagueService.getLeagueById(leagueId);
      if (leagueDetail == null) {
        _errorMessage = 'League not found';
        return;
      }

      // Map league referees to OfficialUser
      _referees = leagueDetail.referees.map((referee) {
        return OfficialUser(
          id: referee.id,
          name: referee.displayName,
          email: referee.email,
          imageUrl: null,
        );
      }).toList();

      // Map league stat keepers to OfficialUser
      _statKeepers = leagueDetail.statKeepers.map((statKeeper) {
        return OfficialUser(
          id: statKeeper.id,
          name: statKeeper.displayName,
          email: statKeeper.email,
          imageUrl: null,
        );
      }).toList();

      _errorMessage = null;
      debugPrint('✅ Loaded ${_referees.length} referees, ${_statKeepers.length} stat keepers');
    } catch (e) {
      _errorMessage = 'Failed to load officials: ${e.toString()}';
      debugPrint('Error initializing LeagueOfficialsProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh officials data
  Future<void> refresh() async {
    await initialize();
  }

  /// Send invitation to referee or free agent for this league
  Future<bool> sendInvitation(String userId, String role) async {
    try {
      bool success = false;
      
      if (role.toLowerCase() == 'referee' || role.toLowerCase() == 'free-agent') {
        success = await LeagueService.inviteRefereeToLeague(leagueId, userId);
      } else if (role.toLowerCase() == 'stat-keeper' || role.toLowerCase() == 'stat keeper') {
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

/// Model for displaying official users in the UI
class OfficialUser {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;

  OfficialUser({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
  });
}

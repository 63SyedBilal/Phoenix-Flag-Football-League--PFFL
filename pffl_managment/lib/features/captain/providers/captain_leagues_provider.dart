import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';

class CaptainLeaguesProvider extends ChangeNotifier {
  // Mock data for captain's leagues
  // In a real app, this would come from an API or database
  List<LeagueCreationModel> _leagues = [
    LeagueCreationModel(
      id: '1',
      leagueName: 'Champions Cup 2025',
      teamLogo: '',
      selectedPlayerIds: [],
      captainId: 'captain1',
      registrationFee: 250,
      createdAt: DateTime.now(),
      status: 'Active',
      format: '5v5',
      startDate: DateTime(2025, 12, 10),
      endDate: DateTime(2026, 3, 20),
    ),
    LeagueCreationModel(
      id: '2',
      leagueName: 'Summer League 2025',
      teamLogo: '',
      selectedPlayerIds: [],
      captainId: 'captain1',
      registrationFee: 200,
      createdAt: DateTime.now(),
      status: 'Active',
      format: '7v7',
      startDate: DateTime(2025, 6, 10),
      endDate: DateTime(2025, 8, 30),
    ),
    LeagueCreationModel(
      id: '3',
      leagueName: 'Winter Warriors 2025',
      teamLogo: '',
      selectedPlayerIds: [],
      captainId: 'captain1',
      registrationFee: 150,
      createdAt: DateTime.now(),
      status: 'Completed',
      format: '5v5',
      startDate: DateTime(2025, 1, 10),
      endDate: DateTime(2025, 3, 20),
    ),
  ];

  List<LeagueCreationModel> get leagues => _leagues;

  // Method to get a specific league by ID
  LeagueCreationModel? getLeagueById(String id) {
    try {
      return _leagues.firstWhere((league) => league.id == id);
    } catch (e) {
      return null;
    }
  }

  // Method to get leagues by status
  List<LeagueCreationModel> getLeaguesByStatus(String status) {
    return _leagues.where((league) => league.status == status).toList();
  }

  // Method to get active leagues
  List<LeagueCreationModel> get activeLeagues {
    return _leagues.where((league) => league.status == 'Active').toList();
  }

  // Method to get completed leagues
  List<LeagueCreationModel> get completedLeagues {
    return _leagues.where((league) => league.status == 'Completed').toList();
  }

  // Method to get pending leagues
  List<LeagueCreationModel> get pendingLeagues {
    return _leagues.where((league) => league.status == 'Pending').toList();
  }
}
import 'package:pffl_managment/core/services/league_service.dart'
    show LeagueService, TeamModel;
import 'package:pffl_managment/core/services/user_service.dart' show UserModel;

/// Helper to handle data fetching for upcoming games
class UpcomingGamesFetchHelper {
  static Future<Map<String, dynamic>> fetchAllRequiredData(
    String leagueId,
  ) async {
    final results = await Future.wait([
      fetchTeamsForLeague(leagueId),
      fetchReferees(leagueId),
      fetchStatKeepers(leagueId),
    ]);

    return {
      'teams': results[0],
      'referees': results[1],
      'statKeepers': results[2],
    };
  }

  static Future<List<TeamModel>> fetchTeamsForLeague(String leagueId) async {
    if (leagueId.isEmpty) return [];
    try {
      final league = await LeagueService.getLeagueById(leagueId);
      return league?.teams ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<UserModel>> fetchReferees(String leagueId) async {
    if (leagueId.isEmpty) return [];
    try {
      final league = await LeagueService.getLeagueById(leagueId);
      return league?.referees ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<UserModel>> fetchStatKeepers(String leagueId) async {
    if (leagueId.isEmpty) return [];
    try {
      final league = await LeagueService.getLeagueById(leagueId);
      return league?.statKeepers ?? [];
    } catch (e) {
      return [];
    }
  }
}

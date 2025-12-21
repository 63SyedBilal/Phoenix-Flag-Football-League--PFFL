import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/core/services/team_service.dart';

/// Service wrapper dedicated to referee game detail operations.
class RefereeGameDetailService {
  const RefereeGameDetailService();

  Future<MatchModel> switchHalfTime(String matchId) {
    return MatchService.switchHalfTime(matchId);
  }

  Future<MatchModel> switchFullTime(String matchId) {
    return MatchService.switchFullTime(matchId);
  }

  Future<MatchModel> switchOvertime(String matchId) {
    return MatchService.switchOvertime(matchId);
  }

  Future<MatchModel> updateMatch(String matchId, Map<String, dynamic> data) {
    return MatchService.updateMatch(matchId, data);
  }

  Future<MatchModel> completeToss({
    required String matchId,
    required String winnerTeamId,
    required String winnerSide,
  }) {
    return MatchService.completeToss(
      matchId: matchId,
      winnerTeamId: winnerTeamId,
      winnerSide: winnerSide,
    );
  }

  Future<MatchModel> addGameAction({
    required String matchId,
    required String teamId,
    required String playerId,
    required String actionType,
  }) {
    return MatchService.addGameAction(
      matchId: matchId,
      teamId: teamId,
      playerId: playerId,
      actionType: actionType,
    );
  }

  Future<Map<String, dynamic>?> fetchTeamById(String teamId) {
    return TeamService.getTeamById(teamId);
  }
}

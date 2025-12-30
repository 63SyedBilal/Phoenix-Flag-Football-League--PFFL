import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/services/referee_statkeeper_trigger_service.dart';

/// Helper to handle notifications for upcoming games
class UpcomingGamesNotificationHelper {
  static Future<void> sendAssignmentNotifications(
    MatchModel match, {
    MatchModel? editingMatch,
    bool isUpdate = false,
  }) async {
    final teamA = match.homeTeam;
    final teamB = match.awayTeam;
    final venue = match.venue ?? 'TBD';
    final date = match
        .date; // Use match.date which is already formatted usually or from matchDateTime
    final time = match.time;
    final matchId = match.id!;

    // Notify Referee
    if (match.refereeId != null && match.refereeId!.isNotEmpty) {
      if (!isUpdate || (editingMatch?.refereeId != match.refereeId)) {
        await RefereeStatKeeperTriggerService.triggerRefereeAssigned(
          refereeId: match.refereeId!,
          refereeName: 'Referee',
          teamA: teamA,
          teamB: teamB,
          venue: venue,
          date: date,
          time: time,
          matchId: matchId,
        );
      } else if (isUpdate) {
        // Rescheduled notification
        await RefereeStatKeeperTriggerService.triggerMatchRescheduled(
          staffId: match.refereeId!,
          teamA: teamA,
          teamB: teamB,
          newDate: date,
          newTime: time,
          venue: venue,
          matchId: matchId,
          isReferee: true,
        );
      }
    }

    // Notify Stat Keeper
    if (match.statKeeperId != null && match.statKeeperId!.isNotEmpty) {
      if (!isUpdate || (editingMatch?.statKeeperId != match.statKeeperId)) {
        await RefereeStatKeeperTriggerService.triggerStatKeeperAssigned(
          statKeeperId: match.statKeeperId!,
          statKeeperName: 'Stat Keeper',
          teamA: teamA,
          teamB: teamB,
          venue: venue,
          date: date,
          time: time,
          matchId: matchId,
        );
      } else if (isUpdate) {
        await RefereeStatKeeperTriggerService.triggerMatchRescheduled(
          staffId: match.statKeeperId!,
          teamA: teamA,
          teamB: teamB,
          newDate: date,
          newTime: time,
          venue: venue,
          matchId: matchId,
          isReferee: false,
        );
      }
    }
  }
}

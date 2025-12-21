import 'package:pffl_managment/core/models/game_model.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';

/// Handles data fetching and mapping for the Referee dashboard.
class RefereeDashboardRepository {
  const RefereeDashboardRepository();

  /// Fetch games assigned to the given [refereeId] that are still pending completion.
  Future<List<GameModel>> fetchAssignedGames(String refereeId) async {
    final allMatches = await MatchService.getAllMatches();

    final assignedMatches = allMatches.where((match) {
      return match.refereeId != null &&
          match.refereeId!.isNotEmpty &&
          match.refereeId == refereeId;
    }).toList();

    assignedMatches.sort((a, b) {
      final aDate = a.matchDateTime ?? _parseFallbackDate(a.date);
      final bDate = b.matchDateTime ?? _parseFallbackDate(b.date);
      return aDate.compareTo(bDate);
    });

    return assignedMatches
        .where((match) => match.status != MatchStatus.completed)
        .map((match) => _convertToGameModel(match, refereeId))
        .toList();
  }

  GameModel _convertToGameModel(MatchModel match, String refereeId) {
    final gameDate = match.matchDateTime ?? _parseFallbackDate(match.date);
    final isAssigned = match.refereeId != null &&
        match.refereeId!.isNotEmpty &&
        match.refereeId == refereeId;

    return GameModel(
      id: match.id ?? '',
      leagueName: match.leagueName,
      team1Name: match.homeTeam,
      team1Logo: match.homeTeamLogo.isNotEmpty ? match.homeTeamLogo : '',
      team2Name: match.awayTeam,
      team2Logo: match.awayTeamLogo.isNotEmpty ? match.awayTeamLogo : '',
      date: gameDate,
      time: match.time,
      isFeePaid: true,
      isMyGame: isAssigned,
    );
  }

  DateTime _parseFallbackDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length == 2) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final now = DateTime.now();
        var parsed = DateTime(now.year, month, day);
        if (parsed.isBefore(DateTime.now())) {
          parsed = DateTime(now.year + 1, month, day);
        }
        return parsed;
      }
    } catch (_) {
      // ignore parse issues and fall through to now
    }
    return DateTime.now();
  }
}

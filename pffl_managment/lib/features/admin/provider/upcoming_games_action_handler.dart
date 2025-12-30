import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/services/match_service.dart';
import 'package:pffl_managment/features/admin/provider/match_provider.dart';
import 'upcoming_games_notification_helper.dart';

class UpcomingGamesActionHandler {
  static Future<MatchModel> createMatch({
    required String leagueId,
    required String? leagueFormat,
    required String teamAId,
    required String teamAName,
    required String teamBId,
    required String teamBName,
    required DateTime date,
    required TimeOfDay time,
    String? venue,
    String? refereeId,
    String? statKeeperId,
    String? roundName,
  }) async {
    final matchProvider = MatchProvider();
    await matchProvider.initialize(leagueId);

    final success = await matchProvider.addMatch(
      teamOneId: teamAId,
      teamOneName: teamAName,
      teamTwoId: teamBId,
      teamTwoName: teamBName,
      matchDate: date,
      matchTime: time,
      venue: venue,
      refereeId: refereeId,
      statKeeperId: statKeeperId,
      roundName: roundName,
      format: leagueFormat,
    );

    if (!success) {
      throw Exception(matchProvider.errorText ?? 'Failed to create match');
    }

    final createdMatch = matchProvider.matches.last;

    // Additional notifications if needed (already mostly handled by MatchProvider but we have extra logic in Helper)
    await UpcomingGamesNotificationHelper.sendAssignmentNotifications(
      createdMatch,
    );

    return createdMatch;
  }

  static Future<MatchModel> updateMatch({
    required String matchId,
    required MatchModel editingMatch,
    required String teamAId,
    required String teamAName,
    required String teamBId,
    required String teamBName,
    required DateTime date,
    required TimeOfDay time,
    String? venue,
    String? refereeId,
    String? statKeeperId,
    String? roundName,
    String? gameNumber,
  }) async {
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final gameDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final matchData = {
      'teamA': teamAId,
      'teamAName': teamAName,
      'teamB': teamBId,
      'teamBName': teamBName,
      'gameDate': gameDateTime.toIso8601String(),
      'gameTime': timeStr,
      'venue': venue ?? '',
      'roundName': roundName ?? 'Group Stage',
      'gameNumber': gameNumber ?? '',
      if (refereeId != null) 'refereeId': refereeId,
      if (statKeeperId != null) 'statKeeperId': statKeeperId,
    };

    final updatedMatch = await MatchService.updateMatch(matchId, matchData);

    await UpcomingGamesNotificationHelper.sendAssignmentNotifications(
      updatedMatch,
      editingMatch: editingMatch,
      isUpdate: true,
    );

    return updatedMatch;
  }
}

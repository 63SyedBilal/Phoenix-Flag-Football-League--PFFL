import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/match_service.dart';

class UpcomingGamesValidationHelper {
  static Future<void> validateGameTime({
    required String leagueId,
    required DateTime date,
    required TimeOfDay time,
    String? excludeMatchId,
  }) async {
    try {
      final allGames = await MatchService.getMatchesByLeague(leagueId);
      final gamesOnSameDate = allGames.where((game) {
        if (game.id == excludeMatchId) return false;
        if (game.matchDateTime == null) return false;
        return game.matchDateTime!.year == date.year &&
            game.matchDateTime!.month == date.month &&
            game.matchDateTime!.day == date.day;
      }).toList();

      if (gamesOnSameDate.length >= 4) {
        throw Exception('Maximum 4 games can be scheduled per day');
      }

      final selectedTimeMinutes = time.hour * 60 + time.minute;
      for (final game in gamesOnSameDate) {
        if (game.matchDateTime != null) {
          final gameTimeMinutes =
              game.matchDateTime!.hour * 60 + game.matchDateTime!.minute;
          final timeDifference = (selectedTimeMinutes - gameTimeMinutes).abs();
          if (timeDifference < 30) {
            throw Exception(
              'Game time conflicts with existing game on this date',
            );
          }
        }
      }
    } catch (e) {
      if (e.toString().contains('Maximum 4 games') ||
          e.toString().contains('conflicts')) {
        rethrow;
      }
    }
  }
}

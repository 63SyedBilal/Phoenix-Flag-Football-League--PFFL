import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/admin_league_game_card.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/core/services/match_service.dart';

class AdminLeagueGamesSection extends StatelessWidget {
  final LeagueCreationModel league;

  const AdminLeagueGamesSection({
    super.key,
    required this.league,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MatchModel>>(
      future: MatchService.getMatchesByLeague(league.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Error loading games: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final matches = snapshot.data ?? [];
        
        // Sort matches by creation order (using id as proxy for creation time)
        // In MongoDB, ObjectIds contain timestamp, so sorting by id gives creation order
        final sortedMatches = List<MatchModel>.from(matches);
        sortedMatches.sort((a, b) {
          // Primary sort: by creation order (using id)
          if (a.id != null && b.id != null) {
            // MongoDB ObjectIds are sortable by creation time
            return a.id!.compareTo(b.id!);
          }
          // Fallback: if one has id and other doesn't, prioritize the one with id
          if (a.id != null) return -1;
          if (b.id != null) return 1;
          
          // Secondary fallback: use matchDateTime if available
          if (a.matchDateTime != null && b.matchDateTime != null) {
            return a.matchDateTime!.compareTo(b.matchDateTime!);
          }
          if (a.matchDateTime != null) return -1;
          if (b.matchDateTime != null) return 1;
          
          return 0;
        });

        // Calculate total games from sorted matches list
        int totalGames = sortedMatches.length;
        for (final match in sortedMatches) {
          if (match.gameNumber != null && match.gameNumber!.isNotEmpty) {
            final total = _extractTotalFromGameNumber(match.gameNumber!, totalGames);
            if (total > totalGames) {
              totalGames = total;
            }
          }
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (sortedMatches.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No games scheduled yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                ...sortedMatches.asMap().entries.map((entry) {
                  final index = entry.key;
                  final match = entry.value;
                  final sequenceNumber = index + 1;
                  
                  return AdminLeagueGameCard(
                    match: match,
                    league: league,
                    totalGames: totalGames,
                    sequenceNumber: sequenceNumber,
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  /// Extract total number from gameNumber string like "Game 8 of 12"
  int _extractTotalFromGameNumber(String gameNumber, int defaultTotal) {
    try {
      final parts = gameNumber.split(' of ');
      if (parts.length == 2) {
        return int.parse(parts[1]);
      }
    } catch (e) {
      // If parsing fails, return default
    }
    return defaultTotal;
  }
}

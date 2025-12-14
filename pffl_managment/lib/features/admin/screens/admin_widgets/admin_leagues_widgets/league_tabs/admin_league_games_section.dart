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
        
        // Sort matches by stage priority and date
        final sortedMatches = _sortMatchesByStage(matches);

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
                ...sortedMatches.map((match) => AdminLeagueGameCard(
                      match: match,
                      league: league,
                    )),
            ],
          ),
        );
      },
    );
  }

  /// Sort matches by stage priority (Final > Semi-Final > Quarter-Final > Group Stage)
  /// Then by date/time within each stage
  List<MatchModel> _sortMatchesByStage(List<MatchModel> matches) {
    final stagePriority = {
      'Final': 1,
      'Semi-Final': 2,
      'Quarter-Final': 3,
      'Group Stage': 4,
    };

    matches.sort((a, b) {
      final aStage = a.roundName ?? 'Group Stage';
      final bStage = b.roundName ?? 'Group Stage';
      final aPriority = stagePriority[aStage] ?? 99;
      final bPriority = stagePriority[bStage] ?? 99;

      // First sort by stage priority
      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }

      // Then sort by date/time within same stage
      if (a.matchDateTime != null && b.matchDateTime != null) {
        return a.matchDateTime!.compareTo(b.matchDateTime!);
      }
      if (a.matchDateTime != null) return -1;
      if (b.matchDateTime != null) return 1;
      return 0;
    });

    return matches;
  }
}

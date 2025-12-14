import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/unified_games_provider.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/admin_league_game_card.dart';
import 'package:provider/provider.dart';

class AdminLeagueGamesSection extends StatelessWidget {
  const AdminLeagueGamesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UnifiedGamesProvider>(
      builder: (context, gamesProvider, child) {
        final matches = gamesProvider.allGames;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Final Placeholder
              AdminLeagueGameCard(
                match: MatchModel(
                  id: 'final_placeholder',
                  leagueName: 'League',
                  homeTeam: 'TBD',
                  homeTeamLogo: '',
                  awayTeam: 'TBD',
                  awayTeamLogo: '',
                  date: '',
                  time: '',
                  status: MatchStatus.upcoming,
                  roundName: 'Final',
                ),
              ),
              // Semi-Final 1 Placeholder
              AdminLeagueGameCard(
                match: MatchModel(
                  id: 'semi_1_placeholder',
                  leagueName: 'League',
                  homeTeam: 'TBD',
                  homeTeamLogo: '',
                  awayTeam: 'TBD',
                  awayTeamLogo: '',
                  date: '',
                  time: '',
                  status: MatchStatus.upcoming,
                  roundName: 'Semi-Final',
                ),
              ),
              // Semi-Final 2 Placeholder
              AdminLeagueGameCard(
                match: MatchModel(
                  id: 'semi_2_placeholder',
                  leagueName: 'League',
                  homeTeam: 'TBD',
                  homeTeamLogo: '',
                  awayTeam: 'TBD',
                  awayTeamLogo: '',
                  date: '',
                  time: '',
                  status: MatchStatus.upcoming,
                  roundName: 'Semi-Final',
                ),
              ),
              // Actual Matches
              ...matches.map((match) => AdminLeagueGameCard(match: match)),
            ],
          ),
        );
      },
    );
  }
}

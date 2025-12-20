import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/admin_league_game_card.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_tabs/playoff_game_card.dart';
import 'package:pffl_managment/features/admin/providers/league_games_provider.dart';
import 'package:provider/provider.dart';

/// Games section that always displays 3 fixed cards: Semi-Final 1, Semi-Final 2, and Final
/// Teams are automatically populated based on points table
class AdminLeagueGamesSection extends StatelessWidget {
  final LeagueCreationModel league;

  const AdminLeagueGamesSection({
    super.key,
    required this.league,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = LeagueGamesProvider(league.id);
        provider.initialize();
        return provider;
      },
      child: _GamesSectionContent(league: league),
    );
  }
}

class _GamesSectionContent extends StatefulWidget {
  final LeagueCreationModel league;

  const _GamesSectionContent({required this.league});

  @override
  State<_GamesSectionContent> createState() => _GamesSectionContentState();
}

class _GamesSectionContentState extends State<_GamesSectionContent> {
  @override
  void initState() {
    super.initState();
    // Refresh when widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LeagueGamesProvider>(context, listen: false);
      provider.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeagueGamesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading games: ${provider.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Get semi-final and final data
          final semiFinal1 = provider.semiFinal1;
          final semiFinal2 = provider.semiFinal2;
          final finalMatch = provider.finalMatch;

          // Calculate total games for game numbering
          final allGames = provider.allGames;
          int totalGames = allGames.length;
          for (final game in allGames) {
            if (game.gameNumber != null && game.gameNumber!.isNotEmpty) {
              final total = _extractTotalFromGameNumber(game.gameNumber!, totalGames);
              if (total > totalGames) {
                totalGames = total;
              }
            }
          }
          // Ensure at least 12 games for display
          if (totalGames < 12) totalGames = 12;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Always show 3 fixed cards: Semi-Final 1, Semi-Final 2, Final
                
                // Semi-Final 1 Card - Always show, even if no teams yet
                PlayoffGameCard(
                  roundName: 'Semi - Final',
                  gameNumber: 'Semi - Final - Game ${_getSemiFinal1GameNumber(allGames)} of $totalGames',
                  game: semiFinal1?.game,
                  team1Name: semiFinal1?.game?.homeTeam ?? semiFinal1?.team1.teamName,
                  team1Logo: semiFinal1?.game?.homeTeamLogo ?? semiFinal1?.team1.teamLogo ?? '',
                  team2Name: semiFinal1?.game?.awayTeam ?? semiFinal1?.team2.teamName,
                  team2Logo: semiFinal1?.game?.awayTeamLogo ?? semiFinal1?.team2.teamLogo ?? '',
                  team1Score: semiFinal1?.game?.homeScore,
                  team2Score: semiFinal1?.game?.awayScore,
                  gameDate: semiFinal1?.game?.matchDateTime,
                  league: widget.league,
                  isTBD: semiFinal1 == null,
                ),

                // Semi-Final 2 Card - Always show, even if no teams yet
                PlayoffGameCard(
                  roundName: 'Semi - Final',
                  gameNumber: 'Semi - Final - Game ${_getSemiFinal2GameNumber(allGames)} of $totalGames',
                  game: semiFinal2?.game,
                  team1Name: semiFinal2?.game?.homeTeam ?? semiFinal2?.team1.teamName,
                  team1Logo: semiFinal2?.game?.homeTeamLogo ?? semiFinal2?.team1.teamLogo ?? '',
                  team2Name: semiFinal2?.game?.awayTeam ?? semiFinal2?.team2.teamName,
                  team2Logo: semiFinal2?.game?.awayTeamLogo ?? semiFinal2?.team2.teamLogo ?? '',
                  team1Score: semiFinal2?.game?.homeScore,
                  team2Score: semiFinal2?.game?.awayScore,
                  gameDate: semiFinal2?.game?.matchDateTime,
                  league: widget.league,
                  isTBD: semiFinal2 == null,
                ),

                // Final Card - Always show, with TBD if teams not determined
                PlayoffGameCard(
                  roundName: 'Final',
                  game: finalMatch?.game,
                  team1Name: finalMatch?.team1?.teamName ?? finalMatch?.game?.homeTeam,
                  team1Logo: finalMatch?.team1?.teamLogo ?? finalMatch?.game?.homeTeamLogo ?? '',
                  team2Name: finalMatch?.team2?.teamName ?? finalMatch?.game?.awayTeam,
                  team2Logo: finalMatch?.team2?.teamLogo ?? finalMatch?.game?.awayTeamLogo ?? '',
                  team1Score: finalMatch?.game?.homeScore,
                  team2Score: finalMatch?.game?.awayScore,
                  gameDate: finalMatch?.game?.matchDateTime,
                  league: widget.league,
                  isTBD: finalMatch == null || finalMatch.team1 == null || finalMatch.team2 == null,
                ),

                // Display other games (non-playoff games) below the 3 fixed cards
                const SizedBox(height: 16),
                ..._buildOtherGamesCards(allGames, widget.league, totalGames),
              ],
            ),
          );
        },
      
    );
  }

  /// Build cards for non-playoff games
  List<Widget> _buildOtherGamesCards(
    List<MatchModel> allGames,
    LeagueCreationModel league,
    int totalGames,
  ) {
    // Filter out playoff games
    final otherGames = allGames.where((game) {
      final roundName = game.roundName?.toLowerCase() ?? '';
      return roundName != 'semi-final 1' &&
             roundName != 'semi-final 2' &&
             roundName != 'semi - final 1' &&
             roundName != 'semi - final 2' &&
             roundName != 'final';
    }).toList();

    // Sort by creation order
    otherGames.sort((a, b) {
      if (a.id != null && b.id != null) {
        return a.id!.compareTo(b.id!);
      }
      if (a.id != null) return -1;
      if (b.id != null) return 1;
      if (a.matchDateTime != null && b.matchDateTime != null) {
        return a.matchDateTime!.compareTo(b.matchDateTime!);
      }
      return 0;
    });

    return otherGames.asMap().entries.map((entry) {
      final index = entry.key;
      final match = entry.value;
      final sequenceNumber = index + 1;
      
      return AdminLeagueGameCard(
        match: match,
        league: league,
        totalGames: totalGames,
        sequenceNumber: sequenceNumber,
      );
    }).toList();
  }

  /// Get game number for Semi-Final 1
  int _getSemiFinal1GameNumber(List<MatchModel> allGames) {
    // Find semi-final 1 game number or calculate
    for (final game in allGames) {
      if (game.roundName?.toLowerCase() == 'semi-final 1' ||
          game.roundName?.toLowerCase() == 'semi - final 1') {
        final seq = game.getSequenceNumber();
        if (seq != null) return seq;
      }
    }
    // Default to game 11 of 12 (assuming 12 total games)
    return 11;
  }

  /// Get game number for Semi-Final 2
  int _getSemiFinal2GameNumber(List<MatchModel> allGames) {
    // Find semi-final 2 game number or calculate
    for (final game in allGames) {
      if (game.roundName?.toLowerCase() == 'semi-final 2' ||
          game.roundName?.toLowerCase() == 'semi - final 2') {
        final seq = game.getSequenceNumber();
        if (seq != null) return seq;
      }
    }
    // Default to game 12 of 12 (assuming 12 total games)
    return 12;
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

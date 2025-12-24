import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/features/admin/providers/league_games_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/admin_league_game_card.dart';

import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_game_widgets/edit_upcomming_matches.dart';

/// Games section that displays playoff games first, then regular games
class AdminLeagueGamesSection extends StatelessWidget {
  final LeagueCreationModel league;

  const AdminLeagueGamesSection({super.key, required this.league});

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

        final allGames = provider.allGames;

        // Show empty state when no games exist
        if (allGames.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'No games created yet',
                style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
              ),
            ),
          );
        }
        final semiFinal1 = provider.semiFinal1;
        final semiFinal2 = provider.semiFinal2;
        final finalMatch = provider.finalMatch;

        // Calculate total games for numbering
        int totalGames = allGames.length;
        for (final game in allGames) {
          if (game.gameNumber != null && game.gameNumber!.isNotEmpty) {
            final total = _extractTotalFromGameNumber(
              game.gameNumber!,
              totalGames,
            );
            if (total > totalGames) totalGames = total;
          }
        }
        if (totalGames < 12) totalGames = 12;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Final card first
              _buildPlayoffCard(
                roundName: 'Final',
                gameNumber:
                    'Final - Game 1 of $totalGames', // Assuming final is game 1 of its round
                gameDate: finalMatch?.game?.matchDateTime,
                team1Name:
                    finalMatch?.team1?.teamName ?? finalMatch?.game?.homeTeam,
                team1Logo:
                    finalMatch?.team1?.teamLogo ??
                    finalMatch?.game?.homeTeamLogo ??
                    '',
                team2Name:
                    finalMatch?.team2?.teamName ?? finalMatch?.game?.awayTeam,
                team2Logo:
                    finalMatch?.team2?.teamLogo ??
                    finalMatch?.game?.awayTeamLogo ??
                    '',
                match: finalMatch?.game,
                isTBD: finalMatch?.team1 == null || finalMatch?.team2 == null,
              ),
              const SizedBox(height: 16),

              // Semi-Final 1
              _buildPlayoffCard(
                roundName: 'Semi - Final',
                gameNumber:
                    'Semi - Final - Game ${_getSemiFinal1GameNumber(allGames)} of $totalGames',
                gameDate: semiFinal1?.game?.matchDateTime,
                team1Name:
                    semiFinal1?.game?.homeTeam ?? semiFinal1?.team1.teamName,
                team1Logo:
                    semiFinal1?.game?.homeTeamLogo ??
                    semiFinal1?.team1.teamLogo ??
                    '',
                team2Name:
                    semiFinal1?.game?.awayTeam ?? semiFinal1?.team2.teamName,
                team2Logo:
                    semiFinal1?.game?.awayTeamLogo ??
                    semiFinal1?.team2.teamLogo ??
                    '',
                match: semiFinal1?.game,
                isTBD: semiFinal1 == null,
              ),
              const SizedBox(height: 16),

              // Semi-Final 2
              _buildPlayoffCard(
                roundName: 'Semi - Final',
                gameNumber:
                    'Semi - Final - Game ${_getSemiFinal2GameNumber(allGames)} of $totalGames',
                gameDate: semiFinal2?.game?.matchDateTime,
                team1Name:
                    semiFinal2?.game?.homeTeam ?? semiFinal2?.team1.teamName,
                team1Logo:
                    semiFinal2?.game?.homeTeamLogo ??
                    semiFinal2?.team1.teamLogo ??
                    '',
                team2Name:
                    semiFinal2?.game?.awayTeam ?? semiFinal2?.team2.teamName,
                team2Logo:
                    semiFinal2?.game?.awayTeamLogo ??
                    semiFinal2?.team2.teamLogo ??
                    '',
                match: semiFinal2?.game,
                isTBD: semiFinal2 == null,
              ),
              const SizedBox(height: 16),

              // Regular games section
              ..._buildRegularGamesCards(allGames, totalGames),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildRegularGamesCards(
    List<MatchModel> allGames,
    int totalGames,
  ) {
    // Filter out playoff games
    final regularGames = allGames.where((game) {
      final roundName = game.roundName?.toLowerCase() ?? '';
      return roundName != 'semi-final 1' &&
          roundName != 'semi-final 2' &&
          roundName != 'semi - final 1' &&
          roundName != 'semi - final 2' &&
          roundName != 'final';
    }).toList();

    // Sort by date (chronological order)
    regularGames.sort((a, b) {
      if (a.matchDateTime != null && b.matchDateTime != null) {
        return a.matchDateTime!.compareTo(b.matchDateTime!);
      }
      return 0;
    });

    // Use asMap to get index for sequential numbering
    return regularGames.asMap().entries.map((entry) {
      final index = entry.key;
      final match = entry.value;

      // Sequential game number (1, 2, 3, ...)
      final gameSeq = index + 1;
      // Total games count for this league
      final totalCount = allGames.length;

      // Use AdminLeagueGameCard to enable edit functionality
      return AdminLeagueGameCard(
        match: match,
        league: widget.league,
        totalGames: totalCount,
        sequenceNumber: gameSeq,
      );
    }).toList();
  }

  int _getSemiFinal1GameNumber(List<MatchModel> allGames) {
    for (final game in allGames) {
      if (game.roundName?.toLowerCase() == 'semi-final 1' ||
          game.roundName?.toLowerCase() == 'semi - final 1') {
        final seq = game.getSequenceNumber();
        if (seq != null) return seq;
      }
    }
    return 11;
  }

  int _getSemiFinal2GameNumber(List<MatchModel> allGames) {
    for (final game in allGames) {
      if (game.roundName?.toLowerCase() == 'semi-final 2' ||
          game.roundName?.toLowerCase() == 'semi - final 2') {
        final seq = game.getSequenceNumber();
        if (seq != null) return seq;
      }
    }
    return 12;
  }

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

  Widget _buildPlayoffCard({
    required String roundName,
    String? gameNumber,
    DateTime? gameDate,
    String? team1Name,
    String? team1Logo,
    String? team2Name,
    String? team2Logo,
    MatchModel? match,
    bool isTBD = false,
  }) {
    final displayTeam1 = team1Name ?? 'TBD';
    final displayTeam2 = team2Name ?? 'TBD';
    final displayTeam1Logo = team1Logo ?? '';
    final displayTeam2Logo = team2Logo ?? '';
    final userRole = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).userRole.toLowerCase();
    final isAdmin = userRole == 'admin' || userRole == 'superadmin';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildPlayoffTeamSection(
                  displayTeam1,
                  displayTeam1Logo,
                  isLeft: true,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        roundName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (gameDate != null) ...[
                        Text(
                          _formatDate(gameDate),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _formatTime(gameDate),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildPlayoffTeamSection(
                  displayTeam2,
                  displayTeam2Logo,
                  isLeft: false,
                ),
              ],
            ),
          ),
          if (isAdmin) ...[
            const Divider(
              height: 1,
              indent: 12,
              endIndent: 12,
              color: Color(0xFFE5E7EB),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  // Create a placeholder match for TBD playoff games
                  final matchToEdit =
                      match ??
                      MatchModel(
                        leagueName: widget.league.leagueName,
                        homeTeam: displayTeam1,
                        homeTeamLogo: displayTeam1Logo,
                        awayTeam: displayTeam2,
                        awayTeamLogo: displayTeam2Logo,
                        date: gameDate != null
                            ? '${gameDate.day}/${gameDate.month}/${gameDate.year}'
                            : 'TBD',
                        time: gameDate != null
                            ? '${gameDate.hour}:${gameDate.minute.toString().padLeft(2, '0')}'
                            : 'TBD',
                        matchDateTime: gameDate,
                        roundName: roundName,
                        gameNumber: gameNumber,
                        leagueId: widget.league.id,
                      );

                  final updated = await showDialog<bool>(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: EditUpcommingMatches(
                        match: matchToEdit,
                        hideTeamSelection: true,
                      ),
                    ),
                  );
                  if (updated == true && context.mounted) {
                    Provider.of<LeagueGamesProvider>(
                      context,
                      listen: false,
                    ).refresh();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Game',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff0F173E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xff0F173E),
                        size: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayoffTeamSection(
    String name,
    String logo, {
    required bool isLeft,
  }) {
    return Row(
      children: [
        if (isLeft) ...[
          _buildPlayoffTeamLogo(logo),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
        ] else ...[
          Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(width: 8),
          _buildPlayoffTeamLogo(logo),
        ],
      ],
    );
  }

  Widget _buildPlayoffTeamLogo(String logo) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: logo.isNotEmpty ? null : Colors.black,
        shape: BoxShape.circle,
      ),
      child: logo.isNotEmpty
          ? ClipOval(
              child: Image.network(
                logo,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.shield, size: 16, color: Colors.white),
              ),
            )
          : const Icon(Icons.shield, size: 16, color: Colors.white),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period PKT';
  }
}

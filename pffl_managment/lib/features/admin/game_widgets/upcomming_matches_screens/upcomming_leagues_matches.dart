import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/unified_games_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/all_matches_screen.dart';
import 'package:pffl_managment/core/models/game_model.dart';

import 'package:pffl_managment/features/admin/provider/league_detail_provider.dart';

// Card widget with league name display
class UpcommingGamesCardWidget extends StatelessWidget {
  final MatchModel match;

  const UpcommingGamesCardWidget({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
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
                _buildTeamSection(
                  match.homeTeam,
                  match.homeTeamLogo,
                  isLeft: true,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        match.roundName ?? 'Match',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        match.date,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        match.time,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildTeamSection(
                  match.awayTeam,
                  match.awayTeamLogo,
                  isLeft: false,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showEditGameDialog(context, match),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Game',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(String name, String logo, {required bool isLeft}) {
    return Row(
      children: [
        if (isLeft) ...[
          _buildTeamLogo(logo),
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
          _buildTeamLogo(logo),
        ],
      ],
    );
  }

  Widget _buildTeamLogo(String logo) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: logo.isNotEmpty ? null : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: logo.isNotEmpty
          ? ClipOval(
              child: Image.network(
                logo,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.group, size: 16, color: Colors.white54),
              ),
            )
          : const Icon(Icons.group, size: 16, color: Colors.white54),
    );
  }

  void _showEditGameDialog(BuildContext context, MatchModel match) {
    // Placeholder for edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality not implemented yet')),
    );
  }

  Widget _buildPillButton({
    required String text,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isOutlined ? Colors.white : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: isOutlined
            ? Border.all(color: const Color(0xFF000000), width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isOutlined ? const Color(0xFF000000) : Colors.white,
                fontFamily: 'Lato',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UpcommingGames extends StatelessWidget {
  final String? leagueId;
  const UpcommingGames({super.key, this.leagueId});

  @override
  Widget build(BuildContext context) {
    return Consumer<UnifiedGamesProvider>(
      builder: (context, gamesProvider, child) {
        final leagueDetailProvider = Provider.of<LeagueDetailProvider>(context);

        // If leagueId is provided, use LeagueDetailProvider, otherwise use UnifiedGamesProvider
        final matches = leagueId != null
            ? leagueDetailProvider.getUpcomingGames()
            : gamesProvider.upcomingGamesPerLeague;

        // Always trigger data fetch on first build to ensure fresh data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (leagueId == null &&
              gamesProvider.allGames.isEmpty &&
              !gamesProvider.isLoading) {
            debugPrint(
              '🔄 UpcommingGames: Triggering data fetch via UnifiedGamesProvider...',
            );
            gamesProvider.fetchAllMatches();
          }
        });

        // Debug print to check data
        debugPrint('🔍 UpcommingGames Widget Build:');
        debugPrint(
          '   - Total games in provider: ${gamesProvider.allGames.length}',
        );
        debugPrint('   - Upcoming games per league: ${matches.length}');
        debugPrint('   - Is loading: ${gamesProvider.isLoading}');

        if (matches.isNotEmpty) {
          debugPrint(
            '   - First entry: ${matches.first.leagueName} - ${matches.first.homeTeam} vs ${matches.first.awayTeam}',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Upcoming Games', style: AppTextStyles.headlineSmall),
                if (matches.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllMatchesScreen(
                            matches: matches
                                .map(
                                  (m) => GameModel(
                                    id: m.id ?? '',
                                    leagueName: m.leagueName,
                                    team1Name: m.homeTeam,
                                    team1Logo: m.homeTeamLogo,
                                    team2Name: m.awayTeam,
                                    team2Logo: m.awayTeamLogo,
                                    date: m.matchDateTime ?? DateTime.now(),
                                    time: m.time,
                                    isFeePaid: false,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'View more',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            if (matches.isEmpty)
              _buildEmptyState(context)
            else
              ...matches.map(
                (match) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: UpcommingGamesCardWidget(match: match),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Upcoming Games',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no upcoming games scheduled at the moment.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

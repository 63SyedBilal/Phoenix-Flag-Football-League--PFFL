import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/unified_games_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/all_matches_screen.dart';
import 'package:pffl_managment/core/models/game_model.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_game_widgets/edit_upcomming_matches.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';

import 'package:pffl_managment/features/admin/provider/league_detail_provider.dart';

// Card widget with league name display
class UpcommingGamesCardWidget extends StatelessWidget {
  final MatchModel match;

  const UpcommingGamesCardWidget({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
            child: Row(
              children: [
                Text(
                  match.leagueName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF111827),
                    fontFamily: 'Lato',
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
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
                      if (match.status == MatchStatus.upcoming) ...[
                        Text(
                          match.date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF111827),
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          match.time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF111827),
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ] else ...[
                        // Score display for Live/Completed
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${match.homeScore ?? 0}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Lato',
                                color: Color(0xFF111827),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                '-',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Text(
                              '${match.awayScore ?? 0}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Lato',
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: match.status == MatchStatus.live
                                ? Colors.red
                                : Colors.grey[700],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            match.status == MatchStatus.live ? 'LIVE' : 'FINAL',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
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
          if (isAdmin) ...[
            const Divider(
              indent: 12,
              endIndent: 12,
              height: 1,
              color: Color(0xFFE5E7EB),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final updated = await showDialog<bool>(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: EditUpcommingMatches(match: match),
                    ),
                  );
                  if (updated == true && context.mounted) {
                    Provider.of<UnifiedGamesProvider>(
                      context,
                      listen: false,
                    ).fetchAllMatches();
                    // Also refresh league detail provider if possible
                    try {
                      Provider.of<LeagueDetailProvider>(
                        context,
                        listen: false,
                      ).refresh();
                    } catch (_) {}
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
                          fontFamily: 'Lato',
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xff0F173E),
                        size: 8,
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

  Widget _buildTeamSection(String name, String logo, {required bool isLeft}) {
    return Row(
      children: [
        if (isLeft) ...[
          _buildTeamLogo(logo),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              fontFamily: 'Lato',
            ),
          ),
        ] else ...[
          _buildTeamLogo(logo),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              fontFamily: 'Lato',
            ),
          ),
          // const SizedBox(width: 8),
          // _buildTeamLogo(logo),
        ],
      ],
    );
  }

  Widget _buildTeamLogo(String logo) {
    return Container(
      width: 32,
      height: 32,
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
}

class UpcommingGames extends StatelessWidget {
  final String? leagueId;
  const UpcommingGames({super.key, this.leagueId});

  @override
  Widget build(BuildContext context) {
    return Consumer<UnifiedGamesProvider>(
      builder: (context, gamesProvider, child) {
        final leagueDetailProvider = Provider.of<LeagueDetailProvider>(context);
        final matches = leagueId != null
            ? leagueDetailProvider.getUpcomingGames()
            : gamesProvider.upcomingGamesPerLeague;

        // Always trigger data fetch on first build to ensure fresh data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (leagueId == null &&
              !gamesProvider.isInitialized &&
              !gamesProvider.isLoading) {
            gamesProvider.fetchAllMatches();
          }
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Games',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: const Color(0xff0F173E),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Lato',
                  ),
                ),
                if (leagueId != null)
                  InkWell(
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
                        const Icon(
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No upcoming games scheduled',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
            fontFamily: 'Lato',
          ),
        ),
      ),
    );
  }
}

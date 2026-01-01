import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pffl_managment/features/key_players/league_key_players_section.dart';
import 'package:pffl_managment/features/sponsors/screens/sponsor_banner_screen.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/screens/games/game_tabs/game_tabs_provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/features/admin/provider/league_detail_provider.dart';

class SummaryTab extends StatelessWidget {
  const SummaryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameTabsProvider>(context);
    final match = provider.match;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Game Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lato',
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),

          _buildPerformanceCard(match),

          const SizedBox(height: 24),

          const Text(
            'Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lato',
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          _buildActionsTimeline(match),

          const SizedBox(height: 24),

          // Game Information
          const Text(
            'Game Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lato',
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          _buildGameInfoCard(match),

          const SizedBox(height: 24),

          // Upcoming Games Header
          _buildSectionHeader('Upcoming Games', 'View More', () {}),
          const SizedBox(height: 16),
          if (provider.upcomingGames.isEmpty && !provider.isLoading)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Text(
                'No upcoming games found for these teams.',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Lato',
                  fontSize: 14,
                ),
              ),
            )
          else if (provider.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ...provider.upcomingGames.map(
              (game) => Column(
                children: [
                  _buildMatchCard(game, context),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          const SizedBox(height: 24),

          SponsorBannerScreen(),

          _FilteredLeaderboardSection(
            selectedTeam: _getSelectedTeam(provider.selectedTabIndex),
          ),
          const SizedBox(height: 12),
          LeagueKeyPlayersSection(),
          SizedBox(height: 24),
          SponsorBannerScreen(),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(MatchModel match) {
    final home = match.homeTeamStats;
    final away = match.awayTeamStats;

    // Helper to get string value safely
    String h(int? val) => (val ?? 0).toString();
    String a(int? val) => (val ?? 0).toString();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                _buildTeamLogo(match.homeTeamLogo),
                const SizedBox(height: 8),
                Text(
                  match.homeScore?.toString() ?? '0',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lato',
                  ),
                ),
              ],
            ),
            const Text(
              'Team Performance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
                color: Color(0xFF111827),
              ),
            ),
            Column(
              children: [
                _buildTeamLogo(match.awayTeamLogo),
                const SizedBox(height: 8),
                Text(
                  match.awayScore?.toString() ?? '0',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatRow(h(home?.catches), 'Catches', a(away?.catches)),
        _buildStatRow(
          h(home?.catchesYards),
          'Catches Yards',
          a(away?.catchesYards),
        ),
        _buildStatRow(h(home?.rushes), 'Rushes', a(away?.rushes)),
        _buildStatRow(h(home?.rushesYards), 'Rush Yards', a(away?.rushesYards)),
        _buildStatRow(
          h(home?.passAttempts),
          'Pass Attempts',
          a(away?.passAttempts),
        ),
        _buildStatRow(
          h(home?.completions),
          'Completions',
          a(away?.completions),
        ),
        _buildStatRow(h(home?.tds), 'Touchdowns', a(away?.tds)),
        _buildStatRow(h(home?.flagPull), 'Flag Pulls', a(away?.flagPull)),
        _buildStatRow(h(home?.safety), 'Safety', a(away?.safety)),
        _buildStatRow(
          h(home?.conversionPoints),
          'Conversion Points',
          a(away?.conversionPoints),
        ),
      ],
    );
  }

  Widget _buildStatRow(String val1, String label, String val2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 30,
            child: Text(
              val1,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lato',
              ),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF000000),
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              val2,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'Lato',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLogo(String url) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) =>
              Icon(Icons.shield, size: 16, color: Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildActionsTimeline(MatchModel match) {
    final actions = match.actions;

    if (actions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Text(
          'No actions recorded for this game yet.',
          style: TextStyle(
            color: Colors.grey,
            fontFamily: 'Lato',
            fontSize: 14,
          ),
        ),
      );
    }

    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 20,
          bottom: 20,
          child: Center(
            child: Container(width: 2, color: const Color(0xFFE5E7EB)),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: actions.map((action) {
            final type = action['type'] ?? action['actionType'] ?? 'unknown';
            final teamId = action['teamId'];
            final playerId = action['playerId'];
            final isHome = teamId == match.homeTeamId; // Assuming home is left

            // Determine label and icon
            String label = '';
            IconData icon = Icons.circle;
            Color color = const Color(0xFF1F2937);

            switch (type.toString().toLowerCase()) {
              case 'touchdown':
              case 'td':
                label = 'Touchdown';
                icon = Icons.sports_football;
                break;
              case 'extrapoint':
              case 'conversion':
                label = 'Conversion';
                icon = Icons.add_circle_outline;
                break;
              case 'safety':
                label = 'Safety';
                icon = Icons.warning_amber_rounded;
                color = Colors.amber;
                break;
              case 'interception':
              case 'int':
                label = 'Interception';
                icon = Icons.swap_horiz;
                break;
              case 'sack':
                label = 'Sack';
                icon = Icons.arrow_downward;
                break;
              // Add milestones
              case 'halftime':
                return Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Half Time',
                      style: TextStyle(fontSize: 12, fontFamily: 'Lato'
                      ,fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              case 'fulltime':
                return Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Full Time',
                      style: TextStyle(fontSize: 12, fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              default:
                label = type.toString();
                icon = Icons.circle;
            }

            // Lookup player name
            String playerName = 'Unknown Player';
            String role = ''; // Can look up position if available

            // Try to find in stats
            final stats = isHome ? match.homeTeamStats : match.awayTeamStats;
            if (stats != null && playerId != null) {
              try {
                final p = stats.playerStats.firstWhere(
                  (ps) => ps.playerId == playerId,
                );
                playerName = p.playerName;
                // Position not in PlayerStatModel, but maybe keep it empty or generic
              } catch (_) {
                // Try looking in the other team just in case IDs are mixed
                final otherStats = isHome
                    ? match.awayTeamStats
                    : match.homeTeamStats;
                if (otherStats != null) {
                  try {
                    final p = otherStats.playerStats.firstWhere(
                      (ps) => ps.playerId == playerId,
                    );
                    playerName = p.playerName;
                  } catch (_) {}
                }
              }
            }
            // If still unknown and action has 'playerName', use it
            if (playerName == 'Unknown Player' &&
                action['playerName'] != null) {
              playerName = action['playerName'];
            }

            return _buildActionItem(
              playerName,
              role,
              icon,
              label,
              isHome, // Left if home
              color: color,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    String name,
    String role,
    IconData icon,
    String label,
    bool isLeft, {
    Color color = const Color(0xFF1F2937),
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: isLeft
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Lato',
                          color: Color(0xFF000000
                          ),
                        ),
                      ),
                      Text(
                        role,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 12),
          // ... existing code ...
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              if (label.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Lato',
                      height: 1.0,
                      letterSpacing: 0,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: !isLeft
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Lato',
                        ),
                      ),
                      Text(
                        role,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontFamily: 'Lato',
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfoCard(MatchModel match) {
    final gameNo = match.gameNumber != null ? 'Game ${match.gameNumber}: ' : '';
    final league = match.leagueName;

    // Resolve Toss text
    String tossText = "Toss information not available.";
    if (match.tossWinnerId != null) {
      String winner = "Unknown Team";
      if (match.tossWinnerId == match.homeTeamId) winner = match.homeTeam;
      if (match.tossWinnerId == match.awayTeamId) winner = match.awayTeam;

      final choice = match.tossChoice ?? "play";
      tossText = "$winner won the toss and chose to $choice.";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$gameNo${match.homeTeam} vs ${match.awayTeam} | League: $league",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Lato',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Format: ${match.format ?? 'N/A'} | Venue: ${match.venue ?? 'N/A'}",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Lato',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Date: ${match.date} | Time: ${match.time}",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Lato',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Toss: $tossText",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Lato',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String actionText,
    VoidCallback onTap,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lato',
            color: Color(0xFF111827),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Text(
                actionText,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Lato',
                  color: Color(0xFF4B5563),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: Color(0xFF4B5563),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatchCard(MatchModel game, BuildContext context) {
    // Get user role
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.userRole.toLowerCase() == 'admin';

    // Extract details
    final team1 = game.homeTeam;
    final team2 = game.awayTeam;
    final date = game.date;
    final time = game.time;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Team 1
              SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: ClipOval(
                        child: ColoredBox(
                          color: const Color(0xFFF3F4F6),
                          child: game.homeTeamLogo.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: game.homeTeamLogo,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => const Icon(
                                    Icons.sports_football,
                                    size: 16,
                                    color: Color(0xFF6B7280),
                                  ),
                                )
                              : const Icon(
                                  Icons.sports_football,
                                  size: 16,
                                  color: Color(0xFF6B7280),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        team1,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 10,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              // Team 2
              SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        team2,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: ClipOval(
                        child: ColoredBox(
                          color: const Color(0xFFF3F4F6),
                          child: game.awayTeamLogo.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: game.awayTeamLogo,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => const Icon(
                                    Icons.sports_football,
                                    size: 16,
                                    color: Color(0xFF6B7280),
                                  ),
                                )
                              : const Icon(
                                  Icons.sports_football,
                                  size: 16,
                                  color: Color(0xFF6B7280),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (isAdmin) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  AppRoutes.adminEditMatch,
                  arguments: game,
                );
                if (context.mounted) {
                  Provider.of<GameTabsProvider>(
                    context,
                    listen: false,
                  ).initialize();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Game',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue[700], // Active color
                    ),
                  ),
                  const Icon(Icons.edit, size: 14, color: Colors.blue),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getSelectedTeam(int tabIndex) {
    // Based on the tab structure in game_details_screen.dart:
    // 0: Summary, 1: Leaderboard, 2: Players, 3: Officials
    // For now, we'll return an empty string to show all teams
    // In a more advanced implementation, you could map specific tabs to teams
    return '';
  }

  Widget _FilteredLeaderboardSection({required String selectedTeam}) {
    return Consumer2<GameTabsProvider, LeagueDetailProvider>(
      builder: (context, gameProvider, leagueProvider, child) {
        final match = gameProvider.match;
        final allTeamStandings = leagueProvider.getLeaderboard();
        
        // Debug print to see what we're working with
        print('🏈 Match teams: ${match.homeTeam} vs ${match.awayTeam}');
        print('🏈 Available teams in standings: ${allTeamStandings.map((s) => s.teamName).toList()}');
        
        // Filter standings to show only the two teams from the current match
        final matchTeamStandings = allTeamStandings.where((standing) {
          final isHomeTeam = standing.teamName.toLowerCase().trim() == match.homeTeam.toLowerCase().trim();
          final isAwayTeam = standing.teamName.toLowerCase().trim() == match.awayTeam.toLowerCase().trim();
          print('🏈 Checking ${standing.teamName} - Home: $isHomeTeam, Away: $isAwayTeam');
          return isHomeTeam || isAwayTeam;
        }).toList();
        
        print('🏈 Found ${matchTeamStandings.length} matching teams');
        
        if (matchTeamStandings.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Text(
              'No match data available',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Lato',
                fontSize: 14,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Match Leaderboard',
                  style: TextStyle(fontFamily: 'Lato', fontSize: 16),
                ),
                const Spacer(),
                Text(
                  'View Leaderboard',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 10,
                    color: Color(0xff0F173E),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Color(0xff0F173E),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: Colors.white),
              child: Scrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      // Header row with all columns
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xffe3ecfb),
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 40,
                              child: Text(
                                'Rank',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Lato',
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 120,
                              child: Text(
                                'Team',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Lato',
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const SizedBox(
                              width: 30,
                              child: Text(
                                'W',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Lato',
                                  color: Color(0xFF000000),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const SizedBox(
                              width: 30,
                              child: Text(
                                'D',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Lato',
                                  color: Color(0xFF000000),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const SizedBox(
                              width: 30,
                              child: Text(
                                'L',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Lato',
                                  color: Color(0xFF000000),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const SizedBox(
                              width: 30,
                              child: Text(
                                'OD',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Lato',
                                  color: Color(0xFF000000),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const SizedBox(
                              width: 30,
                              child: Text(
                                'PS',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Lato',
                                  color: Color(0xFF000000),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const SizedBox(
                              width: 30,
                              child: Text(
                                'PA',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Lato',
                                  color: Color(0xFF000000),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const SizedBox(
                              width: 30,
                              child: Text(
                                'PTA',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Lato',
                                  color: Color(0xFF000000),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Show only the two teams from the current match
                      ...matchTeamStandings.map((standing) => _buildLeaderboardRowFull(
                        standing.rank.toString(),
                        standing.teamName,
                        standing.wins.toString(),
                        standing.draws.toString(),
                        standing.losses.toString(),
                        standing.pointsDifference.toString(),
                        standing.pointsScored.toString(),
                        standing.pointsAgainst.toString(),
                        standing.points.toString(),
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLeaderboardRowFull(
    String rank,
    String team,
    String wins,
    String draws,
    String losses,
    String od,
    String ps,
    String pa,
    String pta,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE5E7EB).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              rank,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Lato',
                color: Color(0xFF000000),
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield, size: 16, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    team,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Lato',
                      color: Color(0xFF000000),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 30,
            child: Text(
              wins,
              style: const TextStyle(
                 fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Lato',
                color: Color(0xFF000000),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 30,
            child: Text(
              draws,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Lato',
                color: Color(0xFF000000),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 30,
            child: Text(
              losses,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Lato',
                color: Color(0xFF000000),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 30,
            child: Text(
              od,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Lato',
                color: Color(0xFF000000),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 30,
            child: Text(
              ps,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Lato',
                color: Color(0xFF000000),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 30,
            child: Text(
              pa,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Lato',
                color: Color(0xFF000000),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 30,
            child: Text(
              pta,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Lato',
                color: Color(0xFF000000),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

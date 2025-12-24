import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/core/utils/date_formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_game_widgets/edit_upcomming_matches.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/screens/games/game_tabs/game_details_screen.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/core/providers/unified_games_provider.dart';
import 'package:pffl_managment/features/admin/provider/league_detail_provider.dart';
import 'package:pffl_managment/features/admin/providers/league_games_provider.dart';

/// Game card widget for Semi-Final and Final matches
/// Matches the exact design from the provided image
class PlayoffGameCard extends StatelessWidget {
  final String roundName; // "Semi - Final", "Final", etc.
  final String? gameNumber; // "Game 8 of 12", etc.
  final MatchModel? game; // Existing game data if available
  final String? team1Name;
  final String? team1Logo;
  final String? team2Name;
  final String? team2Logo;
  final int? team1Score;
  final int? team2Score;
  final DateTime? gameDate;
  final LeagueCreationModel league;
  final bool
  isTBD; // True if teams are TBD (for Final before semi-finals complete)

  const PlayoffGameCard({
    super.key,
    required this.roundName,
    this.gameNumber,
    this.game,
    this.team1Name,
    this.team1Logo,
    this.team2Name,
    this.team2Logo,
    this.team1Score,
    this.team2Score,
    this.gameDate,
    required this.league,
    this.isTBD = false,
  });

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).userRole.toLowerCase();
    final isAdmin = userRole == 'admin' || userRole == 'superadmin';

    final bool isCompleted =
        game != null &&
        game!.status == MatchStatus.completed &&
        team1Score != null &&
        team2Score != null;

    if (isCompleted) {
      return _buildCompletedCard(context);
    } else {
      return _buildUpcomingCard(context, isAdmin);
    }
  }

  Widget _buildCompletedCard(BuildContext context) {
    final formattedDate = gameDate != null
        ? DateFormatter.formatGameDate(gameDate!)
        : (game?.date ?? '');

    // Format date as "Sun 29 Oct" style
    String displayDate = formattedDate;
    if (gameDate != null) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
      // weekday is 1-7 (Monday=1, Sunday=7), convert to 0-6 for array index
      // Monday=1 -> index 0, Sunday=7 -> index 6
      final weekdayIndex = gameDate!.weekday - 1;
      displayDate =
          '${weekdays[weekdayIndex]} ${gameDate!.day} ${months[gameDate!.month - 1]}';
    }

    return GestureDetector(
      onTap: () {
        if (game != null && game!.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameDetailsScreen(match: game!),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF000000).withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Round name with game number and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    gameNumber ?? roundName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600, // Bold as per design
                      color: Color(0xFF111827),
                      fontFamily: 'Lato',
                    ),
                  ),
                ),
                Text(
                  displayDate,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600, // Bold as per design
                    color: Color(0xFF111827),
                    fontFamily: 'Lato',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Team 1 row (Home team - gray text)
            _buildTeamRow(
              flagUrl: team1Logo ?? '',
              teamName: team1Name ?? '',
              score: team1Score,
              isHomeTeam: true,
            ),
            const SizedBox(height: 12),
            // Team 2 row (Away team - black text)
            _buildTeamRow(
              flagUrl: team2Logo ?? '',
              teamName: team2Name ?? '',
              score: team2Score,
              isHomeTeam: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, bool isAdmin) {
    final formattedDate = gameDate != null
        ? DateFormatter.formatGameDate(gameDate!)
        : (game?.date ?? '');

    // Format date as "Sun 29 Oct" style
    String displayDate = formattedDate;
    String displayTime = game?.time ?? '';

    if (gameDate != null) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
      // weekday is 1-7 (Monday=1, Sunday=7), convert to 0-6 for array index
      final weekdayIndex = gameDate!.weekday - 1;
      displayDate =
          '${weekdays[weekdayIndex]} ${gameDate!.day} ${months[gameDate!.month - 1]}';

      // Format time if available
      if (game?.matchDateTime != null) {
        final hour = game!.matchDateTime!.hour > 12
            ? game!.matchDateTime!.hour - 12
            : (game!.matchDateTime!.hour == 0 ? 12 : game!.matchDateTime!.hour);
        final period = game!.matchDateTime!.hour >= 12 ? 'PM' : 'AM';
        final minute = game!.matchDateTime!.minute.toString().padLeft(2, '0');
        displayTime = '$hour:$minute $period PKT';
      } else if (game?.time != null && game!.time.isNotEmpty) {
        // Use time string directly if available
        displayTime = game!.time;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF000000).withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              children: [
                // Round name (centered, smaller font for Final)
                if (roundName.toLowerCase() == 'final') ...[
                  Text(
                    'Final',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Lato',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                ],
                // Date and time (centered)
                Text(
                  displayDate.isNotEmpty ? displayDate : 'TBD',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF374151),
                    fontFamily: 'Lato',
                  ),
                  textAlign: TextAlign.center,
                ),
                if (displayTime.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    displayTime,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Lato',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                // Teams row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Team 1 (or TBD)
                    if (isTBD || team1Name == null || team1Name!.isEmpty) ...[
                      _buildTBDTeam(),
                      const SizedBox(width: 16),
                      _buildTBDTeam(),
                    ] else ...[
                      _buildTeamFlag(team1Logo ?? ''),
                      const SizedBox(width: 8),
                      Text(
                        team1Name!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                          fontFamily: 'Lato',
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildTeamFlag(team2Logo ?? ''),
                      const SizedBox(width: 8),
                      Text(
                        team2Name ?? 'TBD',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                          fontFamily: 'Lato',
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isAdmin) ...[
            Container(
              height: 1,
              color: const Color(0xFFE0E0E0),
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  // Create a placeholder match for TBD games
                  final matchToEdit =
                      game ??
                      MatchModel(
                        leagueName: league.leagueName,
                        homeTeam: team1Name ?? 'TBD',
                        homeTeamLogo: team1Logo ?? '',
                        awayTeam: team2Name ?? 'TBD',
                        awayTeamLogo: team2Logo ?? '',
                        date: gameDate != null
                            ? '${gameDate!.day}/${gameDate!.month}/${gameDate!.year}'
                            : 'TBD',
                        time: gameDate != null
                            ? '${gameDate!.hour}:${gameDate!.minute.toString().padLeft(2, '0')}'
                            : 'TBD',
                        matchDateTime: gameDate,
                        roundName: roundName,
                        gameNumber: gameNumber,
                        leagueId: league.id,
                      );

                  final updated = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: EditUpcommingMatches(
                          match: matchToEdit,
                          hideTeamSelection: true,
                        ),
                      );
                    },
                  );
                  if (updated == true && context.mounted) {
                    try {
                      Provider.of<UnifiedGamesProvider>(
                        context,
                        listen: false,
                      ).fetchAllMatches();
                      Provider.of<LeagueDetailProvider>(
                        context,
                        listen: false,
                      ).refresh();
                      Provider.of<LeagueGamesProvider>(
                        context,
                        listen: false,
                      ).refresh();
                    } catch (_) {}
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
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

  Widget _buildTeamRow({
    required String flagUrl,
    required String teamName,
    int? score,
    required bool isHomeTeam,
  }) {
    // Home team has gray text, Away team has black text
    final textColor = isHomeTeam
        ? const Color(0xFF6B7280)
        : const Color(0xFF111827);
    final scoreColor = const Color(0xFF374151);

    return Row(
      children: [
        // Flag icon (rectangular like in image)
        Container(
          width: 32,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1.6),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(1.6),
            child: flagUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: flagUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: const Color(0xFFF3F4F6)),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFFF3F4F6),
                      child: const Icon(
                        Icons.flag,
                        size: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFFF3F4F6),
                    child: const Icon(
                      Icons.flag,
                      size: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        // Team name
        Expanded(
          child: Text(
            teamName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textColor,
              fontFamily: 'Lato',
            ),
          ),
        ),
        const SizedBox(width: 8), // Spacing before score
        // Score (bold for completed games)
        Text(
          score?.toString() ?? '',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600, // Bold scores as per design
            color: scoreColor,
            fontFamily: 'Lato',
          ),
        ),
      ],
    );
  }

  Widget _buildTeamFlag(String flagUrl) {
    return Container(
      width: 32,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1.6),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1.6),
        child: flagUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: flagUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: const Color(0xFFF3F4F6)),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFFF3F4F6),
                  child: const Icon(
                    Icons.flag,
                    size: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              )
            : Container(
                color: const Color(0xFFF3F4F6),
                child: const Icon(
                  Icons.flag,
                  size: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
      ),
    );
  }

  Widget _buildTBDTeam() {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.shield, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 8),
        const Text(
          'TBD',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
            fontFamily: 'Lato',
          ),
        ),
      ],
    );
  }
}

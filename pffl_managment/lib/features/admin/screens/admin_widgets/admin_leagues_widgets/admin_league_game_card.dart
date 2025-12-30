import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_game_widgets/edit_upcomming_matches.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/core/utils/date_formatter.dart';
import 'package:pffl_managment/screens/games/game_tabs/game_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/core/providers/unified_games_provider.dart';
import 'package:pffl_managment/features/admin/provider/league_detail_provider.dart';
import 'package:pffl_managment/features/admin/providers/league_games_provider.dart';

class AdminLeagueGameCard extends StatelessWidget {
  final MatchModel match;
  final LeagueCreationModel league;
  final int totalGames;
  final int? sequenceNumber; // Position in the sorted list (1-based)

  const AdminLeagueGameCard({
    super.key,
    required this.match,
    required this.league,
    required this.totalGames,
    this.sequenceNumber,
  });

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).userRole.toLowerCase();
    final isAdmin = userRole == 'admin' || userRole == 'superadmin';

    final bool showScores = match.status != MatchStatus.upcoming;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: showScores
          ? _buildCompletedCard(context)
          : _buildUpcomingCard(context, isAdmin),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, bool isAdmin) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              // Home Team
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                ),
                child: match.homeTeamLogo.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          match.homeTeamLogo,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                match.homeTeam,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),

              // Center Info
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      match.roundName ?? 'Semi-Final',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (match.date.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        match.date,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (match.time.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        match.time,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

              // Away Team
              Text(
                match.awayTeam,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                ),
                child: match.awayTeamLogo.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          match.awayTeamLogo,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      )
                    : null,
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
                final updated = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: EditUpcommingMatches(match: match),
                    );
                  },
                );
                if (updated == true && context.mounted) {
                  // Refresh relevant providers
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
    );
  }

  Widget _buildCompletedCard(BuildContext context) {
    // Calculate game number based on sequence position
    final gameNumber = _getGameNumber();
    final formattedDate = match.matchDateTime != null
        ? DateFormatter.formatGameDate(match.matchDateTime!)
        : match.date;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameDetailsScreen(match: match),
          ),
        );
      },
      child: Container(
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
            // Top row: Game number and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        gameNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600, // Bold as per design
                          color: Color(0xFF111827),
                          fontFamily: 'Lato',
                        ),
                      ),
                      if (match.status == MatchStatus.live) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
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
                Text(
                  formattedDate,
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
              flagUrl: match.homeTeamLogo,
              teamName: match.homeTeam,
              score: match.homeScore,
              isHomeTeam: true,
            ),
            const SizedBox(height: 12),
            // Team 2 row (Away team - black text)
            _buildTeamRow(
              flagUrl: match.awayTeamLogo,
              teamName: match.awayTeam,
              score: match.awayScore,
              isHomeTeam: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRow({
    required String flagUrl,
    required String teamName,
    int? score,
    required bool isHomeTeam,
  }) {
    // Home team has gray text, Away team has black text (matching image)
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

  /// Extract game number from gameNumber field or calculate from sequence
  String _getGameNumber() {
    // If gameNumber is already set, use it
    if (match.gameNumber != null && match.gameNumber!.isNotEmpty) {
      return match.gameNumber!;
    }
    // Otherwise, calculate from sequence number (position in creation order)
    if (sequenceNumber != null) {
      return 'Game $sequenceNumber of $totalGames';
    }
    // Fallback
    return 'Game 1 of $totalGames';
  }
}

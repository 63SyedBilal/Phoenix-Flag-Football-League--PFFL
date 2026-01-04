import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminLeagueGameCard extends StatelessWidget {
  final MatchModel match;
  final LeagueCreationModel league;
  final int totalGames;
  final int? sequenceNumber;

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

    // Always show upcoming card UI
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: _buildUpcomingCard(context, isAdmin),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, bool isAdmin) {
    // Calculate game number based on sequence position
    final gameNumber = _getGameNumber();
    final formattedDate = match.matchDateTime != null
        ? _formatDate(match.matchDateTime!)
        : match.date;

    return Container(
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
                        fontWeight: FontWeight.w600,
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
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                  fontFamily: 'Lato',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Team 1 row
          _buildTeamRow(
            flagUrl: match.homeTeamLogo,
            teamName: match.homeTeam,
            score: match.homeScore,
            isHomeTeam: true,
          ),
          const SizedBox(height: 12),
          // Team 2 row
          _buildTeamRow(
            flagUrl: match.awayTeamLogo,
            teamName: match.awayTeam,
            score: match.awayScore,
            isHomeTeam: false,
          ),
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
        // Flag icon (rectangular)
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
        // Score (bold)
        Text(
          score?.toString() ?? '-',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: scoreColor,
            fontFamily: 'Lato',
          ),
        ),
      ],
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

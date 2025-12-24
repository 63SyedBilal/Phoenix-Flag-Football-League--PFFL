import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/utils/date_formatter.dart';
import 'package:pffl_managment/screens/games/game_tabs/game_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GameListCard extends StatelessWidget {
  final MatchModel match;
  final int totalGames;
  final int? sequenceNumber;

  const GameListCard({
    super.key,
    required this.match,
    required this.totalGames,
    this.sequenceNumber,
  });

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF000000).withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  gameNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF374151),
                    fontFamily: 'Lato',
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF374151),
                    fontFamily: 'Lato',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTeamRow(
              flagUrl: match.homeTeamLogo,
              teamName: match.homeTeam,
              score: match.homeScore,
              isHomeTeam: true,
            ),
            const SizedBox(height: 12),
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
        // Score
        Text(
          score?.toString() ?? '',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
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

import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/provider/upcoming_games_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/upcomming_matches_screens/edit_upcoming_games_screen.dart';

class AdminLeagueGameCard extends StatelessWidget {
  final MatchModel match;

  const AdminLeagueGameCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted =
        match.status == MatchStatus.completed &&
        match.homeScore != null &&
        match.awayScore != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: isCompleted
          ? _buildCompletedCard(context)
          : _buildUpcomingCard(context),
    );
  }

  Widget _buildUpcomingCard(BuildContext context) {
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
        Container(
          height: 1,
          color: const Color(0xFFE0E0E0),
          margin: const EdgeInsets.symmetric(horizontal: 12),
        ),
        Material(
          color: Colors.black.withAlpha(5),
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.all(16),
                    child: ChangeNotifierProvider(
                      create: (_) {
                        final provider = UpcomingGamesProvider();
                        provider.loadMatch(match);
                        return provider;
                      },
                      child: const EditUpcomingGamesScreen(),
                    ),
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Game',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF999999),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFCCCCCC),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                match.gameNumber ?? 'Game 8 of 12',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Text(
                match.date,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildTeamScoreRow(
            match.homeTeamLogo,
            match.homeTeam,
            match.homeScore ?? 0, // Removed '!' and provided a default value
          ),
          const SizedBox(height: 10),
          _buildTeamScoreRow(
            match.awayTeamLogo,
            match.awayTeam,
            match.awayScore ?? 0, // Removed '!' and provided a default value
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScoreRow(String logo, String name, int score) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 24,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
          child: Image.network(
            logo,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFF0F0F0),
              child: const Center(
                child: Text('🏴', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ),
        Text(
          score.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:intl/intl.dart';

/// Card for upcoming/scheduled matches
class UpcomingMatchCard extends StatelessWidget {
  final String roundName;
  final DateTime? gameDate;
  final String? team1Name;
  final String? team1Logo;
  final String? team2Name;
  final String? team2Logo;
  final MatchModel? match;
  final LeagueCreationModel league;
  final VoidCallback? onEditTap;

  const UpcomingMatchCard({
    super.key,
    required this.roundName,
    this.gameDate,
    this.team1Name,
    this.team1Logo,
    this.team2Name,
    this.team2Logo,
    this.match,
    required this.league,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayTeam1 = team1Name ?? 'TBD';
    final displayTeam2 = team2Name ?? 'TBD';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                _buildTeamSection(displayTeam1, team1Logo, isLeft: true),
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
                      Text(
                        _formatDate(gameDate),
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _formatTime(gameDate),
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildTeamSection(displayTeam2, team2Logo, isLeft: false),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onEditTap,
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

  Widget _buildTeamSection(String name, String? logo, {required bool isLeft}) {
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

  Widget _buildTeamLogo(String? logo) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: logo != null && logo.isNotEmpty ? null : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: logo != null && logo.isNotEmpty
          ? ClipOval(
              child: Image.network(
                logo,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.group, size: 16, color: Colors.white54),
              ),
            )
          : const Icon(Icons.group, size: 16, color: Colors.white54),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'TBD';
    return DateFormat('EEE dd MMM').format(date);
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat('hh:mm a').format(date).toUpperCase() + ' PKT';
  }
}

/// Card for completed matches
class CompletedMatchCard extends StatelessWidget {
  final String roundName;
  final String gameNumber;
  final DateTime? gameDate;
  final String team1Name;
  final String? team1Logo;
  final String team2Name;
  final String? team2Logo;
  final int? team1Score;
  final int? team2Score;

  const CompletedMatchCard({
    super.key,
    required this.roundName,
    required this.gameNumber,
    this.gameDate,
    required this.team1Name,
    this.team1Logo,
    required this.team2Name,
    this.team2Logo,
    this.team1Score,
    this.team2Score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                gameNumber,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
              Text(
                _formatDate(gameDate),
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTeamRow(team1Name, team1Logo, team1Score),
          const SizedBox(height: 12),
          _buildTeamRow(team2Name, team2Logo, team2Score),
        ],
      ),
    );
  }

  Widget _buildTeamRow(String teamName, String? logo, int? score) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: Colors.grey[200],
          ),
          child: logo != null && logo.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Image.network(
                    logo,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.group, size: 14, color: Colors.grey),
                  ),
                )
              : const Icon(Icons.group, size: 14, color: Colors.grey),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            teamName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF000000),
            ),
          ),
        ),
        Text(
          score?.toString() ?? '-',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'TBD';
    return DateFormat('EEE dd MMM').format(date);
  }
}

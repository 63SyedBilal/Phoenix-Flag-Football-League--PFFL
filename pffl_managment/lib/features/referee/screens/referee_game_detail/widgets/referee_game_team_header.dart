import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/core/utils/team_utils.dart';

class RefereeGameTeamHeader extends StatelessWidget {
  const RefereeGameTeamHeader({super.key, required this.match});

  final MatchModel? match;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTeamInfo(
            logoPath: match?.homeTeamLogo ?? '',
            teamName: match?.homeTeam ?? 'Home',
          ),
          const SizedBox(width: 24),
          Text(
            '${match?.homeScore ?? 0} \\ ${match?.awayScore ?? 0}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 24),
          _buildTeamInfo(
            logoPath: match?.awayTeamLogo ?? '',
            teamName: match?.awayTeam ?? 'Away',
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo({required String logoPath, required String teamName}) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
          ),
          child: ClipOval(
            child: logoPath.isNotEmpty && logoPath.startsWith('http')
                ? Image.network(
                    logoPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildDefaultLogo(teamName),
                  )
                : _buildDefaultLogo(teamName),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          getTeamAbbreviation(teamName),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultLogo(String teamName) {
    return Container(
      color: const Color(0xFFB91C1C),
      child: Center(
        child: Text(
          teamName.isNotEmpty ? teamName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

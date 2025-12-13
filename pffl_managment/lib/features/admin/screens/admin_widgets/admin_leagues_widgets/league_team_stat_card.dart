
import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_detail_models.dart';

class LeagueTeamStatCard extends StatelessWidget {
  final LeagueTeamStatModel teamStat;
  final int index;

  const LeagueTeamStatCard({super.key, required this.teamStat, this.index = 0});

  @override
  Widget build(BuildContext context) {
    String imagePath = index == 0 
        ? 'assets/images/image 4.png' 
        : 'assets/images/image 5.png';

    return Container(
      width: 165.5,
      height: 90,
      decoration: BoxDecoration(
        color: teamStat.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 25,
            right: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 60,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teamStat.teamName.split(' ').first,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Last name or remaining part of team name
                Text(
                  teamStat.teamName.split(' ').length > 1
                      ? teamStat.teamName.split(' ').skip(1).join(' ')
                      : '',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      teamStat.statValue,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      teamStat.statLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_detail_models.dart';

class LeagueTeamStatCard extends StatelessWidget {
  final LeagueTeamStatModel teamStat;
  final int index;

  const LeagueTeamStatCard({super.key, required this.teamStat, this.index = 0});

  @override
  Widget build(BuildContext context) {
    // Select image based on index to support 4 different images
    String imagePath;
    switch (index % 4) {
      case 0:
        imagePath = 'assets/images/image 4.png';
        break;
      case 1:
        imagePath = 'assets/images/image 5.png';
        break;
      case 2:
        imagePath = 'assets/images/image 14.png';
        break;
      case 3:
      default:
        imagePath = 'assets/images/Real Madrid.png';
        break;
    }

    return Container(
      width: 165.5,
      height: 90,
      decoration: BoxDecoration(
        color: teamStat.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Team Logo - Top right corner
          Positioned(
            top: 18,
            right: 10,
            child: Image.asset(
              imagePath,
              width: 55,
              height: 55,
              fit: BoxFit.contain,
            ),
          ),
          
          // Text Content
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 12, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team Name - No space between lines
                Text(
                  teamStat.teamName.split(' ').first,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 0.95,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  teamStat.teamName.split(' ').length > 1
                      ? teamStat.teamName.split(' ').skip(1).join(' ')
                      : '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 20),
                                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      teamStat.statValue,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.0,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        teamStat.statLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
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
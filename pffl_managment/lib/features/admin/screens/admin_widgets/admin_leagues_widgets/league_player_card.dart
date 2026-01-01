import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_detail_models.dart';

class LeaguePlayerCard extends StatelessWidget {
  final LeagueKeyPlayerModel player;
  final int index;

  const LeaguePlayerCard({super.key, required this.player, this.index = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 161,
      height: 90,
      decoration: BoxDecoration(
        color: player.gradientStart,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: -5,
            bottom: 0,
            child: player.avatarUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    child: Image.network(
                      player.avatarUrl,
                      width: 95,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPersonIcon(),
                    ),
                  )
                : _buildPersonIcon(),
          ),

      
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 12, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              
                Text(
                  player.name.isNotEmpty ? player.name.split(' ').first : 'Unknown',
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
                  player.name.isNotEmpty && player.name.split(' ').length > 1
                      ? player.name.split(' ').skip(1).join(' ')
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

                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      player.statValue.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.0,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      player.statLabel,
                      style: const TextStyle(
                        fontSize: 11,
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

  Widget _buildPersonIcon() {
    return Container(
      width: 95,
      height: 90,
      color: Colors.white.withValues(alpha: 0.1),
      child: const Icon(Icons.person, size: 50, color: Colors.white54),
    );
  }
}

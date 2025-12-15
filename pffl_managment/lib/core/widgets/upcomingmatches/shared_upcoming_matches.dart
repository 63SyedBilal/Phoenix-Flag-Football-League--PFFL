import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/shared_game_card.dart';
import 'package:pffl_managment/core/models/game_model.dart';

class SharedUpcomingMatches extends StatelessWidget {
  final List<GameModel> games;
  final VoidCallback? onViewMore;
  final int maxVisibleGames;
  final String title; // New parameter for custom title

  const SharedUpcomingMatches({
    super.key,
    required this.games,
    this.onViewMore,
    this.maxVisibleGames = 4, // Default to 4 games
    this.title = 'Your Next Game', // Default title
  });

  @override
  Widget build(BuildContext context) {
    final visibleGames = games.take(maxVisibleGames).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            if (onViewMore != null)
              TextButton(
                onPressed: onViewMore,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    Text(
                      'View more',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ...visibleGames.map(
          (game) => SharedGameCard(
            game: game,
            showYourGameTag: title == 'Your Next Game', // Only show tag for "Your Next Game"
          ),
        ),
      ],
    );
  }
}
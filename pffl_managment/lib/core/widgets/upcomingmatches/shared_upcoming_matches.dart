import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/shared_game_card.dart';
import 'package:pffl_managment/core/models/game_model.dart';

class SharedUpcomingMatches extends StatelessWidget {
  final List<GameModel> games;
  final VoidCallback? onViewMore;
  final int maxVisibleGames;
  final String title; // New parameter for custom title
  final Function(GameModel)? onGameTap; // Handler for game card tap

  const SharedUpcomingMatches({
    super.key,
    required this.games,
    this.onViewMore,
    this.maxVisibleGames = 4, // Default to 4 games
    this.title = 'Your Next Game', // Default title
    this.onGameTap, // Optional game tap handler
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
                fontFamily: 'Lato',
                color: Colors.black,
              ),
            ),


          ],
        ),
        const SizedBox(height: 16),
        ...visibleGames.map(
          (game) => SharedGameCard(
            game: game,
            showYourGameTag: title == 'Your Next Game', // Only show tag for "Your Next Game"
            onTap: onGameTap != null ? () => onGameTap!(game) : null,
          ),
        ),
      ],
    );
  }
}

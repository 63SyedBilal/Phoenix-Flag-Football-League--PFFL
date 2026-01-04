import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/shared_game_card.dart';
import 'package:pffl_managment/core/models/game_model.dart';

class SharedUpcomingMatches extends StatelessWidget {
  final List<GameModel> games;
  final VoidCallback? onViewMore;
  final int maxVisibleGames;
  final String title;
  final Function(GameModel)? onGameTap;

  const SharedUpcomingMatches({
    super.key,
    required this.games,
    this.onViewMore,
    this.maxVisibleGames = 4,
    this.title = 'Your Next Game',
    this.onGameTap,
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
        const SizedBox(height: 8),
        ...visibleGames.map(
          (game) => SharedGameCard(
            game: game,
            showYourGameTag: title == 'Your Next Game',
            onTap: onGameTap != null ? () => onGameTap!(game) : null,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/game_widgets/upcomming_matches_screens/upcomming_matches_card_widget.dart';
import 'package:pffl_managment/core/providers/unified_games_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_games/admin_games_screen.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';

class UpcommingMatches extends StatelessWidget {
  const UpcommingMatches({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UnifiedGamesProvider>(
      builder: (context, gamesProvider, child) {
        final matches = gamesProvider.upcomingGames;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Upcoming Matches', style: AppTextStyles.headlineSmall),
                if (matches.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdminGamesScreen(matches: matches),
                        ),
                      );
                    },
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
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            ...matches
                .take(3)
                .map(
                  (match) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: UpcommingMatchesCardWidget(match: match),
                  ),
                ),
          ],
        );
      },
    );
  }
}

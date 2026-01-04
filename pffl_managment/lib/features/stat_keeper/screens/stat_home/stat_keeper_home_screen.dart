import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/shared_upcoming_matches.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/all_matches_screen.dart';
import 'package:pffl_managment/core/utils/game_navigation_helper.dart';
import 'package:pffl_managment/features/sponsors/screens/sponsor_banner_screen.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/stat_keeper/providers/stat_keeper_dashboard_provider.dart';
import 'package:pffl_managment/features/stat_keeper/screens/game_stats/game_stats_screen.dart';

class StatKeeperHomeScreen extends StatelessWidget {
  const StatKeeperHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<StatKeeperDashboardProvider>(context);
    final games = dashboardProvider.upcomingGames;
    final assignedGames = games.where((game) => game.isMyGame).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Assigned Games For You",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    if (assignedGames.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllMatchesScreen(
                                matches: assignedGames,
                                title: 'Assigned Games',
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              'View more',
                              style: TextStyle(
                                color: Color(0xFF0F173E),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        children: [
                          Text(
                            'View more',
                            style: TextStyle(
                              color: Color(0xFF0F173E),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (assignedGames.isNotEmpty)
                  SharedUpcomingMatches(
                    games: assignedGames,
                    maxVisibleGames: 1,
                    title: '',
                    onViewMore: null,
                    onGameTap: (game) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GameStatsScreen(matchId: game.id),
                        ),
                      );
                    },
                  )
                else
                  const Text('No games assigned to you yet.'),

                SharedUpcomingMatches(
                  games: games,
                  maxVisibleGames: 3,
                  title: 'Upcoming Games',
                  onGameTap: (game) =>
                      GameNavigationHelper.navigateToGameDetail(context, game),
                  onViewMore: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllMatchesScreen(
                          matches: games,
                          title: 'Upcoming Games',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                SponsorBannerScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

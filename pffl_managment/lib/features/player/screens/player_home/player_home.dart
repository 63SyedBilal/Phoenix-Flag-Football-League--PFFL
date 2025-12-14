import 'package:flutter/material.dart';
import 'package:pffl_managment/features/sponsors/screens/sponsor_banner_screen.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/captain/widgets/league_payment_card.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/shared_upcoming_matches.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/all_matches_screen.dart';
import 'package:pffl_managment/features/player/providers/player_dashboard_provider.dart';

class PlayerHome extends StatelessWidget {
  const PlayerHome ({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<PlayerDashboardProvider>(context);
    final games = dashboardProvider.upcomingGames;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pending Payment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                LeaguePaymentCard(
                  title: 'Player League', // Placeholder title
                  amount: '\$200', // Placeholder amount
                  subtitle: 'League Fee Due',
                  format: '5v5',
                  leagueFee: '\$200',
                  startDate: '10 December 2025',
                  endDate: '25 February 2026',
                  onPayNow: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Processing payment...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),
                // Show only the next game if available
                if (games.isNotEmpty)
                  SharedUpcomingMatches(
                    games: [games[0]], // Show only the next game
                    maxVisibleGames: 1, // Show only 1 game for "Next Game"
                    title: 'Your Next Game',
                    onViewMore: () {
                      // Navigate to full matches list
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllMatchesScreen(
                            matches: [games[0]],
                            title: 'Next Game',
                          ),
                        ),
                      );
                    },
                  ),
                SponsorBannerScreen(),

                const SizedBox(height: 8),

                SharedUpcomingMatches(
                  games: games,
                  maxVisibleGames: 3, // Show only 3 games in main view
                  title: 'Upcoming Games',
                  onViewMore: () {
                    // Navigate to full matches list
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
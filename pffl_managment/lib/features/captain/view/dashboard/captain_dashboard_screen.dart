import 'package:flutter/material.dart';
import 'package:pffl_managment/features/sponsors/screens/sponsor_banner_screen.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/captain/widgets/league_payment_card.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/shared_upcoming_matches.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/all_matches_screen.dart';
import 'package:pffl_managment/features/captain/providers/captain_dashboard_provider.dart';

class CaptainDashboardScreen extends StatelessWidget {
  const CaptainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<CaptainDashboardProvider>(context);
        final nextGame = dashboardProvider.nextGame;
    
    final upcomingGames = dashboardProvider.upcomingGames;

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
                  title: dashboardProvider.leagueTitle,
                  amount: dashboardProvider.paymentAmount,
                  subtitle: dashboardProvider.paymentSubtitle,
                  format: dashboardProvider.leagueFormat,
                  leagueFee: dashboardProvider.paymentAmount,
                  startDate: dashboardProvider.leagueStartDate,
                  endDate: dashboardProvider.leagueEndDate,
                  onPayNow: () {
                    dashboardProvider.handlePayNow();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Processing payment...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                const Text(
                  'Your Next Game',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                // Show only the next game using the shared widget
                if (nextGame != null)
                  SharedUpcomingMatches(
                    games: [nextGame],
                    maxVisibleGames: 1, // Show only 1 game for "Next Game"
                    onViewMore: () {
                      // Navigate to full matches list
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllMatchesScreen(
                            matches: [nextGame],
                            title: 'Next Game',
                          ),
                        ),
                      );
                    },
                  ),
                SponsorBannerScreen(),

                const SizedBox(height: 8),

                // Show upcoming games (limited to 3 in main view)
                SharedUpcomingMatches(
                  games: upcomingGames,
                  maxVisibleGames: 3, // Show only 3 games in main view
                  onViewMore: () {
                    // Navigate to full matches list
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllMatchesScreen(
                          matches: upcomingGames,
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
import 'package:flutter/material.dart';
import 'package:pffl_managment/features/sponsors/screens/sponsor_banner_screen.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/captain/widgets/league_payment_card.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/shared_upcoming_matches.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/all_matches_screen.dart';
import 'package:pffl_managment/core/captain_provider/home_screen_provider/captain_dashboard_provider.dart';
import 'package:pffl_managment/features/captain/widgets/captain_upcoming_matches.dart';

class CaptainDashboardScreen extends StatelessWidget {
  const CaptainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<CaptainDashboardProvider>(context);
    final nextGame = dashboardProvider.nextGame;

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
                const SizedBox(height: 12),
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
                
                // Show upcoming games filtered for captain's team
                const CaptainUpcomingMatches(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:pffl_managment/features/sponsors/screens/sponsor_banner_screen.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/captain/widgets/league_payment_card.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/shared_upcoming_matches.dart';
import 'package:pffl_managment/core/widgets/upcomingmatches/all_matches_screen.dart';
import 'package:pffl_managment/features/player/providers/player_dashboard_provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/core/providers/pending_payment_provider.dart';

class PlayerHome extends StatefulWidget {
  const PlayerHome({super.key});

  @override
  State<PlayerHome> createState() => _PlayerHomeState();
}

class _PlayerHomeState extends State<PlayerHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PendingPaymentProvider>(
        context,
        listen: false,
      ).loadPendingPayment(context);
    });
  }

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
                Consumer<PendingPaymentProvider>(
                  builder: (context, paymentProvider, child) {
                    if (paymentProvider.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (!paymentProvider.hasPendingPayment ||
                        paymentProvider.pendingPayment == null) {
                      // Empty state
                      return Column(
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
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Center(
                              child: Text(
                                'No pending payments',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }

                    final payment = paymentProvider.pendingPayment!;

                    return Column(
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
                          title: payment.leagueName,
                          amount: payment.amount,
                          subtitle: payment.subTitle,
                          format: payment.format,
                          leagueFee: payment.amount,
                          startDate: payment.startDate,
                          endDate: payment.endDate,
                          onPayNow: () {
                            // Navigate to Payment Option Screen
                            Navigator.pushNamed(
                              context,
                              AppRoutes.freeAgentPaymentOption,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
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
                const SizedBox(height: 12),
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

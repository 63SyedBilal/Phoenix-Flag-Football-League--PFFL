import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_card_widget.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_detail_view.dart';
import 'package:pffl_managment/features/admin/leagues/providers/enhanced_leagues_provider.dart';

class LeaguesScreen extends StatefulWidget {
  const LeaguesScreen({Key? key}) : super(key: key);

  @override
  State<LeaguesScreen> createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends State<LeaguesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch leagues from backend when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<EnhancedLeaguesProvider>(context, listen: false);
        provider.fetchAllLeagues();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<EnhancedLeaguesProvider>(
          builder: (context, provider, child) {
            // Show loading state
            if (provider.isLoadingLeagues && provider.allLeagues.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Show error state
            if (provider.errorMessage != null && provider.allLeagues.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchAllLeagues(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Show leagues list with pull-to-refresh
            return RefreshIndicator(
              onRefresh: () => provider.refreshLeagues(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    if (provider.allLeagues.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No leagues found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    else
                      ...provider.allLeagues.map(
                        (league) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: LeagueCardWidget(
                            league: league,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      LeagueDetailView(league: league),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    // Add bottom padding for refresh indicator
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

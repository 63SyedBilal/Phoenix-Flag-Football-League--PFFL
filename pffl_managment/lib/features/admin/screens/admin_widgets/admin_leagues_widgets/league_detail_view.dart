import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/features/admin/game_widgets/upcomming_matches_screens/upcomming_leagues_matches.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/animated_fab.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_detail_header.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_tabs/league_detail_tab_bar.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_tabs/league_leader_board_section.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_tabs/league_offical_list.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_tabs/league_team_list.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_team_stats_section.dart';
import 'package:pffl_managment/features/key_players/league_key_players_section.dart';
import 'package:pffl_managment/features/sponsors/screens/sponsor_banner_screen.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/provider/league_detail_provider.dart';
import 'package:pffl_managment/features/admin/shared/providers/animated_fab_provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_tabs/admin_league_games_section.dart';

class LeagueDetailView extends StatelessWidget {
  final LeagueCreationModel league;

  const LeagueDetailView({super.key, required this.league});

  @override
  Widget build(BuildContext context) {
    return Consumer<LeagueDetailProvider>(
      builder: (context, provider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final fabProvider = Provider.of<AnimatedFABProvider>(
            context,
            listen: false,
          );
          if (provider.selectedTabIndex != 1) {
            fabProvider.reset();
          }
        });

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            leading: ArrowBackButton(onPressed: () => Navigator.pop(context)),
          ),
          floatingActionButton: provider.selectedTabIndex == 1
              ? AnimatedFAB(
                  onPressed: () async {
                    await Navigator.pushNamed(
                      context,
                      AppRoutes.adminCreateMatch,
                      arguments: league,
                    );
                    // Refresh games section when returning from create game
                    if (context.mounted) {
                      // The provider will refresh automatically when the widget rebuilds
                    }
                  },
                )
              : null,
          body: SafeArea(
            child: Column(
              children: [
                LeagueDetailHeader(
                  leagueName: league.leagueName,
                  subtitle:
                      'Stay updated with all details, Games, and stats\nfor this league.',
                  onBackPressed: () => Navigator.of(context).pop(),
                  logoUrl: league.teamLogo,
                ),
                const SizedBox(height: 8),
                const LeagueDetailTabBar(),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (provider.selectedTabIndex == 0) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: UpcommingGames(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SponsorBannerScreen(),
                          ),
                          const LeagueLeaderboardSection(),
                          SizedBox(height: 12,),
                          const LeagueKeyPlayersSection(),
                          const LeagueTeamStatsSection(),
                        ] else if (provider.selectedTabIndex == 1) ...[
                          AdminLeagueGamesSection(league: league),
                        ] else if (provider.selectedTabIndex == 2) ...[
                          const LeagueLeaderboardSection(),
                        ] else if (provider.selectedTabIndex == 3) ...[
                          const LeagueTeamList(),
                        ] else if (provider.selectedTabIndex == 4) ...[
                          LeagueOfficialsList(leagueId: league.id),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
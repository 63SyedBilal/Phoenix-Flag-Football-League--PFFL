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
import 'package:pffl_managment/core/providers/auth_provider.dart';

class LeagueDetailView extends StatefulWidget {
  final LeagueCreationModel league;

  const LeagueDetailView({super.key, required this.league});

  @override
  State<LeagueDetailView> createState() => _LeagueDetailViewState();
}

class _LeagueDetailViewState extends State<LeagueDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<LeagueDetailProvider>(
          context,
          listen: false,
        ).initialize(widget.league.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeagueDetailProvider>(
      builder: (context, provider, child) {
        final isAdmin =
            Provider.of<AuthProvider>(
              context,
              listen: false,
            ).userRole.toLowerCase() ==
            'admin';

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            final fabProvider = Provider.of<AnimatedFABProvider>(
              context,
              listen: false,
            );
            if (provider.selectedTabIndex != 1) {
              fabProvider.reset();
            }
          }
        });

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            leading: ArrowBackButton(onPressed: () => Navigator.pop(context)),
          ),
          floatingActionButton: (provider.selectedTabIndex == 1 && isAdmin)
              ? AnimatedFAB(
                  onPressed: () async {
                    await Navigator.pushNamed(
                      context,
                      AppRoutes.adminCreateMatch,
                      arguments: widget.league,
                    );
                    // Refresh games section when returning from create game
                    if (context.mounted) {
                      // The provider will refresh automatically when the widget rebuilds
                      // or we can explicitly refresh
                      provider.initialize(widget.league.id);
                    }
                  },
                )
              : null,
          body: SafeArea(
            child: Column(
              children: [
                LeagueDetailHeader(
                  leagueName: widget.league.leagueName,
                  subtitle:
                      'Stay updated with all details, Games, and stats\nfor this league.',
                  onBackPressed: () => Navigator.of(context).pop(),
                  logoUrl: widget.league.teamLogo,
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
                            child: UpcommingGames(leagueId: widget.league.id),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SponsorBannerScreen(),
                          ),
                          const LeagueLeaderboardSection(),
                          SizedBox(height: 12),
                          const LeagueKeyPlayersSection(),
                          const LeagueTeamStatsSection(),
                        ] else if (provider.selectedTabIndex == 1) ...[
                          AdminLeagueGamesSection(league: widget.league),
                        ] else if (provider.selectedTabIndex == 2) ...[
                          const LeagueLeaderboardSection(),
                        ] else if (provider.selectedTabIndex == 3) ...[
                          const LeagueTeamList(),
                        ] else if (provider.selectedTabIndex == 4) ...[
                          LeagueOfficialsList(leagueId: widget.league.id),
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

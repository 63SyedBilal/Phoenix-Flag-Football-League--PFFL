import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/game_widgets/upcomming_matches_screens/upcomming_matches.dart' as upcomming_matches;
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_tabs/league_detail_tab_bar.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_tabs/league_leader_board_section.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_tabs/league_offical_list.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/features/captain/providers/captain_league_detail_provider.dart';
import 'package:pffl_managment/features/sponsors/screens/sponsor_banner_screen.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_detail_header.dart';
import 'package:pffl_managment/features/key_players/league_key_players_section.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_tabs/league_team_list.dart';
import 'package:pffl_managment/features/captain/providers/league_summary_provider.dart';
import 'package:pffl_managment/features/captain/widgets/league_summary_section.dart';

class CaptainLeagueDetailScreen extends StatelessWidget {
  final LeagueCreationModel league;

  const CaptainLeagueDetailScreen({super.key, required this.league});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CaptainLeagueDetailProvider>(
          create: (_) => CaptainLeagueDetailProvider(),
        ),
        ChangeNotifierProvider<LeagueSummaryProvider>(
          create: (_) => LeagueSummaryProvider(),
        ),
      ],
      child: Consumer2<CaptainLeagueDetailProvider, LeagueSummaryProvider>(
        builder: (context, leagueProvider, summaryProvider, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading: ArrowBackButton(onPressed: () => Navigator.pop(context)),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  LeagueDetailHeader(
                    leagueName: league.leagueName,
                    subtitle: 'Stay updated with all details, Games, and stats for this league.',
                    onBackPressed: () => Navigator.of(context).pop(),
                    logoUrl: league.teamLogo,
                  ),
                  const LeagueDetailTabBar(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Selector<CaptainLeagueDetailProvider, int>(
                        selector: (_, provider) => provider.selectedTabIndex,
                        builder: (context, tabIndex, _) {
                          return Column(
                            children: [
                              // League Summary Section - shown on all tabs
                              LeagueSummarySection(leagueId: league.id),
                              const SizedBox(height: 16),
                              if (tabIndex == 0) ...[
                                const upcomming_matches.UpcommingMatches(),
                                SponsorBannerScreen(),
                                const LeagueLeaderboardSection(),
                                const LeagueKeyPlayersSection(),
                                const LeagueKeyPlayersSection(),
                              ] else if (tabIndex == 1) ...[
                                const upcomming_matches.UpcommingMatches(),
                              ] else if (tabIndex == 2) ...[
                                const LeagueLeaderboardSection(),
                              ] else if (tabIndex == 3) ...[
                                const LeagueTeamList(),
                              ] else if (tabIndex == 4) ...[
                                LeagueOfficialsList(leagueId: '',),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

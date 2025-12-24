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
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userRole = authProvider.userRole;
        final normalizedRole = userRole.toLowerCase();
        final isAdmin =
            normalizedRole == 'admin' || normalizedRole == 'superadmin';

        // Comprehensive debug logging
        debugPrint('');
        debugPrint('═══════════════════════════════════════');
        debugPrint('LeagueDetailView FAB DEBUG:');
        debugPrint('  Raw userRole: "$userRole"');
        debugPrint('  userRole.toLowerCase(): "${userRole.toLowerCase()}"');
        debugPrint('  isAdmin: $isAdmin');
        debugPrint('  selectedTabIndex: ${provider.selectedTabIndex}');
        debugPrint(
          '  Tab is Games (index 1): ${provider.selectedTabIndex == 1}',
        );
        debugPrint(
          '  shouldShowFAB: ${provider.selectedTabIndex == 1 && isAdmin}',
        );
        debugPrint('═══════════════════════════════════════');
        debugPrint('');

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

        final shouldShowFAB = provider.selectedTabIndex == 1 && isAdmin;

        if (shouldShowFAB) {
          debugPrint('✅ FAB SHOULD BE VISIBLE NOW!');
        } else {
          debugPrint('❌ FAB HIDDEN - Reason:');
          if (!isAdmin)
            debugPrint('   - User is not admin (role: "$userRole")');
          if (provider.selectedTabIndex != 1)
            debugPrint(
              '   - Not on Games tab (current tab: ${provider.selectedTabIndex})',
            );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: ArrowBackButton(onPressed: () => Navigator.pop(context)),
          ),
          floatingActionButton: shouldShowFAB
              ? AnimatedFAB(
                  onPressed: () async {
                    debugPrint('🎯 FAB PRESSED - Navigating to create match');
                    await Navigator.pushNamed(
                      context,
                      AppRoutes.adminCreateMatch,
                      arguments: widget.league,
                    );
                    if (context.mounted) {
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
                        ] else if (provider.selectedTabIndex == 5) ...[
                          const Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SponsorBannerScreen(),
                          ),
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

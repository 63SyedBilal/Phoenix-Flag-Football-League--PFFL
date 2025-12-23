import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/screens/admin_leagues/leagues_screen.dart';
import 'package:pffl_managment/features/captain/screens/captain_home/captain_home_screen.dart';
import 'package:pffl_managment/screens/leagues/common/league_provider.dart';
import 'package:pffl_managment/features/bottom_nevigation/captain_bottom_nevigation/captain_bottom_nevigation.dart';
import 'package:pffl_managment/features/captain/view/teams/team_management_screen.dart';
import 'package:pffl_managment/features/header_widgets/captain_header_widget/captain_header_widget.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/captain_navigation_provider.dart';
import 'package:pffl_managment/screens/games/common/games_screen.dart';
import 'package:pffl_managment/screens/games/common/games_provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/screens/settings/common/settings_screen.dart';
import 'package:pffl_managment/screens/settings/common/settings_provider.dart';
import 'package:pffl_managment/features/captain/providers/captain_team_provider.dart';
import 'package:pffl_managment/core/widgets/back_button_wrapper.dart';

class CaptainDashboard extends StatelessWidget {
  const CaptainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<CaptainNavigationProvider>(context);

    return BackButtonWrapper(
      isRoot: true,
      child: ChangeNotifierProvider(
        create: (_) => CaptainTeamProvider(),
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const CaptainHeaderWidget(),
                Expanded(
                  child: IndexedStack(
                    index: navigationProvider.selectedIndex,
                    children: [
                      const CaptainHomeScreen(),
                      ChangeNotifierProvider(
                        create: (_) => LeagueProvider(userRole: 'captain'),
                        child: const LeaguesScreen(),
                      ),
                      ChangeNotifierProvider(
                        create: (context) {
                          final auth = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          return GamesProvider(
                            userRole: auth.userRole,
                            userId: auth.userId,
                            assignedLeague:
                                'Six Nations', // TODO: Get from profile
                            isLeagueFeeUnpaid: true, // TODO: Get from profile
                          );
                        },
                        child: const GamesScreen(),
                      ),
                      const TeamManagementScreen(),
                      ChangeNotifierProvider(
                        create: (_) =>
                            RoleBasedSettingsProvider(userRole: 'captain'),
                        child: const SettingsScreen(),
                      ),
                    ],
                  ),
                ),
                const CaptainBottomNevigation(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

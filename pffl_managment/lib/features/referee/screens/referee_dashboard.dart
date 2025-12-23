import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/referee_navigation_provider.dart';
import 'package:pffl_managment/features/bottom_nevigation/referee_bottom_nevigation/referee_bottom_nevigation.dart';
import 'package:pffl_managment/features/header_widgets/raferee_header_widget/raferee_header_widget.dart';
import 'package:pffl_managment/features/referee/screens/referee_home/referee_home_screen.dart';
import 'package:pffl_managment/screens/games/common/games_screen.dart';
import 'package:pffl_managment/screens/games/common/games_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_leagues/leagues_screen.dart';
import 'package:pffl_managment/screens/leagues/common/league_provider.dart';
import 'package:pffl_managment/screens/settings/common/settings_screen.dart';
import 'package:pffl_managment/screens/settings/common/settings_provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import 'package:pffl_managment/core/widgets/back_button_wrapper.dart';

class RefereeDashboard extends StatelessWidget {
  const RefereeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<RefereeNavigationProvider>(context);

    return BackButtonWrapper(
      isRoot: true,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const RafereeHeaderWidget(),
              Expanded(
                child: IndexedStack(
                  index: navigationProvider.selectedIndex,
                  children: [
                    const RefereeHomeScreen(),
                    ChangeNotifierProvider(
                      create: (context) {
                        final auth = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        return GamesProvider(
                          userRole: auth.userRole,
                          userId: auth.userId,
                        );
                      },
                      child: const GamesScreen(),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => LeagueProvider(userRole: 'referee'),
                      child: const LeaguesScreen(),
                    ),
                    ChangeNotifierProvider(
                      create: (_) =>
                          RoleBasedSettingsProvider(userRole: 'referee'),
                      child: const SettingsScreen(),
                    ),
                  ],
                ),
              ),
              const RefereeBottomNevigation(),
            ],
          ),
        ),
      ),
    );
  }
}

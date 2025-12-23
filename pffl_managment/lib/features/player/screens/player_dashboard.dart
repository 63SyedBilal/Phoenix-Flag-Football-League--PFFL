import 'package:flutter/material.dart';
import 'package:pffl_managment/features/bottom_nevigation/player_bottom_nevigation/player_bottom_nevigation.dart';
import 'package:pffl_managment/features/header_widgets/player_header_widget/player_header_widget.dart';
import 'package:pffl_managment/features/player/screens/player_home/player_home.dart';
import 'package:pffl_managment/features/player/screens/player_my_team/player_my_team.dart';
import 'package:pffl_managment/screens/games/common/games_screen.dart';
import 'package:pffl_managment/screens/games/common/games_provider.dart';
import 'package:pffl_managment/screens/settings/common/settings_screen.dart';
import 'package:pffl_managment/screens/settings/common/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/player_navigation_provider.dart';

import 'package:pffl_managment/core/widgets/back_button_wrapper.dart';

class PlayerDashboard extends StatelessWidget {
  const PlayerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<PlayerNavigationProvider>(context);

    return BackButtonWrapper(
      isRoot: true,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              PlayerHeaderWidget(),
              Expanded(
                child: IndexedStack(
                  index: navigationProvider.selectedIndex,
                  children: [
                    const PlayerHome(),
                    ChangeNotifierProvider(
                      create: (_) => GamesProvider(userRole: 'player'),
                      child: const GamesScreen(),
                    ),
                    const PlayerMyTeam(),
                    ChangeNotifierProvider(
                      create: (_) =>
                          RoleBasedSettingsProvider(userRole: 'player'),
                      child: const SettingsScreen(),
                    ),
                  ],
                ),
              ),
              const PlayerBottomNevigation(),
            ],
          ),
        ),
      ),
    );
  }
}

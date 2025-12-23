import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/stat_keeper_navigation_provider.dart';
import 'package:pffl_managment/features/bottom_nevigation/stats_keeper_nevigation/stats_keeper_nevigation.dart';
import 'package:pffl_managment/features/header_widgets/stat_keeper_header_widget/stat_keeper_header_widget.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_add/stat_add_screen.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_home/stat_keeper_home_screen.dart';
import 'package:pffl_managment/screens/games/common/games_screen.dart';
import 'package:pffl_managment/screens/games/common/games_provider.dart';
import 'package:pffl_managment/screens/settings/common/settings_screen.dart';
import 'package:pffl_managment/screens/settings/common/settings_provider.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_stats/stat_stats_screen.dart';
import 'package:pffl_managment/features/stat_keeper/providers/stat_stats_provider.dart';
import 'package:provider/provider.dart';

import 'package:pffl_managment/core/widgets/back_button_wrapper.dart';

class StatKeeperDashboard extends StatelessWidget {
  const StatKeeperDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<StatKeeperNavigationProvider>(
      context,
    );

    return BackButtonWrapper(
      isRoot: true,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => StatStatsProvider()),
          // Add other global stats providers here if needed
        ],
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const StatKeeperHeaderWidget(),
                Expanded(
                  child: IndexedStack(
                    index: navigationProvider.selectedIndex,
                    children: [
                      const StatKeeperHomeScreen(),
                      ChangeNotifierProvider(
                        create: (_) => GamesProvider(userRole: 'stat keeper'),
                        child: const GamesScreen(),
                      ),
                      const StatAddScreen(),
                      const StatStatsScreen(),
                      ChangeNotifierProvider(
                        create: (_) =>
                            RoleBasedSettingsProvider(userRole: 'stat keeper'),
                        child: const SettingsScreen(),
                      ),
                    ],
                  ),
                ),
                const StatsKeeperNevigation(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

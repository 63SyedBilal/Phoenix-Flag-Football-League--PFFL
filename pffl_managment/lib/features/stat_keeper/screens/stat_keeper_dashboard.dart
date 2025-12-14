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

class StatKeeperDashboard extends StatelessWidget {
  const StatKeeperDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<StatKeeperNavigationProvider>(
      context,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StatStatsProvider()),
        // Add other global stats providers here if needed
      ],
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const StatKeeperHeaderWidget(),
              Expanded(child: _buildContent(navigationProvider.selectedIndex)),
              const StatsKeeperNevigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const StatKeeperHomeScreen();
      case 1:
        return ChangeNotifierProvider(
          create: (_) => GamesProvider(userRole: 'stat keeper'),
          child: const GamesScreen(),
        );
      case 2:
        return const StatAddScreen();
      case 3:
        return const StatStatsScreen();
      case 4:
        return ChangeNotifierProvider(
          create: (_) => RoleBasedSettingsProvider(userRole: 'stat keeper'),
          child: const SettingsScreen(),
        );

      default:
        return const Center(child: Text('Captain Dashboard'));
    }
  }
}

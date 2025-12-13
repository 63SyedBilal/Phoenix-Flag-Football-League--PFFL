import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/stat_keeper_navigation_provider.dart';
import 'package:pffl_managment/features/bottom_nevigation/stats_keeper_nevigation/stats_keeper_nevigation.dart';
import 'package:pffl_managment/features/header_widgets/stat_keeper_header_widget/stat_keeper_header_widget.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_add/stat_add_screen.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_game/stat_game_screen.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_home/stat_keeper_home_screen.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_setting/stat_setting_screen.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_stats/stat_stats_screen.dart';
import 'package:provider/provider.dart';


class StatKeeperDashboard extends StatelessWidget {
  const StatKeeperDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<StatKeeperNavigationProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const StatKeeperHeaderWidget(),
            Expanded(child: _buildContent(navigationProvider.selectedIndex)),
            const StatsKeeperNevigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const StatKeeperHomeScreen();
      case 1:
        return const StatGameScreen();
      case 2:
        return const StatAddScreen();
      case 3:
        return const StatStatsScreen();
        case 4:
        return const StatSettingScreen();

      default:
        return const Center(child: Text('Captain Dashboard'));
    }
  }
}

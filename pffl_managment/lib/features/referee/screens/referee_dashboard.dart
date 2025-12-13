import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/referee_navigation_provider.dart';
import 'package:pffl_managment/features/bottom_nevigation/referee_bottom_nevigation/referee_bottom_nevigation.dart';
import 'package:pffl_managment/features/header_widgets/raferee_header_widget/raferee_header_widget.dart';
import 'package:pffl_managment/features/referee/screens/referee_game/referee_game_screen.dart';
import 'package:pffl_managment/features/referee/screens/referee_home/referee_home_screen.dart';
import 'package:pffl_managment/features/referee/screens/referee_league/referee_league_screen.dart';
import 'package:pffl_managment/features/referee/screens/referee_setting/referee_setting_screen.dart';
import 'package:provider/provider.dart';


class RefereeDashboard extends StatelessWidget {
  const RefereeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<RefereeNavigationProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const RafereeHeaderWidget(),
            Expanded(child: _buildContent(navigationProvider.selectedIndex)),
            const RefereeBottomNevigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const RefereeHomeScreen();
      case 1:
        return const RefereeGameScreen();
      case 2:
        return const RefereeLeagueScreen();
      case 3:
        return const RefereeSettingScreen();

      default:
        return const Center(child: Text('Captain Dashboard'));
    }
  }
}

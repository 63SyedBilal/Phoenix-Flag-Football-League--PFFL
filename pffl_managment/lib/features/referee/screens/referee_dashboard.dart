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
        return ChangeNotifierProvider(
          create: (_) => GamesProvider(userRole: 'referee'),
          child: const GamesScreen(),
        );
      case 2:
        return ChangeNotifierProvider(
          create: (_) => LeagueProvider(userRole: 'referee'),
          child: const LeaguesScreen(),
        );
      case 3:
        return ChangeNotifierProvider(
          create: (_) => RoleBasedSettingsProvider(userRole: 'referee'),
          child: const SettingsScreen(),
        );

      default:
        return const Center(child: Text('Referee Dashboard'));
    }
  }
}

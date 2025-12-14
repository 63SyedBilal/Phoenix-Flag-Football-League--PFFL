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

class PlayerDashboard extends StatelessWidget {
  const PlayerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<PlayerNavigationProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PlayerHeaderWidget(),
            Expanded(child: _buildContent(navigationProvider.selectedIndex)),
            const PlayerBottomNevigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const PlayerHome();
      case 1:
        return ChangeNotifierProvider(
          create: (_) => GamesProvider(userRole: 'player'),
          child: const GamesScreen(),
        );
      case 2:
        return const PlayerMyTeam();
      case 3:
        return ChangeNotifierProvider(
          create: (_) => RoleBasedSettingsProvider(userRole: 'player'),
          child: const SettingsScreen(),
        );
      default:
        return const Center(child: Text('Player Dashboard'));
    }
  }
}

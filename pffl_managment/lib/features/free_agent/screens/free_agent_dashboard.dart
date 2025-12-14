import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/free_agent_navigation_provider.dart';
import 'package:pffl_managment/features/bottom_nevigation/free_agent_bottom_nevigation/free_agent_bottom_nevigation.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_home/free_agent_home_screen.dart';
import 'package:pffl_managment/screens/games/common/games_screen.dart';
import 'package:pffl_managment/screens/games/common/games_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_leagues/leagues_screen.dart';
import 'package:pffl_managment/screens/leagues/common/league_provider.dart';
import 'package:pffl_managment/screens/settings/common/settings_screen.dart';
import 'package:pffl_managment/screens/settings/common/settings_provider.dart';
import 'package:pffl_managment/features/header_widgets/free_agent_header_widget/free_agent_header_widget.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/free_agent/providers/free_agent_dashboard_provider.dart';

class FreeAgentDashboard extends StatelessWidget {
  const FreeAgentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FreeAgentDashboardProvider()),
      ],
      child: Consumer<FreeAgentNavigationProvider>(
        builder: (context, navigationProvider, _) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  const FreeAgentHeaderWidget(),
                  Expanded(
                    child: _buildContent(navigationProvider.selectedIndex),
                  ),
                  const FreeAgentBottomNevigation(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const FreeAgentHomeScreen();
      case 1:
        return ChangeNotifierProvider(
          create: (_) => GamesProvider(userRole: 'free agent'),
          child: const GamesScreen(),
        );
      case 2:
        return ChangeNotifierProvider(
          create: (_) => LeagueProvider(userRole: 'free agent'),
          child: const LeaguesScreen(),
        );
      case 3:
        return ChangeNotifierProvider(
          create: (_) => RoleBasedSettingsProvider(userRole: 'free agent'),
          child: const SettingsScreen(),
        );

      default:
        return const Center(child: Text('Free Agent Dashboard'));
    }
  }
}

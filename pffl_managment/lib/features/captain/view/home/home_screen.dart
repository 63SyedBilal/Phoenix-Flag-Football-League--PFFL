import 'package:flutter/material.dart';
import 'package:pffl_managment/features/bottom_nevigation/captain_bottom_nevigation/captain_bottom_nevigation.dart';
import 'package:pffl_managment/features/captain/view/dashboard/captain_dashboard_screen.dart';
import 'package:pffl_managment/features/header_widgets/captain_header_widget/captain_header_widget.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/captain_navigation_provider.dart';
import 'package:pffl_managment/features/captain/view/teams/team_management_screen.dart';
import 'package:pffl_managment/features/captain/view/games/games_schedule_screen.dart';
import 'package:pffl_managment/features/captain/view/leagues/captain_leagues_screen.dart';
import 'package:pffl_managment/features/captain/view/setup/captain_settings_screen.dart';

class CaptainHomeScreen extends StatelessWidget {
  const CaptainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<CaptainNavigationProvider>(context);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CaptainHeaderWidget(),
            Expanded(
              child: _buildContent(navigationProvider.selectedIndex),
            ),
            const CaptainBottomNevigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const CaptainDashboardScreen();
      case 1:
        return const TeamManagementScreen();
      case 2:
        return const GamesScheduleScreen();
      case 3:
        return const CaptainLeaguesScreen();
      case 4:
        return const CaptainSettingsScreen();
      default:
        return const Center(child: Text('Captain Dashboard'));
    }
  }
}
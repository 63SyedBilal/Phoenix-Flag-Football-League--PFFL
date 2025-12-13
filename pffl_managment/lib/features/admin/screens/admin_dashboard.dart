import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/admin_navigation_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_home/admin_home_screen.dart';
import 'package:pffl_managment/features/admin/screens/admin_leagues/admin_leagues_screen.dart';
import 'package:pffl_managment/features/bottom_nevigation/admin_bottom_nevigation/admin_bottom_nevigation.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_league/free_agent_league_screen.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_setting/free_agent_setting_screen.dart';
import 'package:pffl_managment/features/header_widgets/admin_header_widget/admin_header_widget.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminNavigationProvider()),
      ],
      child: Consumer<AdminNavigationProvider>(
        builder: (context, navigationProvider, _) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  const AdminHeaderWidget(),
                  Expanded(
                    child: _buildContent(navigationProvider.selectedIndex),
                  ),
                  const AdminBottomNevigation(),
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
        return const AdminHomeScreen();
      case 1:
        return const AdminLeaguesScreen();
      case 2:
        return const FreeAgentLeagueScreen();
      case 3:
        return const FreeAgentSettingScreen();
   
      default:
        return const Center(child: Text('Free Agent Dashboard'));
    }
  }
}
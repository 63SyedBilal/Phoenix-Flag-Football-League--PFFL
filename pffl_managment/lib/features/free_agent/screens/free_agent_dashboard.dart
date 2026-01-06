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
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/core/widgets/back_button_wrapper.dart';

class FreeAgentDashboard extends StatelessWidget {
  const FreeAgentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BackButtonWrapper(
      isRoot: true,
      child: MultiProvider(
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
                      child: _buildContent(
                        context,
                        navigationProvider.selectedIndex,
                      ),
                    ),
                    const FreeAgentBottomNevigation(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, int selectedIndex) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userRole = authProvider.userRole.toLowerCase();
        if (userRole != 'free-agent' &&
            userRole != 'freeagent' &&
            userRole != 'free agent') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            String route;
            switch (userRole) {
              case 'player':
                route = AppRoutes.playerDashboard;
                break;
              case 'captain':
                route = AppRoutes.captainDashboard;
                break;
              case 'referee':
                route = AppRoutes.refereeDashboard;
                break;
              case 'statkeeper':
              case 'stat-keeper':
                route = AppRoutes.statKeeperDashboard;
                break;
              default:
                route = AppRoutes.playerDashboard;
            }
            if (context.mounted) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(route, (route) => false);
            }
          });
          return const Center(child: CircularProgressIndicator());
        }
        return IndexedStack(
          index: selectedIndex,
          children: [
            const FreeAgentHomeScreen(),
            ChangeNotifierProvider(
              create: (context) => GamesProvider(
                userRole: authProvider.userRole,
                userId: authProvider.userId,
              ),
              child: const GamesScreen(),
            ),
            ChangeNotifierProvider(
              create: (_) => LeagueProvider(userRole: 'free agent'),
              child: const LeaguesScreen(),
            ),
            ChangeNotifierProvider(
              create: (_) => RoleBasedSettingsProvider(userRole: 'freeagent'),
              child: const SettingsScreen(),
            ),
          ],
        );
      },
    );
  }
}

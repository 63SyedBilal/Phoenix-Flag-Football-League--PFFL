import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/admin_navigation_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_home/admin_home_screen.dart';
import 'package:pffl_managment/features/admin/screens/admin_leagues/leagues_screen.dart';
import 'package:pffl_managment/screens/games/common/games_screen.dart';
import 'package:pffl_managment/screens/games/common/games_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_users/admin_users_screen.dart';
import 'package:pffl_managment/features/bottom_nevigation/admin_bottom_nevigation/admin_bottom_nevigation.dart';
import 'package:pffl_managment/features/header_widgets/admin_header_widget/admin_header_widget.dart';
import 'package:pffl_managment/screens/settings/common/settings_screen.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/widgets/back_button_wrapper.dart';

import 'package:pffl_managment/features/admin/screens/calendar_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminNavigationProvider>(
      builder: (context, navigationProvider, _) {
        final showHeader =
            navigationProvider.selectedIndex != 5 &&
            navigationProvider.selectedIndex != 6;

        return BackButtonWrapper(
          isRoot: true,
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  if (showHeader) const AdminHeaderWidget(),
                  Expanded(
                    child: IndexedStack(
                      index: navigationProvider.selectedIndex,
                      children: [
                        const AdminHomeScreen(),
                        const LeaguesScreen(),
                        ChangeNotifierProvider(
                          create: (context) {
                            final auth = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            return GamesProvider(
                              userRole: auth.userRole,
                              userId: auth.userId,
                            );
                          },
                          child: const GamesScreen(),
                        ),
                        const AdminUsersScreen(),
                        const SettingsScreen(),

                        const CalendarScreen(),
                      ],
                    ),
                  ),
                  const AdminBottomNevigation(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

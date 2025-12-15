import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/game_widgets/upcomming_matches_screens/upcomming_leagues_matches.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_home_screen_widgets/admin_quick_action_section.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_home_screen_widgets/admin_over_view_section.dart';
import 'package:pffl_managment/features/sponsors/screens/sponsor_banner_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          children: [
            AdminOverViewSection(),
            SizedBox(height: 8),
            AdminQuickActionSection(),
            SizedBox(height: 8),
            SponsorBannerScreen(),
            SizedBox(height: 8),
            const UpcommingGames(), // Changed from UpcommingMatches to UpcommingGames for overview section
          ],
        ),
      ),
    );
  }
}
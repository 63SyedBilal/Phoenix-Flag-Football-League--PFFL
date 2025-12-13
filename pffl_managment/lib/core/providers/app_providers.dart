import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/features/admin/leagues/providers/create_league_viewmodel.dart';
import 'package:pffl_managment/features/admin/provider/dashboard_provider.dart';
import 'package:pffl_managment/features/admin/shared/providers/animated_fab_provider.dart';
import 'package:pffl_managment/features/admin/leagues/providers/league_detail_provider.dart';
import 'package:pffl_managment/features/admin/leagues/providers/leagues_provider.dart';
import 'package:pffl_managment/features/admin/leagues/providers/enhanced_leagues_provider.dart';
import 'package:pffl_managment/features/admin/matches/providers/matches_provider.dart';
import 'package:pffl_managment/features/admin/settings/widgets/refund_reason_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/theme_provider.dart';
import 'package:pffl_managment/core/providers/base_provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/admin_navigation_provider.dart';
import 'package:pffl_managment/features/admin/users/providers/users_provider.dart';
import 'package:pffl_managment/features/sponsors/providers/sponsor_banner_provider.dart';
import 'package:pffl_managment/features/admin/settings/providers/settings_provider.dart';
import 'package:pffl_managment/features/admin/matches/providers/edit_match_provider.dart';
import 'package:pffl_managment/features/admin/shared/providers/sponsor_screen_provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/captain_navigation_provider.dart';
import 'package:pffl_managment/features/captain/providers/captain_match_provider.dart';
import 'package:pffl_managment/features/captain/providers/captain_dashboard_provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/player_navigation_provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/referee_navigation_provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/stat_keeper_navigation_provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/free_agent_navigation_provider.dart';
import 'package:pffl_managment/features/player/providers/player_dashboard_provider.dart';
import 'package:pffl_managment/features/referee/providers/referee_dashboard_provider.dart';
import 'package:pffl_managment/features/stat_keeper/providers/stat_keeper_dashboard_provider.dart';
import 'package:pffl_managment/features/free_agent/providers/free_agent_dashboard_provider.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BaseProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => AdminNavigationProvider()),
        ChangeNotifierProvider(create: (_) => CaptainNavigationProvider()),
        ChangeNotifierProvider(create: (_) => CaptainMatchProvider()),
        ChangeNotifierProvider(create: (_) => CaptainDashboardProvider()),
        ChangeNotifierProvider(create: (_) => LeaguesProvider()),
        ChangeNotifierProvider(create: (_) => MatchesProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (_) => SponsorBannerProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LeagueDetailProvider()),
        ChangeNotifierProvider(create: (_) => EditMatchProvider()),
        ChangeNotifierProvider(create: (_) => EnhancedLeaguesProvider()),
        ChangeNotifierProvider(create: (_) => RefundReasonProvider()),
        ChangeNotifierProvider(create: (_) => SponsorScreenProvider()),
        ChangeNotifierProvider(create: (_) => AnimatedFABProvider()),
        ChangeNotifierProvider(create: (_) => PlayerNavigationProvider()),
        ChangeNotifierProvider(create: (_) => RefereeNavigationProvider()),
        ChangeNotifierProvider(create: (_) => StatKeeperNavigationProvider()),
        ChangeNotifierProvider(create: (_) => FreeAgentNavigationProvider()),
        ChangeNotifierProvider(create: (_) => PlayerDashboardProvider()),
        ChangeNotifierProvider(create: (_) => RefereeDashboardProvider()),
        ChangeNotifierProvider(create: (_) => StatKeeperDashboardProvider()),
        ChangeNotifierProvider(create: (_) => FreeAgentDashboardProvider()),
        ChangeNotifierProvider(create: (_) => CreateLeagueViewModel()),
      ],
      child: child,
    );
  }
}
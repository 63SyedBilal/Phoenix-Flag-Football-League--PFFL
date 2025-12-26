import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/core/providers/unified_games_provider.dart';
import 'package:pffl_managment/features/admin/provider/create_league_viewmodel.dart';
import 'package:pffl_managment/features/admin/provider/dashboard_provider.dart';
import 'package:pffl_managment/features/admin/provider/upcoming_games_provider.dart';
import 'package:pffl_managment/features/admin/shared/providers/animated_fab_provider.dart';
import 'package:pffl_managment/features/admin/provider/league_detail_provider.dart';
import 'package:pffl_managment/features/admin/provider/leagues_provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/refund_reason_provider.dart';
import 'package:pffl_managment/features/captain/providers/captain_team_provider.dart';
import 'package:pffl_managment/features/free_agent/providers/free_agent_onboarding_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/theme_provider.dart';
import 'package:pffl_managment/core/providers/base_provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/admin_navigation_provider.dart';
import 'package:pffl_managment/features/admin/provider/admin_user_provider/users_provider.dart';
import 'package:pffl_managment/features/sponsors/providers/sponsor_banner_provider.dart';
import 'package:pffl_managment/core/providers/admin_setting_provider/settings_provider.dart';
import 'package:pffl_managment/features/admin/provider/edit_match_provider.dart';
import 'package:pffl_managment/features/admin/shared/providers/sponsor_screen_provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/captain_navigation_provider.dart';
import 'package:pffl_managment/features/captain/providers/captain_match_provider.dart';
import 'package:pffl_managment/core/captain_provider/home_screen_provider/captain_dashboard_provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/player_navigation_provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/referee_navigation_provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/stat_keeper_navigation_provider.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/free_agent_navigation_provider.dart';
import 'package:pffl_managment/features/player/providers/player_dashboard_provider.dart';
import 'package:pffl_managment/features/referee/providers/referee_dashboard_provider.dart';
import 'package:pffl_managment/features/stat_keeper/providers/stat_keeper_dashboard_provider.dart';
import 'package:pffl_managment/features/free_agent/providers/free_agent_dashboard_provider.dart';
import 'package:pffl_managment/features/admin/leagues/providers/enhanced_leagues_provider.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/providers/create_team_provider.dart';
import 'package:pffl_managment/invite_screens/captain_invite_screen/providers/captain_invite_provider.dart';
import 'package:pffl_managment/features/player/providers/player_team_provider.dart';
import 'package:pffl_managment/core/providers/notification_provider.dart';
import 'package:pffl_managment/core/providers/back_button_provider.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';
import 'package:pffl_managment/core/services/preference_service.dart';
import 'package:pffl_managment/features/referee/providers/complete_referee_profile_provider.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_league_selection/providers/league_selection_provider.dart';
import 'package:pffl_managment/features/free_agent/screens/payment_option/providers/payment_option_provider.dart';
import 'package:pffl_managment/features/free_agent/screens/add_payment_details/providers/add_payment_details_provider.dart';
import 'package:pffl_managment/core/providers/calendar_provider.dart';

class AppProviders extends StatelessWidget {
  final Widget child;
  final PreferenceService preferenceService;

  const AppProviders({
    super.key,
    required this.child,
    required this.preferenceService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Local Storage Service Provider
        Provider<PreferenceService>.value(value: preferenceService),

        // Use Preference Provider
        ChangeNotifierProvider(
          create: (context) => UserPreferenceProvider(preferenceService),
        ),
        ChangeNotifierProxyProvider<
          UserPreferenceProvider,
          CompleteRefereeProfileProvider
        >(
          create: (context) => CompleteRefereeProfileProvider(
            Provider.of<UserPreferenceProvider>(context, listen: false),
          ),
          update: (context, userPrefs, provider) =>
              provider ?? CompleteRefereeProfileProvider(userPrefs),
        ),

        // SINGLE SOURCE OF TRUTH for all games data
        ChangeNotifierProvider(create: (_) => UnifiedGamesProvider()),
        ChangeNotifierProvider(create: (_) => UpcomingGamesProvider()),
        ChangeNotifierProvider(create: (_) => CaptainTeamProvider()),
        ChangeNotifierProvider(create: (_) => BaseProvider()),
        ChangeNotifierProvider(create: (_) => FreeAgentOnboardingProvider()),
        ChangeNotifierProxyProvider<UserPreferenceProvider, AuthProvider>(
          create: (context) => AuthProvider(
            Provider.of<UserPreferenceProvider>(context, listen: false),
          ),
          update: (context, userPrefs, auth) => auth ?? AuthProvider(userPrefs),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        // Navigation providers should be initialized early
        ChangeNotifierProvider(create: (_) => AdminNavigationProvider()),
        ChangeNotifierProvider(create: (_) => CaptainNavigationProvider()),
        ChangeNotifierProvider(create: (_) => PlayerNavigationProvider()),
        ChangeNotifierProvider(create: (_) => RefereeNavigationProvider()),
        ChangeNotifierProvider(create: (_) => StatKeeperNavigationProvider()),
        ChangeNotifierProvider(create: (_) => FreeAgentNavigationProvider()),
        // Other providers
        ChangeNotifierProvider(create: (_) => CaptainMatchProvider()),
        ChangeNotifierProvider(create: (_) => CaptainDashboardProvider()),
        ChangeNotifierProvider(create: (_) => LeaguesProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (_) => SponsorBannerProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LeagueDetailProvider()),
        ChangeNotifierProvider(create: (_) => EditMatchProvider()),
        ChangeNotifierProvider(create: (_) => EnhancedLeaguesProvider()),
        ChangeNotifierProvider(create: (_) => RefundReasonProvider()),
        ChangeNotifierProvider(create: (_) => SponsorScreenProvider()),
        ChangeNotifierProvider(create: (_) => AnimatedFABProvider()),
        ChangeNotifierProvider(create: (_) => PlayerDashboardProvider()),
        ChangeNotifierProvider(create: (_) => RefereeDashboardProvider()),
        ChangeNotifierProvider(create: (_) => StatKeeperDashboardProvider()),
        ChangeNotifierProvider(create: (_) => FreeAgentDashboardProvider()),
        ChangeNotifierProvider(create: (_) => CreateLeagueViewModel()),
        ChangeNotifierProxyProvider<
          UserPreferenceProvider,
          CompleteProfileProvider
        >(
          create: (context) => CompleteProfileProvider(
            Provider.of<UserPreferenceProvider>(context, listen: false),
          ),
          update: (context, userPrefs, provider) =>
              provider ?? CompleteProfileProvider(userPrefs),
        ),
        ChangeNotifierProxyProvider<UserPreferenceProvider, CreateTeamProvider>(
          create: (context) => CreateTeamProvider(
            Provider.of<UserPreferenceProvider>(context, listen: false),
          ),
          update: (context, userPrefs, provider) =>
              provider ?? CreateTeamProvider(userPrefs),
        ),
        ChangeNotifierProvider(create: (_) => CaptainInviteProvider()),
        ChangeNotifierProvider(create: (_) => PlayerTeamProvider()),
        ChangeNotifierProvider(create: (_) => LeagueSelectionProvider()),
        ChangeNotifierProvider(create: (_) => PaymentOptionProvider()),
        ChangeNotifierProvider(create: (_) => AddPaymentDetailsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => BackButtonProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
      ],
      child: child,
    );
  }
}

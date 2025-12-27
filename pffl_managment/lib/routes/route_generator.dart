import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/League_creation_screen/league_creation_screen.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_game_widgets/edit_upcomming_matches.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/create_games_screens/create_games_screen.dart';
import 'package:pffl_managment/features/admin/screens/admin_dashboard.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_detail_view.dart';
import 'package:pffl_managment/features/auth/screens/login_screen.dart';
import 'package:pffl_managment/features/auth/screens/create_profile/create_account_screen.dart';
import 'package:pffl_managment/features/auth/screens/get_started_screen.dart';
import 'package:pffl_managment/features/auth/screens/change_password/change_password_screen.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_dashboard.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_league_selection/league_selection_screen.dart';
import 'package:pffl_managment/features/free_agent/screens/payment_option/payment_option_screen.dart';
import 'package:pffl_managment/features/free_agent/screens/add_payment_details/add_payment_details_screen.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_payment_history_screen.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/complete_profile_screen.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/complete_captain_profile_screen.dart';
import 'package:pffl_managment/features/admin/users/views/my_team.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/payment_receipt_screen.dart';
import 'package:pffl_managment/features/captain/captain_dashboard.dart';
import 'package:pffl_managment/features/captain/view/captain_create_team/captain_create_team.dart';
import 'package:pffl_managment/features/captain/view/leagues/league_detail/captain_league_detail_screen.dart';
import 'package:pffl_managment/features/captain/view/payments/captain_payment_history_view.dart';
import 'package:pffl_managment/invite_screens/admin_invite_screen/admin_invite_screen.dart';
import 'package:pffl_managment/invite_screens/captain_invite_screen/captain_invite_screen.dart';
import 'package:pffl_managment/features/player/screens/player_dashboard.dart';
import 'package:pffl_managment/features/referee/screens/referee_dashboard.dart';
import 'package:pffl_managment/features/referee/screens/referee_game_detail/referee_game_detail_screen.dart';
import 'package:pffl_managment/features/referee/screens/game_management_screen.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_keeper_dashboard.dart';
import 'package:pffl_managment/screens/games/common/games_screen.dart';
import 'package:pffl_managment/screens/notification/player_notification/player_notification.dart';
import 'package:pffl_managment/screens/notification/captain_notification/captain_notification.dart';
import 'package:pffl_managment/screens/notification/admin_notification/admin_notification.dart';
import 'package:pffl_managment/screens/notification/referee_notification/referee_notification.dart';
import 'package:pffl_managment/screens/notification/statkeeper_notification/statkeeper_notification.dart';
import 'package:pffl_managment/screens/notification/freeagent_notification/freeagent_notification.dart';
import 'package:pffl_managment/features/referee/screens/complete_profile/complete_referee_profile_screen.dart';

import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.getStarted:
        return MaterialPageRoute(builder: (_) => GetStartedScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => CreateAccountScreen());

      case AppRoutes.completeProfile:
        return MaterialPageRoute(builder: (_) => const CompleteProfileScreen());

      case AppRoutes.completeCaptainProfile:
        return MaterialPageRoute(
          builder: (_) => const CompleteCaptainProfileScreen(),
        );

      case AppRoutes.changePassword:
        return MaterialPageRoute(
          builder: (_) => const ChangePasswordScreen(),
        );

      case AppRoutes.playerDashboard:
        return MaterialPageRoute(builder: (_) => const PlayerDashboard());

      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());

      case AppRoutes.captainDashboard:
        return MaterialPageRoute(builder: (_) => const CaptainDashboard());

      case AppRoutes.captainCreateTeam:
        return MaterialPageRoute(builder: (_) => const CaptainCreateTeam());

      case AppRoutes.captainInvite:
        return MaterialPageRoute(builder: (_) => const CaptainInviteScreen());

      case AppRoutes.adminUserManagement:
        return MaterialPageRoute(builder: (_) => const UsersView());

      case AppRoutes.adminMatchesManagement:
        return MaterialPageRoute(builder: (_) => const GamesScreen());

      case AppRoutes.adminCreateLeague:
        return MaterialPageRoute(builder: (_) => const LeagueCreationScreen());

      case AppRoutes.adminLeagueDetail:
        final league = settings.arguments as LeagueCreationModel;
        return MaterialPageRoute(
          builder: (_) => LeagueDetailView(league: league),
        );

      case AppRoutes.captainLeagueDetail:
        final league = settings.arguments as LeagueCreationModel;
        return MaterialPageRoute(
          builder: (_) => CaptainLeagueDetailScreen(league: league),
        );

      case AppRoutes.captainPaymentHistory:
        return MaterialPageRoute(
          builder: (_) => const CaptainPaymentHistoryView(),
        );

      case AppRoutes.adminEditMatch:
        final match = settings.arguments as MatchModel;
        return MaterialPageRoute(
          builder: (_) => EditUpcommingMatches(match: match),
        );

      case AppRoutes.adminCreateMatch:
        final league = settings.arguments as LeagueCreationModel?;
        if (league == null) {
          throw Exception(
            'League is required to create a game. Please navigate from a league detail page.',
          );
        }
        return MaterialPageRoute(
          builder: (_) => CreateUpcomingGamesScreen(league: league),
        );

      case AppRoutes.adminInvite:
        print('Routing to adminInvite');
        return MaterialPageRoute(builder: (_) => const AdminInviteScreen());

      case AppRoutes.paymentReceipt:
        final paymentData = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PaymentReceiptScreen(paymentData: paymentData),
        );

      // Added missing route cases
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => GetStartedScreen());

      case AppRoutes.refereeDashboard:
        return MaterialPageRoute(builder: (_) => const RefereeDashboard());

      case AppRoutes.refereeGameManagement:
        return MaterialPageRoute(builder: (_) => const GameManagementScreen());

      case AppRoutes.refereeGameDetail:
        final match = settings.arguments as MatchModel;
        return MaterialPageRoute(
          builder: (_) => RefereeGameDetailScreen(match: match),
        );

      case AppRoutes.completeRefereeProfile:
        return MaterialPageRoute(
          builder: (_) => const CompleteRefereeProfileScreen(),
        );

      case AppRoutes.statKeeperDashboard:
        return MaterialPageRoute(builder: (_) => const StatKeeperDashboard());

      case AppRoutes.freeAgentDashboard:
        return MaterialPageRoute(builder: (_) => const FreeAgentDashboard());

      case AppRoutes.freeAgentActiveLeagues:
        return MaterialPageRoute(builder: (_) => const LeagueSelectionScreen());

      case AppRoutes.freeAgentPaymentOption:
        return MaterialPageRoute(builder: (_) => const PaymentOptionScreen());

      case AppRoutes.freeAgentAddPaymentDetails:
        return MaterialPageRoute(builder: (_) => AddPaymentDetailsScreen());

      case AppRoutes.freeAgentPaymentHistory:
        return MaterialPageRoute(
          builder: (_) => const FreeAgentPaymentHistoryScreen(),
        );

      // Notification Routes
      case AppRoutes.playerNotification:
        return MaterialPageRoute(builder: (_) => const PlayerNotification());

      case AppRoutes.captainNotification:
        return MaterialPageRoute(builder: (_) => const CaptainNotification());

      case AppRoutes.adminNotification:
        return MaterialPageRoute(builder: (_) => const AdminNotification());

      case AppRoutes.refereeNotification:
        return MaterialPageRoute(builder: (_) => const RefereeNotification());

      case AppRoutes.statKeeperNotification:
        return MaterialPageRoute(
          builder: (_) => const StatKeeperNotification(),
        );

      case AppRoutes.freeAgentNotification:
        return MaterialPageRoute(builder: (_) => const FreeAgentNotification());

      // Default route
      default:
        print('Route not found: ${settings.name}');
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    print('ERROR ROUTE CALLED - Route not found');
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(child: Text('ERROR: Route not found')),
        );
      },
    );
  }
}

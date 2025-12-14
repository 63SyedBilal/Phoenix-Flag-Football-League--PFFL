import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_game_widgets/edit_upcomming_matches.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/upcomming_matches_screens/create_upcoming_games_screen.dart';
import 'package:pffl_managment/features/admin/screens/admin_dashboard.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_detail_view.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/create_league/league_creation_screen.dart';
import 'package:pffl_managment/features/auth/screens/login_screen.dart';
import 'package:pffl_managment/features/auth/screens/create_account_screen.dart';
import 'package:pffl_managment/features/auth/screens/get_started_screen.dart';
import 'package:pffl_managment/features/auth/screens/complete_profile.dart';
import 'package:pffl_managment/features/admin/users/views/my_team.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/payment_receipt_screen.dart';
import 'package:pffl_managment/features/captain/screens/captain_dashboard.dart';
import 'package:pffl_managment/features/captain/view/leagues/league_detail/captain_league_detail_screen.dart';
import 'package:pffl_managment/features/captain/view/payments/captain_payment_history_view.dart';
import 'package:pffl_managment/invite_screens/admin_invite_screen/admin_invite_screen.dart';
import 'package:pffl_managment/features/player/screens/player_dashboard.dart';
import 'package:pffl_managment/features/referee/screens/referee_dashboard.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_keeper_dashboard.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_dashboard.dart';
import 'package:pffl_managment/screens/games/common/games_screen.dart';

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
        return MaterialPageRoute(builder: (_) => const CompleteProfile());

      case AppRoutes.playerDashboard:
        return MaterialPageRoute(builder: (_) => const PlayerDashboard());

      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());

      case AppRoutes.captainDashboard:
        return MaterialPageRoute(builder: (_) => const CaptainDashboard());

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
        return MaterialPageRoute(builder: (_) => const EditUpcommingMatches());

      case AppRoutes.adminCreateMatch:
        return MaterialPageRoute(
          builder: (_) => const CreateUpcomingGamesScreen(),
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

      case AppRoutes.statKeeperDashboard:
        return MaterialPageRoute(builder: (_) => const StatKeeperDashboard());

      case AppRoutes.freeAgentDashboard:
        return MaterialPageRoute(builder: (_) => const FreeAgentDashboard());

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
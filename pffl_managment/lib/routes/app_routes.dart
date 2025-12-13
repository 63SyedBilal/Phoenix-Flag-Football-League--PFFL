// App Routes Constants
class AppRoutes {
  // Auth Routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String getStarted = '/get-started';
  static const String completeProfile = '/complete-profile';

  // Player Routes
  static const String playerDashboard = '/player/dashboard';
  static const String playerProfile = '/player/profile';
  static const String playerTeams = '/player/teams';
  static const String playerGames = '/player/games';

  // Captain Routes
  static const String captainDashboard = '/captain/dashboard';
  static const String captainTeamManagement = '/captain/team-management';
  static const String captainGameScheduling = '/captain/game-scheduling';
  static const String captainLeagueDetail = '/captain/league-detail';
  static const String captainPaymentHistory = '/captain/payment-history';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUserManagement = '/admin/user-management';
  static const String adminLeagueManagement = '/admin/league-management';
  static const String adminMatchesManagement = '/admin/matches-management';
  static const String adminCreateLeague = '/admin/create-league';
  static const String adminLeagueDetail = '/admin/league-detail';
  static const String adminLeaguesDashboard = '/admin/leagues-dashboard';
  static const String adminEditMatch = '/admin/edit-match';
  static const String adminCreateMatch = '/admin/create-match';
  static const String adminInvite = '/admin/invite';

  // Referee Routes
  static const String refereeDashboard = '/referee/dashboard';
  static const String refereeGameManagement = '/referee/game-management';

  // Stat Keeper Routes
  static const String statKeeperDashboard = '/stat-keeper/dashboard';
  static const String statKeeperGameStats = '/stat-keeper/game-stats';

  // Free Agent Routes
  static const String freeAgentDashboard = '/free-agent/dashboard';

  // Common Routes
  static const String home = '/';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String help = '/help';
  static const String paymentReceipt = '/payment-receipt';
}
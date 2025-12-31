/// Application configuration constants
class AppConfig {
  // API Configuration
  // Network IP for physical devices and network access
  // For Android emulator, use: 'http://10.0.2.2:3000/api'
  // For iOS simulator, use: 'http://localhost:3000/api'
  // For physical device, use your local network IP: 'http://192.168.18.174:3000/api'
  // Current IP: 192.168.18.174 (updated automatically)

  // Server Configuration
  static const String serverHost = '0.0.0.0'; // Listen on all interfaces
  static const int serverPort = 3000; // Backend server port
  static const String apiPath = '/api'; // API base path

  // Network IP Configuration
  // OLD IP - Commented out on 2025-12-27: static const String networkIp = '192.168.1.3';
  // NEW IP - Set using ipconfig on 2025-12-27
  static const String networkIp = '192.168.1.4'; // Current system IP

  static const String localhost = 'localhost';
  static const String androidEmulatorIp = '10.0.2.2';

  // Get base URL based on platform
  // NOTE: Android Emulator sometimes can't reach 10.0.2.2
  // If 10.0.2.2 doesn't work, try using the network IP instead
  // For mobile devices, use your computer's IP address
  // TEMPORARY: Try localhost for testing (may not work from mobile)
  // static String get baseUrl => 'http://localhost:3000/api';

  // CURRENT: Network IP
  static String get baseUrl => 'http://192.168.18.32:3000/api';

  // ALTERNATIVE: Try 0.0.0.0 (all interfaces)
  // static String get baseUrl => 'http://0.0.0.0:3000/api';

  // NEW IP CONFIGURATION - Set using ipconfig on 2025-12-27
  // Current system IP: 192.168.1.3 (obtained via ipconfig command)
  // For local development and testing on physical devices, uncomment:
  // static String get baseUrl => 'http://192.168.1.3:3000/api';

  // Alternative: Use network IP for physical devices
  static String get networkBaseUrl => 'http://$networkIp:$serverPort$apiPath';

  // Emulator/Simulator URLs
  static String get androidEmulatorUrl =>
      'http://$androidEmulatorIp:$serverPort$apiPath';
  static String get iosSimulatorUrl => 'http://$localhost:$serverPort$apiPath';

  // Full server URLs (without /api)
  static String get serverBaseUrl => 'http://$networkIp:$serverPort';
  static String get localhostServerUrl => 'http://$localhost:$serverPort';

  // API Endpoints - Authentication
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/user'; // POST /user for registration
  static const String loginTestEndpoint = '/login-test';
  static const String completeProfileEndpoint = '/complete-profile';

  // API Endpoints - User Management
  static const String userEndpoint = '/user';
  static const String findUserEndpoint = '/find-user';
  static const String checkUsersEndpoint = '/check-users';
  static const String createTestUsersEndpoint = '/create-test-users';
  static const String seedUsersEndpoint = '/seed-users';

  // API Endpoints - Profile
  static const String profileEndpoint = '/profile';

  // API Endpoints - League
  static const String leagueEndpoint = '/league';

  // API Endpoints - Team
  static const String teamEndpoint = '/team';
  static const String teamInvitePlayerEndpoint = '/team/invite-player';
  static const String teamCodeEndpoint = '/team/code';

  // API Endpoints - Match
  static const String matchEndpoint = '/match';

  // API Endpoints - Notification
  static const String notificationAllEndpoint = '/notification/all';
  static const String notificationAcceptEndpoint = '/notification/accept';
  static const String notificationRejectEndpoint = '/notification/reject';

  // API Endpoints - Payments
  static const String paymentsAllEndpoint = '/payments/all';
  static const String paymentsMyEndpoint = '/payments/my';
  static const String paymentsUnpaidEndpoint = '/payments/unpaid';
  static const String paymentsCreateIntentEndpoint = '/payments/create-intent';
  static const String paymentsConfirmEndpoint = '/payments/confirm';
  static const String paymentsProcessEndpoint = '/payments/process';
  static const String paymentsStripeEndpoint = '/payments/stripe';

  // API Endpoints - Invite
  static const String inviteEndpoint = '/invite';

  // API Endpoints - Upload
  static const String uploadEndpoint = '/upload';

  // API Endpoints - Superadmin
  static const String superadminEndpoint = '/superadmin';
  static const String superadminStatsEndpoint = '/superadmin/stats';
  static const String superadminPaymentsAllEndpoint =
      '/superadmin/payments/all';
  static const String superadminPaymentsUnpaidEndpoint =
      '/superadmin/payments/unpaid';

  // API Endpoints - Test/Debug
  static const String testDbEndpoint = '/test-db';
  static const String testLoginEndpoint = '/test-login';
  static const String testRoleMappingEndpoint = '/test-role-mapping';
  static const String testUpdateRoleEndpoint = '/test-update-role';

  // Timeouts - Increased for better network reliability
  static const Duration connectTimeout = Duration(seconds: 300);
  static const Duration receiveTimeout = Duration(seconds: 300);
  static const Duration sendTimeout = Duration(seconds: 300);
}

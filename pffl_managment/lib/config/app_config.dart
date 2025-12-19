import 'dart:io';
import 'package:flutter/foundation.dart';

/// Application configuration constants
class AppConfig {
  // API Configuration
  // Network IP for physical devices and network access
  // For Android emulator, use: 'http://10.0.2.2:3000/api'
  // For iOS simulator, use: 'http://localhost:3000/api'
  // For physical device, use your local network IP: 'http://192.168.18.32:3000/api'
  // Current IP: 192.168.18.32 (updated automatically)

  // Server Configuration
  static const String serverHost = '0.0.0.0'; // Listen on all interfaces
  static const int serverPort = 3000; // Backend server port
  static const String apiPath = '/api'; // API base path

  // Network IP Configuration
  static const String networkIp = '192.168.18.32'; // Current system IP
  static const String localhost = 'localhost';
  static const String androidEmulatorIp = '10.0.2.2';

  // Get base URL based on platform
  // NOTE: Android Emulator sometimes can't reach 10.0.2.2
  // If 10.0.2.2 doesn't work, try using the network IP instead
  static String get baseUrl {
    if (kIsWeb) {
      // Web platform
      return 'http://$localhost:$serverPort$apiPath';
    } else if (Platform.isAndroid) {
      // Android - Try network IP first (works for both emulator and physical device)
      // If this doesn't work, try 10.0.2.2 for emulator
      return 'http://$networkIp:$serverPort$apiPath'; // Network IP (works for emulator and device)
      // Alternative for Android Emulator only (if network IP doesn't work):
      // return 'http://$androidEmulatorIp:$serverPort$apiPath';
    } else if (Platform.isIOS) {
      // iOS Simulator
      return 'http://$localhost:$serverPort$apiPath';
    } else {
      // Default to network IP for other platforms (Windows, Linux, macOS)
      return 'http://$networkIp:$serverPort$apiPath';
    }
  }

  // Alternative: Use network IP for physical devices
  // Change this if you're using a physical Android device
  static String get networkBaseUrl => 'http://$networkIp:$serverPort$apiPath';

  // Emulator/Simulator URLs
  static String get androidEmulatorUrl => 'http://$androidEmulatorIp:$serverPort$apiPath';
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
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);

  // Get full API URL
  static String getApiUrl(String endpoint) {
    // Remove leading slash if present to avoid double slashes
    final cleanEndpoint = endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint;
    return '$baseUrl/$cleanEndpoint';
  }

  // Helper method to get user-specific endpoint
  static String getUserEndpoint(String userId) {
    return getApiUrl('$userEndpoint/$userId');
  }

  // Helper method to get profile-specific endpoint
  static String getProfileEndpoint(String profileId) {
    return getApiUrl('$profileEndpoint/$profileId');
  }

  // Helper method to get league-specific endpoint
  static String getLeagueEndpoint(String leagueId) {
    return getApiUrl('$leagueEndpoint/$leagueId');
  }

  // Helper method to get team-specific endpoint
  static String getTeamEndpoint(String teamId) {
    return getApiUrl('$teamEndpoint/$teamId');
  }

  // Helper method to get match-specific endpoint
  static String getMatchEndpoint(String matchId) {
    return getApiUrl('$matchEndpoint/$matchId');
  }

  // Helper method to get notification-specific endpoint
  static String getNotificationAcceptEndpoint(String notificationId) {
    return getApiUrl('$notificationAcceptEndpoint/$notificationId');
  }

  static String getNotificationRejectEndpoint(String notificationId) {
    return getApiUrl('$notificationRejectEndpoint/$notificationId');
  }
}

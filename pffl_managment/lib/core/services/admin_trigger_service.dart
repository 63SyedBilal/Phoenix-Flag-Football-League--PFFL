import 'notification_sender_service.dart';

/// Service for Admin specific notification triggers
class AdminTriggerService {
  // ==========================================
  // 6. ADMIN NOTIFICATIONS
  // ==========================================

  /// Triggered when any new user completes registration
  static Future<void> triggerUserRegistered({
    required String userName,
    required String role,
    required String timestamp,
    required String userId,
  }) async {
    await NotificationSenderService.sendAdminNotification(
      message: 'New user registered: $userName as $role on $timestamp',
      type: 'ADMIN_USER_REGISTRATION',
      additionalData: {'userId': userId},
    );
  }

  /// Triggered when player pays league fee
  static Future<void> triggerPlayerLeaguePayment({
    required String playerName,
    required double amount,
    required String leagueName,
    required String teamName,
    required String timestamp,
    required String paymentId,
    required String playerId,
  }) async {
    await NotificationSenderService.sendAdminNotification(
      message:
          'League Payment: $playerName paid \$$amount for $leagueName - $teamName on $timestamp. Payment ID: $paymentId',
      type: 'ADMIN_LEAGUE_PAYMENT',
      additionalData: {'paymentId': paymentId, 'playerId': playerId},
    );
  }

  /// Triggered when match is completed
  static Future<void> triggerMatchCompleted({
    required String teamA,
    required String teamB,
    required int scoreA,
    required int scoreB,
    required String leagueName,
    required String matchId,
  }) async {
    await NotificationSenderService.sendAdminNotification(
      message:
          'Match completed: $teamA $scoreA - $scoreB $teamB in $leagueName',
      type: 'ADMIN_MATCH_COMPLETED',
      additionalData: {'matchId': matchId},
    );
  }

  /// Triggered when user requests refund
  static Future<void> triggerRefundRequested({
    required String userName,
    required double amount,
    required String reason,
    required String paymentId,
    required String userId,
  }) async {
    await NotificationSenderService.sendAdminNotification(
      message:
          'Refund requested: $userName requested refund of \$$amount for $reason. Payment ID: $paymentId',
      type: 'ADMIN_REFUND_REQUEST',
      additionalData: {'paymentId': paymentId, 'userId': userId},
    );
  }

  /// Triggered when user submits report
  static Future<void> triggerReportReceived({
    required String userName,
    required String reportType,
    required String description,
    required String userId,
  }) async {
    await NotificationSenderService.sendAdminNotification(
      message: 'Report from $userName: $reportType - $description',
      type: 'ADMIN_REPORT_RECEIVED',
      additionalData: {'userId': userId},
    );
  }

  /// Triggered when a player rejects an invitation
  static Future<void> triggerPlayerRejectedInvite({
    required String playerName,
    required String teamName,
    required String captainName,
    required String teamId,
    required String playerId,
  }) async {
    await NotificationSenderService.sendAdminNotification(
      message:
          '$playerName rejected invitation to join $teamName by Captain $captainName',
      type: 'ADMIN_INVITATION_REJECTED',
      additionalData: {'teamId': teamId, 'playerId': playerId},
    );
  }
}

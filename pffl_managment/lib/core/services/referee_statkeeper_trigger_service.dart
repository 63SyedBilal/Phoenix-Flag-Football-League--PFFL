import 'notification_sender_service.dart';

/// Service for Referee and Stat Keeper specific notification triggers
class RefereeStatKeeperTriggerService {
  // ==========================================
  // 2. REFEREE NOTIFICATIONS
  // ==========================================

  /// Triggered when referee is assigned to a match
  static Future<void> triggerRefereeAssigned({
    required String refereeId,
    required String refereeName,
    required String teamA,
    required String teamB,
    required String venue,
    required String date,
    required String time,
    required String matchId,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: refereeId,
      type: 'MATCH_ASSIGNED',
      message:
          'You have been assigned as referee for $teamA vs $teamB at $venue on $date at $time',
      matchId: matchId,
    );

    // ALSO send to Admin
    await NotificationSenderService.sendAdminNotification(
      message: 'Referee $refereeName assigned to $teamA vs $teamB',
      type: 'ADMIN_REFEREE_ASSIGNED',
    );
  }

  /// Triggered when assigned match is cancelled
  static Future<void> triggerRefereeMatchCancelled({
    required String refereeId,
    required String teamA,
    required String teamB,
    required String originalDate,
    required String matchId,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: refereeId,
      type: 'MATCH_CANCELLED',
      message:
          '$teamA vs $teamB scheduled for $originalDate has been cancelled',
      matchId: matchId,
    );
  }

  // ==========================================
  // 3. STAT KEEPER NOTIFICATIONS
  // ==========================================

  /// Triggered when stat keeper is assigned to a match
  static Future<void> triggerStatKeeperAssigned({
    required String statKeeperId,
    required String statKeeperName,
    required String teamA,
    required String teamB,
    required String venue,
    required String date,
    required String time,
    required String matchId,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: statKeeperId,
      type: 'MATCH_ASSIGNED',
      message:
          'You have been assigned as stat keeper for $teamA vs $teamB at $venue on $date at $time',
      matchId: matchId,
    );

    // ALSO send to Admin
    await NotificationSenderService.sendAdminNotification(
      message: 'Stat Keeper $statKeeperName assigned to $teamA vs $teamB',
      type: 'ADMIN_STAT_KEEPER_ASSIGNED',
    );
  }

  /// Triggered when assigned match is rescheduled
  static Future<void> triggerMatchRescheduled({
    required String staffId, // Can be referee or stat keeper
    required String teamA,
    required String teamB,
    required String newDate,
    required String newTime,
    required String venue,
    required String matchId,
    required bool isReferee,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: staffId,
      type: 'MATCH_RESCHEDULED',
      message: '$teamA vs $teamB rescheduled to $newDate at $newTime at $venue',
      matchId: matchId,
    );
  }

  /// Triggered when staff receives payment for a match
  static Future<void> triggerStaffPaymentReceived({
    required String staffId,
    required double amount,
    required String teamA,
    required String teamB,
    required String date,
    required String receiptId,
    required String matchId,
    required bool isReferee,
  }) async {
    final role = isReferee ? 'refereeing' : 'stat keeping';
    await NotificationSenderService.sendNotification(
      receiverId: staffId,
      type: 'STAFF_PAYMENT_RECEIVED',
      message:
          'Payment of \$$amount received for $role $teamA vs $teamB on $date. Receipt: $receiptId',
      matchId: matchId,
    );
  }
}

import 'notification_sender_service.dart';

/// Service for Player and Free Agent specific notification triggers
class PlayerFreeAgentTriggerService {
  // ==========================================
  // 4. PLAYER NOTIFICATIONS
  // ==========================================

  /// Triggered when player receives team invitation
  static Future<void> triggerPlayerInvitationReceived({
    required String playerId,
    required String playerName,
    required String teamName,
    required String captainName,
    required String teamId,
    required String captainId,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: playerId,
      type: 'TEAM_INVITATION',
      message:
          'You have been invited to join $teamName by Captain $captainName',
      teamId: teamId,
      senderId: captainId,
    );

    // ALSO send to Admin
    await NotificationSenderService.sendAdminNotification(
      message: 'Player $playerName received invitation to $teamName',
      type: 'ADMIN_INVITATION_RECEIVED',
    );
  }

  /// Triggered when captain removes player from team
  static Future<void> triggerRemovedFromTeam({
    required String playerId,
    required String teamName,
    required String teamId,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: playerId,
      type: 'REMOVED_FROM_TEAM',
      message: 'You have been removed from $teamName',
      teamId: teamId,
    );
  }

  // ==========================================
  // 5. FREE AGENT NOTIFICATIONS
  // ==========================================

  /// Triggered after admin verifies free agent profile
  static Future<void> triggerProfileVerified({required String userId}) async {
    await NotificationSenderService.sendNotification(
      receiverId: userId,
      type: 'PROFILE_VERIFIED',
      message:
          'Your free agent profile has been verified and is now visible to teams',
    );
  }

  /// Triggered if admin rejects profile
  static Future<void> triggerProfileRejected({
    required String userId,
    required String reason,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: userId,
      type: 'PROFILE_REJECT_REASON',
      message:
          'Your profile needs additional information. Please update and resubmit. Reason: $reason',
    );
  }

  /// Triggered when captain views free agent profile
  static Future<void> triggerProfileViewed({
    required String freeAgentId,
    required String captainName,
    required String teamName,
    required String captainId,
    required String teamId,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: freeAgentId,
      type: 'PROFILE_VIEWED',
      message: 'Captain $captainName from $teamName viewed your profile',
      teamId: teamId,
      senderId: captainId,
    );
  }

  /// Triggered after accepting invitation and joining team
  static Future<void> triggerJoinedTeamSuccess({
    required String userId,
    required String teamName,
    required String teamId,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: userId,
      type: 'JOINED_TEAM_SUCCESS',
      message: 'Congratulations! You have successfully joined $teamName',
      teamId: teamId,
    );
  }

  /// Triggered after successfully paying league registration fee
  static Future<void> triggerPlayerLeaguePayment({
    required String userId,
    required String leagueName,
    required double amount,
    required String teamName,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: userId,
      type: 'PLAYER_LEAGUE_PAYMENT',
      message:
          'Payment Successful! You have paid \$$amount for $leagueName as part of team $teamName',
    );
  }
}

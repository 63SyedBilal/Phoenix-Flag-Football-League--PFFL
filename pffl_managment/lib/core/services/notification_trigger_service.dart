import 'notification_sender_service.dart';

/// Service to handle all business logic triggers for notifications
class NotificationTriggerService {
  static const String adminEmail = 'pffl@gmail.com';

  // ==========================================
  // 1. CAPTAIN NOTIFICATIONS
  // ==========================================

  /// Triggered when player accepts team invitation
  static Future<void> triggerPlayerJoinedTeam({
    required String captainId,
    required String playerName,
    required String teamName,
    required String teamId,
    required String playerId,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: captainId,
      type: 'TEAM_JOINED',
      message: '$playerName has joined your team $teamName',
      teamId: teamId,
    );
  }

  /// Triggered when player leaves team
  static Future<void> triggerPlayerLeftTeam({
    required String captainId,
    required String playerName,
    required String teamName,
    required String teamId,
    required String playerId,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: captainId,
      type: 'TEAM_LEFT',
      message: '$playerName has left your team $teamName',
      teamId: teamId,
    );
  }

  /// Triggered after captain sends invitation to player
  static Future<void> triggerInvitationSent({
    required String captainId,
    required String playerName,
    required String teamName,
    required String teamId,
    required String playerId,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: captainId,
      type: 'INVITATION_SENT_CONFIRM',
      message: 'Invitation sent to $playerName to join $teamName',
      teamId: teamId,
    );

    // Also notify Admin
    await triggerAdminTeamInvitationSent(
      captainId: captainId,
      playerName: playerName,
      teamName: teamName,
      captainName: 'Captain', // Better if we had it
    );
  }

  /// Triggered when team registration is successful
  static Future<void> triggerLeagueRegistrationSuccessful({
    required String captainId,
    required String teamName,
    required String leagueName,
    required String leagueId,
    required String teamId,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: captainId,
      type: 'LEAGUE_REGISTRATION_SUCCESS',
      message: 'Your team $teamName has been registered for $leagueName',
      leagueId: leagueId,
      teamId: teamId,
    );

    // Also notify Admin
    await triggerAdminTeamRegisteredInLeague(
      teamName: teamName,
      leagueName: leagueName,
      captainName: 'Captain',
      teamId: teamId,
      leagueId: leagueId,
    );
  }

  /// Triggered when leadership is transferred
  static Future<void> triggerLeadershipTransferred({
    required String oldCaptainId,
    required String newCaptainId,
    required String newCaptainName,
    required String oldCaptainName,
    required String teamName,
    required String teamId,
  }) async {
    // Notify old captain
    await NotificationSenderService.sendNotification(
      receiverId: oldCaptainId,
      type: 'LEADERSHIP_GIVEN',
      message: 'You have transferred captaincy of $teamName to $newCaptainName',
      teamId: teamId,
    );

    // Notify new captain
    await NotificationSenderService.sendNotification(
      receiverId: newCaptainId,
      type: 'LEADERSHIP_RECEIVED',
      message:
          'You are now the captain of $teamName. Leadership transferred from $oldCaptainName',
      teamId: teamId,
    );
  }

  // ==========================================
  // 6. ADMIN NOTIFICATIONS (Partial - more in separate file if long)
  // ==========================================

  static Future<void> triggerAdminTeamInvitationSent({
    required String captainId,
    required String playerName,
    required String teamName,
    required String captainName,
  }) async {
    await NotificationSenderService.sendAdminNotification(
      message:
          'Captain $captainName sent invitation to $playerName for $teamName',
      type: 'ADMIN_INVITATION_SENT',
    );
  }

  static Future<void> triggerAdminTeamRegisteredInLeague({
    required String teamName,
    required String leagueName,
    required String captainName,
    required String teamId,
    required String leagueId,
  }) async {
    await NotificationSenderService.sendAdminNotification(
      message:
          'Team Registration: $teamName registered for $leagueName by Captain $captainName',
      type: 'ADMIN_TEAM_REGISTRATION',
    );
  }

  static Future<void> triggerPlayerDeclinedTeamInvite({
    required String captainId,
    required String playerName,
    required String teamName,
    required String teamId,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: captainId,
      type: 'INVITATION_DECLINED',
      message: '$playerName declined your invitation to join $teamName',
      teamId: teamId,
    );
  }

  /// Triggered when referee accepts league invitation
  static Future<void> triggerRefereeAcceptedInvite({
    required String senderId,
    required String refereeName,
    required String leagueName,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: senderId,
      type: 'INVITATION_ACCEPTED',
      message: 'Referee $refereeName accepted your invitation for $leagueName',
    );
  }

  /// Triggered when referee rejects league invitation
  static Future<void> triggerRefereeRejectedInvite({
    required String senderId,
    required String refereeName,
    required String leagueName,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: senderId,
      type: 'INVITATION_REJECTED',
      message: 'Referee $refereeName rejected your invitation for $leagueName',
    );
  }

  /// Triggered when statkeeper accepts league invitation
  static Future<void> triggerStatKeeperAcceptedInvite({
    required String senderId,
    required String statKeeperName,
    required String leagueName,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: senderId,
      type: 'INVITATION_ACCEPTED',
      message:
          'Stat Keeper $statKeeperName accepted your invitation for $leagueName',
    );
  }

  /// Triggered when statkeeper rejects league invitation
  static Future<void> triggerStatKeeperRejectedInvite({
    required String senderId,
    required String statKeeperName,
    required String leagueName,
  }) async {
    await NotificationSenderService.sendNotification(
      receiverId: senderId,
      type: 'INVITATION_REJECTED',
      message:
          'Stat Keeper $statKeeperName rejected your invitation for $leagueName',
    );
  }
}

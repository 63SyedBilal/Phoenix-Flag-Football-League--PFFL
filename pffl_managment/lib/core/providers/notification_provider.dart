import 'package:flutter/material.dart';
import 'package:pffl_managment/core/models/notification_model.dart';
import 'package:pffl_managment/core/services/notification_service.dart';
import 'package:pffl_managment/core/services/payment_service.dart';
import 'package:pffl_managment/core/services/notification_trigger_service.dart';
import 'package:pffl_managment/core/services/player_freeagent_trigger_service.dart';
import 'package:pffl_managment/core/services/admin_trigger_service.dart';
import 'package:pffl_managment/features/stat_keeper/repositories/stat_keeper_repository_fixed.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing notifications
class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  Set<String> _readNotificationIds = {};
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  bool get hasNotifications => _unreadCount > 0;

  NotificationProvider() {
    _initProvider();
  }

  Future<void> _initProvider() async {
    await _loadReadStatus();
    await loadNotifications();
  }

  Future<void> _loadReadStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIds = prefs.getStringList('read_notifications') ?? [];
      _readNotificationIds = Set<String>.from(readIds);
    } catch (e) {}
  }

  Future<void> _saveReadStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'read_notifications',
        _readNotificationIds.toList(),
      );
    } catch (e) {}
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current user role and email to decide whether to fetch payments
      final prefs = await SharedPreferences.getInstance();
      final userRole = prefs.getString('userRole')?.toLowerCase() ?? '';
      final userEmail = prefs.getString('userEmail') ?? 'Unknown';
      final isAdmin = userRole == 'admin';

      // Fetch role-specific notifications
      print(
        '🔄 [NOTIFICATION PROVIDER] Fetching notifications for user: $userEmail (Role: $userRole)',
      );

      List<NotificationModel> roleSpecificNotifications =
          await NotificationService.getNotificationsByRole(userRole);

      print(
        '✅ [NOTIFICATION PROVIDER] Fetched ${roleSpecificNotifications.length} role-specific notifications for $userEmail',
      );

      // Log role-specific notifications for debugging
      for (int i = 0; i < roleSpecificNotifications.length; i++) {
        final notif = roleSpecificNotifications[i];
        print(
          '   [$i] ID: ${notif.id}, Type: ${notif.type}, Status: ${notif.status}',
        );
      }

      // Fetch payment notifications for admin only
      List<NotificationModel> paymentNotifications = [];
      if (isAdmin) {
        final paymentMaps = await _fetchPaymentNotifications();
        paymentNotifications = paymentMaps
            .map((map) {
              try {
                return NotificationModel.fromJson(map);
              } catch (e) {
                print(
                  '⚠️ [NOTIFICATION PROVIDER DEBUG] Error converting payment: $e',
                );
                return null;
              }
            })
            .whereType<NotificationModel>()
            .toList();
      }

      _notifications = [...roleSpecificNotifications, ...paymentNotifications];
      print(
        '✅ [NOTIFICATION PROVIDER] Total notifications for $userEmail: ${_notifications.length} (${roleSpecificNotifications.length} role-specific + ${paymentNotifications.length} payment)',
      );

      // Sort by date descending
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Log team invite notifications specifically
      final teamInvites = _notifications
          .where((n) => n.type.contains('TEAM') || n.type.contains('INVITE'))
          .toList();
      print(
        '🎯 [NOTIFICATION PROVIDER DEBUG] Found ${teamInvites.length} team/invite notifications:',
      );
     

      _updateUnreadCount();
      print('✅ [NOTIFICATION PROVIDER] Unread count: $_unreadCount');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load notifications: ${e.toString()}';
      print('❌ [NOTIFICATION PROVIDER] Error loading notifications: $e');
      notifyListeners();
    }
  }

  /// Fetch payment notifications for Admin
  Future<List<Map<String, dynamic>>> _fetchPaymentNotifications() async {
    try {
      final payments = await PaymentService.getAllPayments('all');
      final List<Map<String, dynamic>> notifications = [];

      for (var payment in payments) {
        final status = payment['status']?.toString().toLowerCase() ?? 'pending';
        // Only include paid/pending for notifications
        if (status != 'paid' && status != 'pending' && status != 'unpaid')
          continue;

        final createdAtStr =
            payment['createdAt']?.toString() ??
            payment['updatedAt']?.toString() ??
            DateTime.now().toIso8601String();
        final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();

        final userId = payment['userId'];
        String playerName = 'A player';
        Map<String, dynamic>? senderData;
        if (userId is Map<String, dynamic>) {
          senderData = userId;
          playerName =
              '${userId['firstName'] ?? ''} ${userId['lastName'] ?? ''}'.trim();
          if (playerName.isEmpty) playerName = userId['email'] ?? 'A player';
        }

        final leagueId = payment['leagueId'];
        String leagueName = 'the league';
        Map<String, dynamic>? leagueData;
        if (leagueId is Map<String, dynamic>) {
          leagueData = leagueId;
          leagueName = leagueId['leagueName'] ?? 'the league';
        }

        final amount = payment['amount']?.toString() ?? '0';
        String msg = '';
        String type = '';

        if (status == 'paid') {
          type = 'PAYMENT_RECEIVED';
          msg = '$playerName has paid \$$amount for $leagueName.';
        } else {
          type = 'PAYMENT_PENDING';
          msg =
              '$playerName\'s payment of \$$amount for $leagueName is pending.';
        }

        notifications.add({
          '_id': 'pay_${payment['_id'] ?? payment['id']}',
          'type': type,
          'status': 'accepted', // Payments are not "pending action" invitations
          'message': msg,
          'createdAt': createdAt.toIso8601String(),
          'updatedAt': createdAt.toIso8601String(),
          'sender': senderData,
          'league': leagueData,
        });
      }
      return notifications;
    } catch (e) {
      return [];
    }
  }

  void _updateUnreadCount() {
    // A notification is unread if it's NOT in our read set
    _unreadCount = _notifications
        .where((n) => !_readNotificationIds.contains(n.id))
        .length;
  }

  Future<void> markAsRead(String notificationId) async {
    if (!_readNotificationIds.contains(notificationId)) {
      _readNotificationIds.add(notificationId);
      _updateUnreadCount();
      notifyListeners();
      await _saveReadStatus();
    }
  }

  Future<void> markAllAsRead() async {
    bool changed = false;
    for (var n in _notifications) {
      if (!_readNotificationIds.contains(n.id)) {
        _readNotificationIds.add(n.id);
        changed = true;
      }
    }

    if (changed) {
      _updateUnreadCount();
      notifyListeners();
      await _saveReadStatus();
    }
  }

  Future<Map<String, dynamic>> acceptNotification(String notificationId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      // Get notification details before accepting
      final notification = _notifications.firstWhere(
        (n) => n.id == notificationId,
      );

      final result = await NotificationService.acceptNotification(
        notificationId,
      );
      if (result['success'] == true) {
        // Trigger notifications
        if (notification.type.contains('TEAM_INVITE') ||
            notification.type.contains('INVITATION')) {
          final captainId = notification.sender?.id ?? '';
          final playerName = notification.receiver?.firstName ?? 'A player';
          final teamName = notification.team?.teamName ?? 'Team';
          final teamId = notification.team?.id ?? '';
          final playerId = notification.receiver?.id ?? '';
          final captainName = notification.sender?.firstName ?? 'Captain';

          // Notify Captain
          await NotificationTriggerService.triggerPlayerJoinedTeam(
            captainId: captainId,
            playerName: playerName,
            teamName: teamName,
            teamId: teamId,
            playerId: playerId,
          );

          // Notify Admin
          await NotificationTriggerService.triggerAdminTeamRegisteredInLeague(
            teamName: teamName,
            leagueName: notification.league?.leagueName ?? 'League',
            captainName: captainName,
            teamId: teamId,
            leagueId: notification.league?.id ?? '',
          );

          // Notify Player (Welcome)
          await PlayerFreeAgentTriggerService.triggerJoinedTeamSuccess(
            userId: playerId,
            teamName: teamName,
            teamId: teamId,
          );
        }

        await loadNotifications();
        return result;
      }
      _errorMessage = 'Failed to accept notification';
      notifyListeners();
      return {'success': false, 'roleChanged': false};
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return {'success': false, 'roleChanged': false};
    }
  }

  Future<bool> approveStats(String notificationId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      // Find the notification to get the match ID and sender ID (Stat Keeper)
      final notification = _notifications.firstWhere(
        (n) => n.id == notificationId,
      );
      final matchId =
          notification.match?['_id']?.toString() ??
          notification.match?['id']?.toString();
      final senderId = notification.sender?.id;

      if (matchId == null || senderId == null) {
        _errorMessage = 'Match ID or Stat Keeper ID not found in notification';
        notifyListeners();
        return false;
      }

      await StatKeeperRepositoryFixed.approveStats(matchId, senderId);

      await loadNotifications();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to approve stats: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectNotification(String notificationId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      // Get notification details before rejecting
      final notification = _notifications.firstWhere(
        (n) => n.id == notificationId,
      );

      final success = await NotificationService.rejectNotification(
        notificationId,
      );
      if (success) {
        // Trigger rejection notifications
        if (notification.type.contains('TEAM_INVITE') ||
            notification.type.contains('INVITATION')) {
          final captainId = notification.sender?.id ?? '';
          final playerName = notification.receiver?.firstName ?? 'A player';
          final teamName = notification.team?.teamName ?? 'Team';
          final teamId = notification.team?.id ?? '';
          final captainName = notification.sender?.firstName ?? 'Captain';
          final playerId = notification.receiver?.id ?? '';

          // Notify Captain
          await NotificationTriggerService.triggerPlayerDeclinedTeamInvite(
            captainId: captainId,
            playerName: playerName,
            teamName: teamName,
            teamId: teamId,
          );

          // Notify Admin
          await AdminTriggerService.triggerPlayerRejectedInvite(
            playerName: playerName,
            teamName: teamName,
            captainName: captainName,
            teamId: teamId,
            playerId: playerId,
          );
        }

        await loadNotifications();
        return true;
      }
      _errorMessage = 'Failed to reject notification';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh() async {
    await loadNotifications();
  }
}

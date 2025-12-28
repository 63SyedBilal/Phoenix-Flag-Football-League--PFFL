import 'package:flutter/material.dart';
import 'package:pffl_managment/core/models/notification_model.dart';
import 'package:pffl_managment/core/services/notification_service.dart';
import 'package:pffl_managment/core/services/payment_service.dart';
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
    } catch (e) {
      print('❌ Error loading read status: $e');
    }
  }

  Future<void> _saveReadStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'read_notifications',
        _readNotificationIds.toList(),
      );
    } catch (e) {
      print('❌ Error saving read status: $e');
    }
  }

  Future<void> loadNotifications() async {
    print('🔄 [NOTIFICATION PROVIDER DEBUG] Starting loadNotifications...');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current user role to decide whether to fetch payments
      final prefs = await SharedPreferences.getInstance();
      final userRole = prefs.getString('userRole')?.toLowerCase() ?? '';
      final userId = prefs.getString('userId') ?? '';
      final isAdmin = userRole == 'admin';

      print('🔄 [NOTIFICATION PROVIDER DEBUG] User info:');
      print('   - User ID: $userId');
      print('   - User Role: $userRole');
      print('   - Is Admin: $isAdmin');

      // Fetch role-specific notifications
      print(
        '🔄 [NOTIFICATION PROVIDER DEBUG] Fetching role-specific notifications for: $userRole',
      );

      List<NotificationModel> roleSpecificNotifications;
      switch (userRole) {
        case 'player':
          roleSpecificNotifications =
              await NotificationService.getPlayerNotifications();
          break;
        case 'captain':
          roleSpecificNotifications =
              await NotificationService.getCaptainNotifications();
          break;
        case 'admin':
        case 'superadmin':
          roleSpecificNotifications =
              await NotificationService.getAdminNotifications();
          break;
        case 'referee':
          roleSpecificNotifications =
              await NotificationService.getRefereeNotifications();
          print(
            '🎯 [NOTIFICATION PROVIDER] Referee notifications: ${roleSpecificNotifications.length}',
          );
          for (final notif in roleSpecificNotifications) {
            print('   - ${notif.type}: ${notif.message}');
          }
          break;
        case 'stat-keeper':
        case 'statkeeper':
          roleSpecificNotifications =
              await NotificationService.getStatKeeperNotifications();
          print(
            '🎯 [NOTIFICATION PROVIDER] Stat keeper notifications: ${roleSpecificNotifications.length}',
          );
          for (final notif in roleSpecificNotifications) {
            print('   - ${notif.type}: ${notif.message}');
          }
          break;
        case 'free-agent':
        case 'freeagent':
          roleSpecificNotifications =
              await NotificationService.getFreeAgentNotifications();
          break;
        default:
          // Fallback to all notifications if role is unknown
          print(
            '⚠️ [NOTIFICATION PROVIDER DEBUG] Unknown role "$userRole", fetching all notifications',
          );
          roleSpecificNotifications =
              await NotificationService.getAllNotifications();
      }

      print(
        '✅ [NOTIFICATION PROVIDER DEBUG] Fetched ${roleSpecificNotifications.length} role-specific notifications',
      );

      // Log role-specific notifications for debugging
      print('🔄 [NOTIFICATION PROVIDER DEBUG] Role-specific notifications:');
      for (int i = 0; i < roleSpecificNotifications.length; i++) {
        final notif = roleSpecificNotifications[i];
        print(
          '   [$i] ID: ${notif.id}, Type: ${notif.type}, Status: ${notif.status}',
        );
        print('       Message: ${notif.message}');
        print('       Sender: ${notif.senderName}');
        print('       Team: ${notif.teamName}');
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
        '✅ [NOTIFICATION PROVIDER DEBUG] Total notifications: ${_notifications.length} (${roleSpecificNotifications.length} role-specific + ${paymentNotifications.length} payment)',
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
      for (final invite in teamInvites) {
        print('   - ${invite.type}: ${invite.message}');
      }

      _updateUnreadCount();

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load notifications: ${e.toString()}';
      print('❌ [NOTIFICATION PROVIDER DEBUG] Error: $e');
      print('❌ [NOTIFICATION PROVIDER DEBUG] Stack: $stackTrace');
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
      print('❌ Error fetching payment notifications: $e');
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
      final result = await NotificationService.acceptNotification(
        notificationId,
      );
      if (result['success'] == true) {
        await loadNotifications();
        return result;
      }
      _errorMessage = 'Failed to accept notification';
      notifyListeners();
      return {'success': false, 'roleChanged': false};
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('❌ Error accepting notification: $e');
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
      print('❌ Error approving stats: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectNotification(String notificationId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await NotificationService.rejectNotification(
        notificationId,
      );
      if (success) {
        await loadNotifications();
        return true;
      }
      _errorMessage = 'Failed to reject notification';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('❌ Error rejecting notification: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh() async {
    await loadNotifications();
  }
}

import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/notification_service.dart';
import 'package:pffl_managment/core/services/payment_service.dart';
import 'package:pffl_managment/features/stat_keeper/repositories/stat_keeper_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model for notification data
class NotificationModel {
  final String id;
  final String type;
  final String status;
  final String? format;
  final Map<String, dynamic>? sender;
  final Map<String, dynamic>? receiver;
  final Map<String, dynamic>? team;
  final Map<String, dynamic>? league;
  final Map<String, dynamic>? match;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? message;

  NotificationModel({
    required this.id,
    required this.type,
    required this.status,
    this.format,
    this.sender,
    this.receiver,
    this.team,
    this.league,
    this.match,
    required this.createdAt,
    required this.updatedAt,
    this.message,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'pending',
      format: json['format']?.toString(),
      sender: json['sender'] is Map
          ? Map<String, dynamic>.from(json['sender'])
          : null,
      receiver: json['receiver'] is Map
          ? Map<String, dynamic>.from(json['receiver'])
          : null,
      team: json['team'] is Map
          ? Map<String, dynamic>.from(json['team'])
          : null,
      league: json['league'] is Map
          ? Map<String, dynamic>.from(json['league'])
          : null,
      match: json['match'] is Map
          ? Map<String, dynamic>.from(json['match'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      message: json['message']?.toString(),
    );
  }

  String get senderName {
    if (sender == null) return 'Unknown';
    final firstName = sender!['firstName'] ?? '';
    final lastName = sender!['lastName'] ?? '';
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    return sender!['email'] ?? 'Unknown';
  }

  String get teamName => team?['teamName'] ?? 'Unknown Team';
  String get leagueName => league?['leagueName'] ?? 'Unknown League';
  String? get teamImage => team?['image']?.toString();
  String? get leagueLogo => league?['logo']?.toString();

  // Match information getters
  String get matchTeamA =>
      match?['teamAName']?.toString() ??
      match?['teamA']?.toString() ??
      'Team A';
  String get matchTeamB =>
      match?['teamBName']?.toString() ??
      match?['teamB']?.toString() ??
      'Team B';
  String? get matchVenue => match?['venue']?.toString();
  String? get matchGameTime => match?['gameTime']?.toString();
  DateTime? get matchGameDate {
    if (match?['gameDate'] != null) {
      try {
        return DateTime.parse(match!['gameDate'].toString());
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String get displayMessage {
    if (message != null && message!.isNotEmpty) {
      return message!;
    }

    switch (type) {
      case 'TEAM_INVITE':
        if (league != null && leagueName != 'Unknown League') {
          return 'You\'ve been invited by $senderName to join the team $teamName for the upcoming league.';
        } else {
          return 'You\'ve been invited by $senderName to join the team $teamName.';
        }
      case 'TEAM_INVITE_ACCEPTED':
        final formatStr = format ?? 'team';
        return '$senderName has accepted your invitation to join the $formatStr squad';
      case 'LEAGUE_REFEREE_INVITE':
        return '$senderName invited you to be a referee for $leagueName';
      case 'LEAGUE_STATKEEPER_INVITE':
        return '$senderName invited you to be a stat keeper for $leagueName';
      case 'LEAGUE_TEAM_INVITE':
        return 'Your team "$teamName" has been invited to participate in the league "$leagueName". Would you like to accept the invitation?';
      case 'GAME_ASSIGNED':
        final matchTeamA =
            match?['teamAName']?.toString() ??
            match?['teamA']?.toString() ??
            'Team A';
        final matchTeamB =
            match?['teamBName']?.toString() ??
            match?['teamB']?.toString() ??
            'Team B';
        final gameDate = match?['gameDate'] != null
            ? DateTime.tryParse(match!['gameDate'].toString())
            : null;
        final dateStr = gameDate != null
            ? '${gameDate.day}/${gameDate.month}/${gameDate.year}'
            : '';
        if (dateStr.isNotEmpty) {
          return 'Aapko ek game assign hua hai: $matchTeamA vs $matchTeamB on $dateStr';
        } else {
          return 'Aapko ek game assign hua hai: $matchTeamA vs $matchTeamB';
        }
      case 'INVITE_ACCEPTED_REFEREE':
        return '$senderName has accepted your invitation to be a referee for $leagueName';
      case 'INVITE_ACCEPTED_STATKEEPER':
        return '$senderName has accepted your invitation to be a stat keeper for $leagueName';
      case 'INVITE_ACCEPTED_TEAM':
        return '$senderName has accepted your invitation for team "$teamName" to participate in the league "$leagueName"';
      case 'STATS_APPROVAL_REQUEST':
        final matchTeamA =
            match?['teamAName']?.toString() ??
            match?['teamA']?.toString() ??
            'Team A';
        final matchTeamB =
            match?['teamBName']?.toString() ??
            match?['teamB']?.toString() ??
            'Team B';
        return 'Stat Keeper $senderName has submitted stats for approval for the match $matchTeamA vs $matchTeamB.';
      case 'STATS_PUBLISHED':
        final matchTeamA =
            match?['teamAName']?.toString() ??
            match?['teamA']?.toString() ??
            'Team A';
        final matchTeamB =
            match?['teamBName']?.toString() ??
            match?['teamB']?.toString() ??
            'Team B';
        return 'Admin has approved and published your stats for the match $matchTeamA vs $matchTeamB.';
      default:
        return 'You have a new notification';
    }
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
}

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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current user role to decide whether to fetch payments
      final prefs = await SharedPreferences.getInstance();
      final userRole = prefs.getString('userRole')?.toLowerCase() ?? '';
      final isAdmin = userRole == 'admin';

      // Parallel fetch
      final results = await Future.wait([
        NotificationService.getAllNotifications(),
        if (isAdmin) _fetchPaymentNotifications() else Future.value([]),
      ]);

      final List<Map<String, dynamic>> regularData =
          results[0] as List<Map<String, dynamic>>;
      final List<Map<String, dynamic>> paymentData =
          results[1] as List<Map<String, dynamic>>;

      _notifications = [
        ...regularData.map((json) => NotificationModel.fromJson(json)),
        ...paymentData.map((json) => NotificationModel.fromJson(json)),
      ];

      // Sort by date descending
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _updateUnreadCount();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load notifications: ${e.toString()}';
      print('❌ Error loading notifications: $e');
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
      final senderId =
          notification.sender?['_id']?.toString() ??
          notification.sender?['id']?.toString();

      if (matchId == null || senderId == null) {
        _errorMessage = 'Match ID or Stat Keeper ID not found in notification';
        notifyListeners();
        return false;
      }

      await StatKeeperRepository.approveStats(matchId, senderId);

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

import 'package:flutter/material.dart';
import 'package:pffl_managment/core/services/notification_service.dart';

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
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'pending',
      format: json['format']?.toString(),
      sender: json['sender'] is Map ? Map<String, dynamic>.from(json['sender']) : null,
      receiver: json['receiver'] is Map ? Map<String, dynamic>.from(json['receiver']) : null,
      team: json['team'] is Map ? Map<String, dynamic>.from(json['team']) : null,
      league: json['league'] is Map ? Map<String, dynamic>.from(json['league']) : null,
      match: json['match'] is Map ? Map<String, dynamic>.from(json['match']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
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
  String get matchTeamA => match?['teamAName']?.toString() ?? match?['teamA']?.toString() ?? 'Team A';
  String get matchTeamB => match?['teamBName']?.toString() ?? match?['teamB']?.toString() ?? 'Team B';
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
    switch (type) {
      case 'TEAM_INVITE':
        // Format: "You've been invited by [Sender Name] to join the team [Team Name] for the upcoming league."
        if (league != null && leagueName != 'Unknown League') {
          return 'You\'ve been invited by $senderName to join the team $teamName for the upcoming league.';
        } else {
          return 'You\'ve been invited by $senderName to join the team $teamName.';
        }
      case 'LEAGUE_REFEREE_INVITE':
        return '$senderName invited you to be a referee for $leagueName';
      case 'LEAGUE_STATKEEPER_INVITE':
        return '$senderName invited you to be a stat keeper for $leagueName';
      case 'LEAGUE_TEAM_INVITE':
        return 'A new league "$leagueName" has been created and your team has been invited. Would you like to accept the invitation?';
      case 'GAME_ASSIGNED':
        final matchTeamA = match?['teamAName']?.toString() ?? match?['teamA']?.toString() ?? 'Team A';
        final matchTeamB = match?['teamBName']?.toString() ?? match?['teamB']?.toString() ?? 'Team B';
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
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  bool get hasNotifications => _unreadCount > 0;

  NotificationProvider() {
    loadNotifications();
  }

  /// Load all notifications for the current user
  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final notificationsData = await NotificationService.getAllNotifications();
      
      _notifications = notificationsData
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      // Count pending notifications
      _unreadCount = _notifications.where((n) => n.isPending).length;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load notifications: ${e.toString()}';
      print('❌ Error loading notifications: $e');
      notifyListeners();
    }
  }

  /// Accept a notification
  Future<bool> acceptNotification(String notificationId) async {
    _errorMessage = null;
    notifyListeners();
    
    try {
      final success = await NotificationService.acceptNotification(notificationId);
      if (success) {
        // Reload notifications to get updated status
        await loadNotifications();
        return true;
      }
      _errorMessage = 'Failed to accept notification';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print('❌ Error accepting notification: $e');
      notifyListeners();
      return false;
    }
  }

  /// Reject a notification
  Future<bool> rejectNotification(String notificationId) async {
    _errorMessage = null;
    notifyListeners();
    
    try {
      final success = await NotificationService.rejectNotification(notificationId);
      if (success) {
        // Reload notifications to get updated status
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

  /// Refresh notifications
  Future<void> refresh() async {
    await loadNotifications();
  }
}


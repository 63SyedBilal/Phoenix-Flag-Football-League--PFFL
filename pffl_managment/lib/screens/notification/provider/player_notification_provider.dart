import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class PlayerNotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Set<String> _expandedIds = {};

  final String? userId; // Added for targeted filtering

  PlayerNotificationProvider({this.userId}); // Constructor with userId

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isExpanded(String id) => _expandedIds.contains(id);

  void toggleExpansion(String id) {
    if (_expandedIds.contains(id)) {
      _expandedIds.remove(id);
    } else {
      _expandedIds.add(id);
    }
    notifyListeners();
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await NotificationService.getUserNotifications(
        role: 'player',
        userId: userId, // Pass userId for filtering
      );
    } catch (e) {
      _errorMessage = 'Failed to load notifications';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    final success = await NotificationService.markAsRead(id);
    if (success) {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          body: _notifications[index].body,
          type: _notifications[index].type,
          createdAt: _notifications[index].createdAt,
          isRead: true,
        );
        notifyListeners();
      }
    }
  }

  Future<void> deleteNotification(String id) async {
    final success = await NotificationService.deleteNotification(id);
    if (success) {
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> acceptNotification(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await NotificationService.respondToInvitation(id, true);

      if (result['success'] == true) {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          final old = _notifications[index];
          _notifications[index] = NotificationModel(
            id: old.id,
            title: old.title,
            body: old.body,
            type: old.type,
            createdAt: old.createdAt,
            isRead: old.isRead,
            status: 'accepted',
            teamImage: old.teamImage,
            leagueLogo: old.leagueLogo,
            league: old.league,
            team: old.team,
            format: old.format,
            senderId: old.senderId,
            teamId: old.teamId,
            leagueId: old.leagueId,
            senderName: old.senderName,
          );
          notifyListeners();
        }
      } else {
        _errorMessage = result['error'];
      }
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      return {'success': false, 'error': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectNotification(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await NotificationService.respondToInvitation(id, false);

      if (result['success'] == true) {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          final old = _notifications[index];
          _notifications[index] = NotificationModel(
            id: old.id,
            title: old.title,
            body: old.body,
            type: old.type,
            createdAt: old.createdAt,
            isRead: old.isRead,
            status: 'rejected',
            teamImage: old.teamImage,
            leagueLogo: old.leagueLogo,
            league: old.league,
            team: old.team,
            format: old.format,
            senderId: old.senderId,
            teamId: old.teamId,
            leagueId: old.leagueId,
            senderName: old.senderName,
          );
          notifyListeners();
        }
        return true;
      } else {
        _errorMessage = result['error'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to refresh manually
  Future<void> refresh() async {
    await fetchNotifications();
  }
}

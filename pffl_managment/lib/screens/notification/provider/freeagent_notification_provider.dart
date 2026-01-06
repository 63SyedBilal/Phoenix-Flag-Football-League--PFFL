import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class FreeAgentNotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  final String? userId; // Added for targeted filtering

  FreeAgentNotificationProvider({this.userId}); // Constructor with userId

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await NotificationService.getUserNotifications(
        role: 'freeagent',
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
        await fetchNotifications();
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
        await fetchNotifications();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchNotifications();
  }
}

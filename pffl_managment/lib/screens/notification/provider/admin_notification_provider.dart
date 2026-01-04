import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class AdminNotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch notifications for admin
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await NotificationService.getUserNotifications(
        role: 'admin',
      );
    } catch (e) {
      _errorMessage = 'Failed to load notifications';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    try {
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
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String id) async {
    try {
      final success = await NotificationService.deleteNotification(id);
      if (success) {
        _notifications.removeWhere((n) => n.id == id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  Future<bool> approveStats(String notificationId) async {
    // TODO: Implement approve stats logic in service
    await Future.delayed(const Duration(seconds: 1)); // Mock
    return true;
  }
}

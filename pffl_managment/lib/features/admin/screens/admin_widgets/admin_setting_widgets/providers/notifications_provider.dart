import 'package:flutter/foundation.dart';
import 'package:pffl_managment/core/services/notification_service.dart';
import 'package:pffl_managment/core/services/payment_service.dart';

/// Model for notification display
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String date;
  final String type; // 'payment_received', 'payment_refunded', 'payment_processed', 'payment_pending', 'league_created', 'team_invite', 'league_invite'

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
  });
}

/// Provider for Notifications Screen
class NotificationsProvider extends ChangeNotifier {
  // State variables
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize and fetch notifications
  Future<void> initialize() async {
    if (_isLoading) return;
    await fetchNotifications();
  }

  /// Fetch notifications from backend
  Future<void> fetchNotifications() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('🔄 Fetching notifications...');

      // Fetch both regular notifications and payment data
      final results = await Future.wait([
        NotificationService.getAllNotifications(),
        _fetchPaymentNotifications(),
      ]);

      final regularNotifications = results[0] as List<Map<String, dynamic>>;
      final paymentNotifications = results[1] as List<NotificationModel>;

      debugPrint('✅ Fetched ${regularNotifications.length} regular notifications');
      debugPrint('✅ Fetched ${paymentNotifications.length} payment notifications');

      // Convert regular notifications to NotificationModel
      final convertedNotifications = regularNotifications.map((n) {
        return _convertNotificationToModel(n);
      }).toList();

      // Combine and sort by date (most recent first)
      _notifications = [...convertedNotifications, ...paymentNotifications];
      _notifications.sort((a, b) => b.date.compareTo(a.date));

      debugPrint('✅ Total notifications: ${_notifications.length}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error fetching notifications: $e');
      _errorMessage = 'Failed to load notifications';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch payment notifications from payment data
  Future<List<NotificationModel>> _fetchPaymentNotifications() async {
    try {
      // Fetch all payments to generate payment notifications
      final payments = await PaymentService.getAllPayments('all');
      
      final paymentNotifications = <NotificationModel>[];

      for (var payment in payments) {
        final status = payment['status'] as String? ?? 'pending';
        final createdAt = payment['createdAt'] as String? ?? payment['updatedAt'] as String? ?? DateTime.now().toIso8601String();
        final amount = payment['amount'] as num? ?? 0;
        final userId = payment['userId'];
        final leagueId = payment['leagueId'];
        
        String playerName = 'A player';
        if (userId != null && userId is Map) {
          final firstName = userId['firstName'] as String? ?? '';
          final lastName = userId['lastName'] as String? ?? '';
          playerName = '${firstName} ${lastName}'.trim();
          if (playerName.isEmpty) {
            playerName = userId['email'] as String? ?? 'A player';
          }
        }

        String leagueName = 'the league';
        if (leagueId != null && leagueId is Map) {
          leagueName = leagueId['leagueName'] as String? ?? 'the league';
        }

        String title;
        String message;
        String type;

        switch (status.toLowerCase()) {
          case 'paid':
            title = 'Payment Received';
            message = '$playerName has successfully paid \$${amount.toStringAsFixed(2)} for $leagueName. Please review the payment details.';
            type = 'payment_received';
            break;
          case 'refunded':
            title = 'Payment Refunded';
            message = '$playerName\'s payment of \$${amount.toStringAsFixed(2)} for $leagueName has been successfully refunded. Please review the refund details if needed.';
            type = 'payment_refunded';
            break;
          case 'pending':
          case 'unpaid':
            title = 'Payment Pending';
            message = '$playerName\'s payment of \$${amount.toStringAsFixed(2)} for $leagueName is currently pending. We are awaiting confirmation from the payment provider.';
            type = 'payment_pending';
            break;
          default:
            title = 'Payment Processed';
            message = '$playerName\'s payment of \$${amount.toStringAsFixed(2)} for $leagueName has been successfully processed. Please check your account for the updated balance.';
            type = 'payment_processed';
        }

        // Only add paid and pending payments as notifications (to avoid duplicates)
        // Refunded payments can be added if status field supports it
        if (status.toLowerCase() == 'paid' || status.toLowerCase() == 'unpaid' || status.toLowerCase() == 'pending') {

          paymentNotifications.add(NotificationModel(
            id: payment['_id']?.toString() ?? payment['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            message: message,
            date: _formatDate(createdAt),
            type: type,
          ));
        }
      }

      return paymentNotifications;
    } catch (e) {
      debugPrint('❌ Error fetching payment notifications: $e');
      return [];
    }
  }

  /// Convert backend notification to NotificationModel
  NotificationModel _convertNotificationToModel(Map<String, dynamic> notification) {
    final type = notification['type'] as String? ?? '';
    final createdAt = notification['createdAt'] as String? ?? DateTime.now().toIso8601String();
    
    String title;
    String message;
    String notificationType;

    switch (type) {
      case 'LEAGUE_TEAM_INVITE':
      case 'LEAGUE_REFEREE_INVITE':
      case 'LEAGUE_STATKEEPER_INVITE':
        final league = notification['league'];
        final leagueName = league != null && league is Map ? league['leagueName'] as String? : 'a league';
        title = 'League Created Successfully';
        message = 'Your new league "$leagueName" has been created successfully.\nYou can now manage teams, and schedules from your league dashboard.';
        notificationType = 'league_created';
        break;
      case 'TEAM_INVITE':
        title = 'Team Invitation';
        message = 'You have been invited to join a team.';
        notificationType = 'team_invite';
        break;
      case 'ROLE_INVITE':
        title = 'Role Invitation';
        message = 'You have been invited to take on a new role.';
        notificationType = 'role_invite';
        break;
      default:
        title = 'Notification';
        message = 'You have a new notification.';
        notificationType = 'other';
    }

    return NotificationModel(
      id: notification['_id']?.toString() ?? notification['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      date: _formatDate(createdAt),
      type: notificationType,
    );
  }

  /// Format date string to display format
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return DateTime.now().toString().substring(0, 10);
    }
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await fetchNotifications();
  }
}

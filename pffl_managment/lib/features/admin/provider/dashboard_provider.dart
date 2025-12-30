import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pffl_managment/core/models/stat_card_model.dart';
import 'package:pffl_managment/core/models/quick_action_model.dart';
import 'package:pffl_managment/core/models/dashboard_stats_model.dart';
import 'package:pffl_managment/core/services/dashboard_stats_service.dart';

/// ViewModel for Admin Dashboard
/// Manages real-time statistics fetched from the backend API
class DashboardViewModel extends ChangeNotifier {
  final String _userName = "Tyler";
  final String _leagueName = "Phoenix Flag Football League";

  // Dashboard stats state
  DashboardStatsModel? _stats;
  bool _isLoading = false;
  String? _error;
  bool _hasFetched = false;

  // Getters for basic info
  String get userName => _userName;
  String get leagueName => _leagueName;

  // Getters for stats state
  DashboardStatsModel? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasFetched => _hasFetched;

  /// Format number with commas (e.g., 2847 -> "2,847")
  String _formatNumber(int number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  /// Format currency (e.g., 12540 -> "$12,540")
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return formatter.format(amount);
  }

  /// Fetch dashboard statistics from API
  /// Called when Admin Overview screen is loaded
  Future<void> fetchDashboardStats() async {
    // Prevent multiple simultaneous fetches
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await DashboardStatsService.getDashboardStats();

      if (result != null) {
        _stats = result;
        _hasFetched = true;
      } else {
        _error = 'Failed to load dashboard statistics';
      }
    } catch (e) {
      _error = 'Error loading statistics: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh dashboard statistics
  Future<void> refreshStats() async {
    _hasFetched = false;
    await fetchDashboardStats();
  }

  /// Overview Stats - Returns real data from API
  /// Falls back to loading/error state if data not available
  List<StatCardModel> get statCards {
    // If still loading, return loading state cards
    if (_isLoading && !_hasFetched) {
      return _getLoadingStatCards();
    }

    // If we have stats, return real data
    if (_stats != null) {
      return [
        StatCardModel(
          title: 'Total Leagues',
          value: _formatNumber(_stats!.leagues.total),
          subtitle: '+${_stats!.leagues.thisMonth} this month',
          icon: Icons.emoji_events_outlined,
          iconColor: const Color(0xFFDF7016),
          backgroundColor: const Color(0xFFFBFBFB),
        ),
        StatCardModel(
          title: 'Total Games',
          value: _formatNumber(_stats!.games.total),
          subtitle: '${_stats!.games.today} today',
          icon: Icons.calendar_today_outlined,
          iconColor: const Color(0xFF0043AF),
          backgroundColor: const Color(0xFFFBFBFB),
        ),
        StatCardModel(
          title: 'Registered\nUsers',
          value: _formatNumber(_stats!.users.total),
          subtitle: '+${_stats!.users.thisWeek} this week',
          icon: Icons.people_outline,
          iconColor: const Color(0xFFB3000A),
          backgroundColor: const Color(0xFFFBFBFB),
        ),
        StatCardModel(
          title: 'Pending\nPayments',
          value: _formatCurrency(_stats!.payments.totalAmount),
          subtitle: '${_stats!.payments.count} pending',
          icon: Icons.attach_money,
          iconColor: const Color(0xFF00985E),
          backgroundColor: const Color(0xFFFBFBFB),
        ),
      ];
    }

    // If error or no data, return placeholder cards
    return _getPlaceholderStatCards();
  }

  /// Loading state stat cards
  List<StatCardModel> _getLoadingStatCards() {
    return [
      StatCardModel(
        title: 'Total Leagues',
        value: '...',
        subtitle: 'Loading...',
        icon: Icons.emoji_events_outlined,
        iconColor: const Color(0xFFDF7016),
        backgroundColor: const Color(0xFFFBFBFB),
      ),
      StatCardModel(
        title: 'Total Games',
        value: '...',
        subtitle: 'Loading...',
        icon: Icons.calendar_today_outlined,
        iconColor: const Color(0xFF0043AF),
        backgroundColor: const Color(0xFFFBFBFB),
      ),
      StatCardModel(
        title: 'Registered\nUsers',
        value: '...',
        subtitle: 'Loading...',
        icon: Icons.people_outline,
        iconColor: const Color(0xFFB3000A),
        backgroundColor: const Color(0xFFFBFBFB),
      ),
      StatCardModel(
        title: 'Pending\nPayments',
        value: '...',
        subtitle: 'Loading...',
        icon: Icons.attach_money,
        iconColor: const Color(0xFF00985E),
        backgroundColor: const Color(0xFFFBFBFB),
      ),
    ];
  }

  /// Placeholder stat cards when no data available
  List<StatCardModel> _getPlaceholderStatCards() {
    return [
      StatCardModel(
        title: 'Total Leagues',
        value: '0',
        subtitle: 'No data',
        icon: Icons.emoji_events_outlined,
        iconColor: const Color(0xFFDF7016),
        backgroundColor: const Color(0xFFFBFBFB),
      ),
      StatCardModel(
        title: 'Total Games',
        value: '0',
        subtitle: 'No data',
        icon: Icons.calendar_today_outlined,
        iconColor: const Color(0xFF0043AF),
        backgroundColor: const Color(0xFFFBFBFB),
      ),
      StatCardModel(
        title: 'Registered\nUsers',
        value: '0',
        subtitle: 'No data',
        icon: Icons.people_outline,
        iconColor: const Color(0xFFB3000A),
        backgroundColor: const Color(0xFFFBFBFB),
      ),
      StatCardModel(
        title: 'Pending\nPayments',
        value: '\$0',
        subtitle: 'No data',
        icon: Icons.attach_money,
        iconColor: const Color(0xFF00985E),
        backgroundColor: const Color(0xFFFBFBFB),
      ),
    ];
  }

  // Quick Actions
  List<QuickActionModel> get quickActions => [
    QuickActionModel(
      title: 'Create League',
      icon: Icons.add,
      onTap: () {
      },
    ),
    QuickActionModel(
      title: 'Schedule Game',
      icon: Icons.calendar_today_outlined,
      onTap: () => _handleScheduleGame(),
    ),
    QuickActionModel(
      title: 'Manage Stats',
      icon: Icons.content_paste,
      onTap: () => _handleManageStats(),
    ),
    QuickActionModel(
      title: 'View Reports',
      icon: Icons.bar_chart,
      onTap: () => _handleViewReports(),
    ),
  ];

  void _handleScheduleGame() {
  }

  void _handleManageStats() {
  }

  void _handleViewReports() {
  }
}


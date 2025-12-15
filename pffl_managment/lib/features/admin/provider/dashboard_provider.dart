import 'package:flutter/material.dart';
import 'package:pffl_managment/core/models/stat_card_model.dart';
import 'package:pffl_managment/core/models/quick_action_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final String _userName = "Tyler";
  final String _leagueName = "Phoenix Flag Football League";
  bool _hasNotifications = true;

  String get userName => _userName;
  String get leagueName => _leagueName;
  bool get hasNotifications => _hasNotifications;

  // Overview Stats
  List<StatCardModel> get statCards => [
    StatCardModel(
      title: 'Total Leagues',
      value: '12',
      subtitle: '+2 this month',
      icon: Icons.emoji_events_outlined,
      iconColor: const Color(0xFFDF7016),
      backgroundColor: const Color(0xFFFBFBFB),
    ),
    StatCardModel(
      title: 'Active Games',
      value: '48',
      subtitle: '8 today',
      icon: Icons.calendar_today_outlined,
      iconColor: const Color(0xFF0043AF),
      backgroundColor: const Color(0xFFFBFBFB),
    ),
    StatCardModel(
      title: 'Registered\nUsers',
      value: '2,847',
      subtitle: '+156 this week',
      icon: Icons.people_outline,
      iconColor: const Color(0xFFB3000A),
      backgroundColor: const Color(0xFFFBFBFB),
    ),
    StatCardModel(
      title: 'Pending\npayments',
      value: '\$12,540',
      subtitle: '23 pending',
      icon: Icons.attach_money,
      iconColor: const Color(0xFF00985E),
      backgroundColor: const Color(0xFFFBFBFB),
    ),
  ];

  // Quick Actions
  List<QuickActionModel> get quickActions => [
    QuickActionModel(
      title: 'Create League',
      icon: Icons.add,
      onTap: () {
        debugPrint('Create League tapped');
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
    debugPrint('Schedule Game tapped');
  }

  void _handleManageStats() {
    debugPrint('Manage Stats tapped');
  }

  void _handleViewReports() {
    debugPrint('View Reports tapped');
  }

  void toggleNotifications() {
    _hasNotifications = !_hasNotifications;
    notifyListeners();
  }
}

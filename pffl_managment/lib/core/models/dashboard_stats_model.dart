/// Model class for deserializing dashboard statistics from the API
/// Used by DashboardViewModel to display real-time stats in Admin Overview
class DashboardStatsModel {
  final LeagueStats leagues;
  final GameStats games;
  final UserStats users;
  final PaymentStats payments;

  DashboardStatsModel({
    required this.leagues,
    required this.games,
    required this.users,
    required this.payments,
  });

  /// Factory constructor to create model from JSON response
  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      leagues: LeagueStats.fromJson(json['leagues'] ?? {}),
      games: GameStats.fromJson(json['games'] ?? {}),
      users: UserStats.fromJson(json['users'] ?? {}),
      payments: PaymentStats.fromJson(json['payments'] ?? {}),
    );
  }

  /// Convert model to JSON map
  Map<String, dynamic> toJson() {
    return {
      'leagues': leagues.toJson(),
      'games': games.toJson(),
      'users': users.toJson(),
      'payments': payments.toJson(),
    };
  }
}

/// League statistics
class LeagueStats {
  final int total;
  final int active;
  final int thisMonth;

  LeagueStats({
    required this.total,
    required this.active,
    required this.thisMonth,
  });

  factory LeagueStats.fromJson(Map<String, dynamic> json) {
    return LeagueStats(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      thisMonth: json['thisMonth'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'active': active,
      'thisMonth': thisMonth,
    };
  }
}

/// Game/Match statistics
class GameStats {
  final int total;
  final int active;
  final int today;

  GameStats({
    required this.total,
    required this.active,
    required this.today,
  });

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      today: json['today'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'active': active,
      'today': today,
    };
  }
}

/// User statistics
class UserStats {
  final int total;
  final int thisWeek;
  final Map<String, int> byRole;

  UserStats({
    required this.total,
    required this.thisWeek,
    required this.byRole,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    final byRoleJson = json['byRole'] as Map<String, dynamic>? ?? {};
    final byRole = byRoleJson.map((key, value) => MapEntry(key, value as int? ?? 0));
    
    return UserStats(
      total: json['total'] ?? 0,
      thisWeek: json['thisWeek'] ?? 0,
      byRole: byRole,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'thisWeek': thisWeek,
      'byRole': byRole,
    };
  }

  /// Get count for a specific role
  int getRoleCount(String role) => byRole[role] ?? 0;
}

/// Payment statistics
class PaymentStats {
  final double totalAmount;
  final int count;

  PaymentStats({
    required this.totalAmount,
    required this.count,
  });

  factory PaymentStats.fromJson(Map<String, dynamic> json) {
    return PaymentStats(
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAmount': totalAmount,
      'count': count,
    };
  }
}


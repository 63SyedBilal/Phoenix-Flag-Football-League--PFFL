import 'package:flutter/material.dart';

class LeagueCreationModel {
  final String id;
  final String leagueName;
  final String teamLogo;
  final List<String> selectedPlayerIds;
  final String captainId;
  final double registrationFee;
  final DateTime createdAt;
  final String status;
  final String format;
  final DateTime startDate;
  final DateTime endDate; // Added end date field

  LeagueCreationModel({
    required this.id,
    required this.leagueName,
    required this.teamLogo,
    required this.selectedPlayerIds,
    required this.captainId,
    required this.registrationFee,
    required this.createdAt,
    this.status = 'Active',
    this.format = '5v5',
    required this.startDate,
    required this.endDate,
  });
}

class PlayerModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final bool isAvailable;

  PlayerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.isAvailable = true,
  });
}

class PaymentStatusModel {
  final String playerId;
  final String playerName;
  final double amount;
  final PaymentStatus status;
  final DateTime? paidAt;

  PaymentStatusModel({
    required this.playerId,
    required this.playerName,
    required this.amount,
    required this.status,
    this.paidAt,
  });
}

enum PaymentStatus { pending, paid, overdue }

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.overdue:
        return 'Overdue';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return const Color(0xFFF59E0B);
      case PaymentStatus.paid:
        return const Color(0xFF10B981);
      case PaymentStatus.overdue:
        return const Color(0xFFEF4444);
    }
  }
}

class TeamLogoModel {
  final String id;
  final String url;
  final String name;

  TeamLogoModel({required this.id, required this.url, required this.name});
}

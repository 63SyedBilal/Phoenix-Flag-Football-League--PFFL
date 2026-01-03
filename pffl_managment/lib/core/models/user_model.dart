import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String team;
  final UserStatus status;
  final String? imageUrl;
  final String? jerseyNumber;
  final String? position;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.team,
    required this.status,
    this.imageUrl,
    this.jerseyNumber,
    this.position,
  });

  /// Check if user has a valid profile image URL
  bool get hasProfileImage =>
      imageUrl != null && imageUrl!.isNotEmpty && imageUrl!.startsWith('http');

  /// Get list of positions (split by comma if multiple)
  List<String> get positions {
    if (position == null || position!.isEmpty) return [];
    return position!
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }
}

enum UserRole {
  superadmin,
  admin,
  player,
  captain,
  referee,
  statKeeper,
  freeAgent,
}

enum UserStatus { active, invited, pending }

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.superadmin:
        return 'Super Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.player:
        return 'Player';
      case UserRole.captain:
        return 'Captain';
      case UserRole.referee:
        return 'Referee';
      case UserRole.statKeeper:
        return 'Stat Keeper';
      case UserRole.freeAgent:
        return 'Free Agent';
    }
  }

  UserRoleColors get colors {
    switch (this) {
      case UserRole.superadmin:
      case UserRole.admin:
        return UserRoleColors(
          background: const Color(0xFFFEE2E2), // red-100
          border: const Color(0xFFFECACA), // red-200
          text: const Color(0xFF991B1B), // red-800
        );
      case UserRole.player:
        return UserRoleColors(
          background: const Color(0xFFDBEAFE), // blue-100
          border: const Color(0xFFBFDBFE), // blue-200
          text: const Color(0xFF1E3A8A), // blue-900
        );
      case UserRole.captain:
        return UserRoleColors(
          background: const Color(0xFFFEF3C7), // amber-100
          border: const Color(0xFFFDE68A), // amber-200
          text: const Color(0xFF78350F), // amber-900
        );
      case UserRole.referee:
        return UserRoleColors(
          background: const Color(0xFFEDE9FE), // violet-100
          border: const Color(0xFFDDD6FE), // violet-200
          text: const Color(0xFF4C1D95), // violet-900
        );
      case UserRole.statKeeper:
        return UserRoleColors(
          background: const Color(0xFFD1FAE5), // emerald-100
          border: const Color(0xFFA7F3D0), // emerald-200
          text: const Color(0xFF064E3B), // emerald-900
        );
      case UserRole.freeAgent:
        return UserRoleColors(
          background: const Color(0xFFF3F4F6), // gray-100
          border: const Color(0xFFE5E7EB), // gray-200
          text: const Color(0xFF374151), // gray-700
        );
    }
  }
}

class UserRoleColors {
  final Color background;
  final Color border;
  final Color text;

  UserRoleColors({
    required this.background,
    required this.border,
    required this.text,
  });
}

extension UserStatusExtension on UserStatus {
  String get displayName {
    switch (this) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.invited:
        return 'Invited';
      case UserStatus.pending:
        return 'Pending';
    }
  }

  Color get color {
    switch (this) {
      case UserStatus.active:
        return const Color(0xFF10B981); // emerald-500
      case UserStatus.invited:
        return const Color(0xFF3B82F6); // blue-500
      case UserStatus.pending:
        return const Color(0xFFF59E0B); // amber-500
    }
  }
}

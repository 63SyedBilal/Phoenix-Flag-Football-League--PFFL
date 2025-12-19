import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String team;
  final UserStatus status;
  final String? imageUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.team,
    required this.status,
    this.imageUrl,
  });

  /// Check if user has a valid profile image URL
  bool get hasProfileImage =>
      imageUrl != null && imageUrl!.isNotEmpty && imageUrl!.startsWith('http');
}

enum UserRole { player, captain, referee, statKeeper }

enum UserStatus { active, invited, pending }

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.player:
        return 'Player';
      case UserRole.captain:
        return 'Captain';
      case UserRole.referee:
        return 'Referee';
      case UserRole.statKeeper:
        return 'Stat Keeper';
    }
  }

  UserRoleColors get colors {
    switch (this) {
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

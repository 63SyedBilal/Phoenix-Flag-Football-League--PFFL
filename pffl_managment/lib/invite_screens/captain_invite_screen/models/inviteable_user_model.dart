import 'package:pffl_managment/core/services/user_service.dart';

/// Model representing a user that can be invited to a team
/// Combines UserModel data with profile data (jersey number, position)
class InviteableUserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? jerseyNumber;
  final String? position; // Comma-separated positions
  final String? imageUrl;
  bool isInvited; // Whether user is already in team squad
  bool isInviting; // Whether invite action is in progress

  InviteableUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.jerseyNumber,
    this.position,
    this.imageUrl,
    this.isInvited = false,
    this.isInviting = false,
  });

  /// Create from UserModel
  factory InviteableUserModel.fromUserModel(UserModel user) {
    return InviteableUserModel(
      id: user.id,
      firstName: user.firstName ?? '',
      lastName: user.lastName ?? '',
      email: user.email,
      role: user.role,
    );
  }

  /// Get full name
  String get fullName {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    return email;
  }

  /// Get display name with jersey number
  String get displayName {
    if (jerseyNumber != null && jerseyNumber!.isNotEmpty) {
      return '#$jerseyNumber $fullName';
    }
    return fullName;
  }

  /// Get primary position (first position from comma-separated list)
  String get primaryPosition {
    if (position == null || position!.isEmpty) {
      return '';
    }
    final positions = position!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return positions.isNotEmpty ? positions[0] : '';
  }

  /// Get count of additional positions
  int get additionalPositionsCount {
    if (position == null || position!.isEmpty) {
      return 0;
    }
    final positions = position!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return positions.length > 1 ? positions.length - 1 : 0;
  }

  /// Get position display text
  String get positionDisplayText {
    if (primaryPosition.isEmpty) {
      return '';
    }
    if (additionalPositionsCount > 0) {
      return '$primaryPosition +$additionalPositionsCount more';
    }
    return primaryPosition;
  }

  /// Update with profile data
  InviteableUserModel copyWith({
    String? jerseyNumber,
    String? position,
    String? imageUrl,
    bool? isInvited,
    bool? isInviting,
  }) {
    return InviteableUserModel(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: role,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      position: position ?? this.position,
      imageUrl: imageUrl ?? this.imageUrl,
      isInvited: isInvited ?? this.isInvited,
      isInviting: isInviting ?? this.isInviting,
    );
  }
}


/// Utility class for role normalization and validation
class UserRoleUtils {
  /// Normalizes a role string to a standard format:
  /// - lowercase
  /// - no spaces
  /// - no underscores
  /// - trimmed
  static String normalizeRole(String role) {
    return role.toLowerCase().replaceAll(' ', '').replaceAll('_', '').trim();
  }

  /// Validates if a normalized role is an admin-level role
  static bool isAdmin(String normalizedRole) {
    return normalizedRole == 'admin' || normalizedRole == 'superadmin';
  }

  /// List of all valid role keys after normalization
  static const List<String> validRoles = [
    'superadmin',
    'admin',
    'captain',
    'player',
    'referee',
    'statkeeper',
    'freeagent',
  ];
}

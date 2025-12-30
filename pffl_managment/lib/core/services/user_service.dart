import 'package:dio/dio.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

/// Service for user-related API calls
class UserService {
  /// Get Dio instance with authentication token and working URL
  static Future<Dio> _getAuthenticatedDio() async {
    // Use AuthService's working Dio instance which has the correct URL
    return await AuthService.getWorkingDio();
  }

  /// Fetch users by role
  /// GET /api/user?role=free-agent
  static Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final dio = await _getAuthenticatedDio();

      final response = await dio.get('/user', queryParameters: {'role': role});

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          final users = (data['data'] as List)
              .map((json) => UserModel.fromJson(json))
              .toList();
          return users;
        }
        return [];
      } else {
        return [];
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      rethrow;
    } catch (e) {
      return [];
    }
  }

  /// Fetch all free agents
  static Future<List<UserModel>> getFreeAgents() async {
    return getUsersByRole('free-agent');
  }

  /// Fetch all stat keepers
  static Future<List<UserModel>> getStatKeepers() async {
    return getUsersByRole('stat-keeper');
  }

  /// Fetch all referees
  static Future<List<UserModel>> getReferees() async {
    return getUsersByRole('referee');
  }

  /// Fetch all captains
  static Future<List<UserModel>> getCaptains() async {
    return getUsersByRole('captain');
  }

  /// Fetch all users
  /// GET /api/user
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/user');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          final users = (data['data'] as List)
              .map((json) => UserModel.fromJson(json))
              .toList();

          return users;
        }
        return [];
      } else {
        return [];
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get all profiles
  /// GET /api/profile
  static Future<List<Map<String, dynamic>>> getAllProfiles() async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/profile');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        return [];
      }
    } on DioException catch (e) {
      if (e.response != null) {
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Update user role
  /// PUT /api/user/:id
  static Future<bool> updateUserRole(String userId, String newRole) async {
    final trimmedId = userId.trim();
    try {
      print(
        '🔄 ID Length: ${trimmedId.length}, CodeUnits: ${trimmedId.codeUnits}',
      );

      final dio = await _getAuthenticatedDio();

      final path = '/user/$trimmedId';

      final response = await dio.put(path, data: {'role': newRole});

      if (response.statusCode == 200) {
        return true;
      }

      throw Exception(
        'Failed to update user role: Status ${response.statusCode}',
      );
    } on DioException catch (e) {

      if (e.response != null) {

        if (e.response?.statusCode == 404) {
          throw Exception(
            'User ID not found on server. ID: $trimmedId (Len: ${trimmedId.length})',
          );
        }

        // Extract helpful error message if available
        if (e.response?.data is Map && e.response?.data['error'] != null) {
          throw Exception(e.response?.data['error']);
        }
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  /// PUT /api/user/:id
  static Future<Map<String, dynamic>?> updateProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    try {

      final dio = await _getAuthenticatedDio();
      final url = '/user/${userId.trim()}';

      final response = await dio.put(url, data: profileData);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        return data as Map<String, dynamic>;
      } else {
        print(
          '❌ UserService: Failed to update profile: ${response.statusCode} - ${response.statusMessage}',
        );
        return null;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response?.data['error'] ?? 'Failed to update profile';
        throw Exception(error);
      }
      throw Exception('Failed to update profile');
    } catch (e) {
      rethrow;
    }
  }

  /// Check if jersey number is available
  /// GET /api/user/check-jersey?number=10&excludeUserId=123
  static Future<Map<String, dynamic>> checkJerseyNumber(
    int jerseyNumber, {
    String? excludeUserId,
  }) async {
    try {
      final dio = await _getAuthenticatedDio();
      final queryParams = <String, dynamic>{'number': jerseyNumber.toString()};

      if (excludeUserId != null && excludeUserId.isNotEmpty) {
        queryParams['excludeUserId'] = excludeUserId;
      }

      final response = await dio.get(
        '/user/check-jersey',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        return {
          'available': false,
          'message': 'Failed to check jersey number availability',
        };
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['message'] != null) {
          return {'available': false, 'message': errorData['message']};
        }
      }
      return {
        'available': false,
        'message': 'Failed to check jersey number availability',
      };
    } catch (e) {
      return {
        'available': false,
        'message': 'Failed to check jersey number availability',
      };
    }
  }
}

/// User model for API responses
class UserModel {
  final String id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phone;
  final String role;
  final String? profileImage; // Add profile image field
  final int? jerseyNumber; // Add jersey number field
  final String? position; // Add position field

  UserModel({
    required this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.phone,
    required this.role,
    this.profileImage, // Add profile image parameter
    this.jerseyNumber, // Add jersey number parameter
    this.position, // Add position parameter
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle both _id and id fields
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';

    return UserModel(
      id: id,
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? '',
      profileImage: json['profileImage'], // Parse profile image from JSON
      jerseyNumber: json['jerseyNumber'], // Parse jersey number from JSON
      position: json['position'], // Parse position from JSON
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '${firstName!} ${lastName!}'.trim();
    }
    return email;
  }

  String get displayName {
    final name = fullName;
    return name.isNotEmpty ? name : email;
  }
}

/// Service for invite-related API calls
class InviteService {
  /// Get Dio instance with authentication token and working URL
  static Future<Dio> _getAuthenticatedDio() async {
    // Use AuthService's working Dio instance which has the correct URL
    return await AuthService.getWorkingDio();
  }

  /// Send invitation to user by email
  /// POST /api/invite
  /// Body: { email: string, role: string }
  /// Returns true for both new user creation (201) and existing user role invitation (200)
  static Future<bool> sendInvite(String email, String role) async {
    try {
      final dio = await _getAuthenticatedDio();

      final response = await dio.post(
        '/invite',
        data: {'email': email.trim(), 'role': role},
      );

      // Both 200 (existing user - role invitation sent) and 201 (new user created) are success
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final emailSent = responseData['emailSent'] ?? true;

        if (emailSent) {
        } else {
          print(
            '⚠️ Invite processed successfully, but email was not sent (SMTP not configured)',
          );
        }
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      if (e.response != null) {

        // Handle 409 Conflict - user already exists, but we can still send role invitation
        if (e.response?.statusCode == 409) {
          print(
            '⚠️ User already exists. This might be expected for role invitations.',
          );
          // For existing users, we might need a different endpoint or handle differently
          // For now, return false but log the issue
          return false;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}


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
      print('📡 Fetching users with role: $role');
      final dio = await _getAuthenticatedDio();
      print('📡 API URL: ${dio.options.baseUrl}/user?role=$role');

      final response = await dio.get('/user', queryParameters: {'role': role});

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          final users = (data['data'] as List)
              .map((json) => UserModel.fromJson(json))
              .toList();
          print('✅ Fetched ${users.length} users with role: $role');
          return users;
        }
        print('⚠️ No data field in response');
        return [];
      } else {
        print('❌ Failed to fetch users: ${response.statusMessage}');
        return [];
      }
    } on DioException catch (e) {
      print('❌ Error fetching users by role: ${e.message}');
      print('❌ Error type: ${e.type}');
      if (e.response != null) {
        print('❌ Error status: ${e.response?.statusCode}');
        print('❌ Error response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('❌ General error fetching users: $e');
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
        print('Failed to fetch all users: ${response.statusMessage}');
        return [];
      }
    } on DioException catch (e) {
      print('Error fetching all users: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      return [];
    } catch (e) {
      print('General error fetching all users: $e');
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
        print('Failed to fetch profiles: ${response.statusMessage}');
        return [];
      }
    } on DioException catch (e) {
      print('Error fetching profiles: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      return [];
    } catch (e) {
      print('General error fetching profiles: $e');
      return [];
    }
  }

  /// Update user role
  /// PUT /api/user/:id
  static Future<bool> updateUserRole(String userId, String newRole) async {
    final trimmedId = userId.trim();
    try {
      print('🔄 API Request: PUT role=$newRole for user=$trimmedId');
      print(
        '🔄 ID Length: ${trimmedId.length}, CodeUnits: ${trimmedId.codeUnits}',
      );

      final dio = await _getAuthenticatedDio();

      final path = '/user/$trimmedId';
      print('🔄 Request Path: ${dio.options.baseUrl}$path');

      final response = await dio.put(path, data: {'role': newRole});

      print('✅ Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      }

      throw Exception(
        'Failed to update user role: Status ${response.statusCode}',
      );
    } on DioException catch (e) {
      print('❌ Error updating user role: ${e.message}');
      print('❌ Request URI: ${e.requestOptions.uri}');

      if (e.response != null) {
        print('❌ Error response: ${e.response?.data}');

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
      print('General error updating user role: $e');
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
      final response = await dio.put('/user/$userId', data: profileData);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        return data as Map<String, dynamic>;
      } else {
        print('Failed to update user profile: ${response.statusMessage}');
        return null;
      }
    } on DioException catch (e) {
      print('Error updating user profile: ${e.message}');
      if (e.response != null) {
        final error = e.response?.data['error'] ?? 'Failed to update profile';
        throw Exception(error);
      }
      throw Exception('Failed to update profile');
    } catch (e) {
      rethrow;
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

  UserModel({
    required this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.phone,
    required this.role,
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
      print('📧 Sending invite to: $email with role: $role');
      final dio = await _getAuthenticatedDio();
      print('📧 API URL: ${dio.options.baseUrl}/invite');

      final response = await dio.post(
        '/invite',
        data: {'email': email.trim(), 'role': role},
      );

      print('📧 Response status: ${response.statusCode}');
      print('📧 Response data: ${response.data}');

      // Both 200 (existing user - role invitation sent) and 201 (new user created) are success
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final emailSent = responseData['emailSent'] ?? true;

        if (emailSent) {
          print('✅ Invite sent successfully');
        } else {
          print(
            '⚠️ Invite processed successfully, but email was not sent (SMTP not configured)',
          );
        }
        return true;
      } else {
        print('❌ Failed to send invite: ${response.statusMessage}');
        print('❌ Response: ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      print('❌ Error sending invite: ${e.message}');
      print('❌ Error type: ${e.type}');
      if (e.response != null) {
        print('❌ Error status: ${e.response?.statusCode}');
        print('❌ Error response: ${e.response?.data}');

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
      print('❌ General error sending invite: $e');
      return false;
    }
  }
}

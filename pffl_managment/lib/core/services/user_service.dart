import 'package:dio/dio.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

/// Service for user-related API calls
class UserService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Get Dio instance with authentication token
  static Future<Dio> _getAuthenticatedDio() async {
    final token = await AuthService.getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
    return _dio;
  }

  /// Fetch users by role
  /// GET /api/user?role=free-agent
  static Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get(
        '/user',
        queryParameters: {'role': role},
      );

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
        print('Failed to fetch users: ${response.statusMessage}');
        return [];
      }
    } on DioException catch (e) {
      print('Error fetching users by role: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('General error fetching users: $e');
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
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.put(
        '/user/$userId',
        data: {'role': newRole},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update user role: ${response.statusMessage}');
        return false;
      }
    } on DioException catch (e) {
      print('Error updating user role: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      return false;
    } catch (e) {
      print('General error updating user role: $e');
      return false;
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
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Get Dio instance with authentication token
  static Future<Dio> _getAuthenticatedDio() async {
    final token = await AuthService.getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
    return _dio;
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
        data: {
          'email': email,
          'role': role,
        },
      );

      // Both 200 (existing user - role invitation sent) and 201 (new user created) are success
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to send invite: ${response.statusMessage}');
        return false;
      }
    } on DioException catch (e) {
      print('Error sending invite: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        // 409 Conflict is now handled on backend - should not occur for role invitations
        // But if it does, we'll treat it as an error (e.g., duplicate key error)
        if (e.response?.statusCode == 409) {
          print('Conflict error: ${e.response?.data}');
          return false;
        }
      }
      return false;
    } catch (e) {
      print('General error sending invite: $e');
      return false;
    }
  }
}


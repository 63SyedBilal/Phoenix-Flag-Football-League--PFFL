import 'package:dio/dio.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

/// Service for payment-related API calls
class PaymentService {
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

  /// Get all payments for superadmin
  /// GET /api/superadmin/payments/all?status=paid|unpaid|all
  static Future<List<Map<String, dynamic>>> getAllPayments(String status) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get(
        '/superadmin/payments/all',
        queryParameters: {'status': status},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        } else if (data['data'] != null) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        print('Failed to fetch payments: ${response.statusMessage}');
        return [];
      }
    } on DioException catch (e) {
      print('Error fetching payments: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      return [];
    } catch (e) {
      print('General error fetching payments: $e');
      return [];
    }
  }

  /// Get all teams
  /// GET /api/team
  static Future<List<Map<String, dynamic>>> getAllTeams() async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/team');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          return (data['data'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        print('Failed to fetch teams: ${response.statusMessage}');
        return [];
      }
    } on DioException catch (e) {
      print('Error fetching teams: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      return [];
    } catch (e) {
      print('General error fetching teams: $e');
      return [];
    }
  }

  /// Search users
  /// GET /api/user
  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final dio = await _getAuthenticatedDio();
      final response = await dio.get('/user');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          final allUsers = (data['data'] as List).cast<Map<String, dynamic>>();
          // Filter users by query (search in name or email)
          if (query.isEmpty) {
            return allUsers;
          }
          final lowerQuery = query.toLowerCase();
          return allUsers.where((user) {
            final firstName = (user['firstName'] as String? ?? '').toLowerCase();
            final lastName = (user['lastName'] as String? ?? '').toLowerCase();
            final email = (user['email'] as String? ?? '').toLowerCase();
            return firstName.contains(lowerQuery) ||
                lastName.contains(lowerQuery) ||
                email.contains(lowerQuery) ||
                '$firstName $lastName'.trim().contains(lowerQuery);
          }).toList();
        }
        return [];
      } else {
        print('Failed to search users: ${response.statusMessage}');
        return [];
      }
    } on DioException catch (e) {
      print('Error searching users: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      return [];
    } catch (e) {
      print('General error searching users: $e');
      return [];
    }
  }
}

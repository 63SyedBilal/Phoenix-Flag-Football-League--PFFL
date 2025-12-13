import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.13:3000/api';
  static final Dio _dio = Dio();
  
  // Allow overriding the base URL for testing
  static String _baseUrlOverride = '';
  
  static String get effectiveBaseUrl => _baseUrlOverride.isNotEmpty ? _baseUrlOverride : baseUrl;
  
  static void setBaseUrl(String url) {
    _baseUrlOverride = url;
  }

  // Login API
  static Future<AuthResponse?> login(String email, String password) async {
    try {
      print('Attempting to login with email: $email');
      print('Using base URL: $effectiveBaseUrl');
      final response = await _dio.post(
        '$effectiveBaseUrl/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('Login response status: ${response.statusCode}');
      print('Login response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final authResponse = AuthResponse.fromJson(data);
        
        // Save token for future requests
        await saveToken(authResponse.token);
        
        return authResponse;
      } else {
        print('Login failed with status: ${response.statusCode}, message: ${response.statusMessage}');
        return null;
      }
    } on DioException catch (e) {
      print('Login Dio error: ${e.message}');
      if (e.response != null) {
        print('Error response status: ${e.response?.statusCode}');
        print('Error response data: ${e.response?.data}');
      }
      // Return null to indicate login failure
      return null;
    } catch (e) {
      print('Login general error: $e');
      // Return null to indicate login failure
      return null;
    }
  }

  // Register API
  static Future<AuthResponse?> register(Map<String, dynamic> userData) async {
    try {
      print('Attempting to register user with email: ${userData['email']}');
      print('Using base URL: $effectiveBaseUrl');
      final response = await _dio.post(
        '$effectiveBaseUrl/register',
        data: userData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final authResponse = AuthResponse.fromJson(data);
        
        // Save token for future requests
        await saveToken(authResponse.token);
        
        return authResponse;
      } else {
        print('Registration failed: ${response.statusMessage}');
        return null;
      }
    } on DioException catch (e) {
      print('Registration error: ${e.message}');
      // Return null to indicate registration failure
      return null;
    } catch (e) {
      print('Registration error: $e');
      // Return null to indicate registration failure
      return null;
    }
  }

  // Method to store token for future requests
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Method to get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Method to clear token (logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Configure Dio with interceptors
  static void configureDio() {
    // Add interceptor to automatically attach token to requests
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired, clear it
          await clearToken();
        }
        return handler.next(e);
      },
    ));
  }
}

class AuthResponse {
  final String message;
  final UserData data;
  final String token;

  AuthResponse({
    required this.message,
    required this.data,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'],
      data: UserData.fromJson(json['data']),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
      'token': token,
    };
  }
}

class UserData {
  final String id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phone;
  final String role;
  final bool needsProfileCompletion;
  final bool needsProfileForm;
  final bool needsTeamForm;

  UserData({
    required this.id,
    this.firstName,
    this.lastName,
    required this.email,
    this.phone,
    required this.role,
    required this.needsProfileCompletion,
    required this.needsProfileForm,
    required this.needsTeamForm,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      needsProfileCompletion: json['needsProfileCompletion'] ?? false,
      needsProfileForm: json['needsProfileForm'] ?? false,
      needsTeamForm: json['needsTeamForm'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'needsProfileCompletion': needsProfileCompletion,
      'needsProfileForm': needsProfileForm,
      'needsTeamForm': needsTeamForm,
    };
  }
}
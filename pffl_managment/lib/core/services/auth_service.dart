import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/config/app_config.dart';

class AuthService {
  // Lazy initialization to ensure platform detection works
  static Dio? _dioInstance;

  static Dio get _dio {
    _dioInstance ??= Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl, // This will use the getter
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: {'Content-Type': 'application/json'},
        // Enable follow redirects
        followRedirects: true,
        maxRedirects: 5,
        // Validate status codes
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Configure SSL certificate pinning for security
    _configureCertificatePinning(_dioInstance!);

    // Ensure baseUrl is always current
    _dioInstance!.options.baseUrl = AppConfig.baseUrl;
    return _dioInstance!;
  }

  /// Configure SSL certificate pinning
  static void _configureCertificatePinning(Dio dio) {
    // For production, you should pin your SSL certificate
    // This is a basic setup - in production, pin your actual certificate

    if (dio.httpClientAdapter is IOHttpClientAdapter) {
      final adapter = dio.httpClientAdapter as IOHttpClientAdapter;

      // Create HttpClient with certificate validation
      final client = HttpClient();

      // For local development, allow all certificates and bypass SSL validation
      // REMOVE THIS IN PRODUCTION - Only for local development
      client.badCertificateCallback = (cert, host, port) => true;

      adapter.createHttpClient = () => client;
    }
  }

  // Allow overriding the base URL for testing
  static String? _baseUrlOverride;

  static String get effectiveBaseUrl => _baseUrlOverride ?? AppConfig.baseUrl;

  static void setBaseUrl(String? url) {
    _baseUrlOverride = url;
    if (url != null) {
      _dio.options.baseUrl = url;
    } else {
      _dio.options.baseUrl = AppConfig.baseUrl; // Use getter
    }
  }

  // Reset Dio instance (useful for testing or reconfiguration)
  static void resetDio() {
    _dioInstance = null;
  }

  // Store the working base URL after successful login
  static String? _workingBaseUrl;

  // Get a working Dio instance with URL fallback (for other services to use)
  static Future<Dio> getWorkingDio() async {
    // Use the working baseUrl from login, or fallback to AppConfig
    final workingBaseUrl = _workingBaseUrl ?? AppConfig.baseUrl;

    final dio = Dio(
      BaseOptions(
        baseUrl: workingBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add authentication token
    final token = await getToken();
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }

    return dio;
  }

  /// Map backend role names to frontend role names
  /// Backend uses "stat-keeper", frontend uses "statkeeper"
  static String mapRole(String backendRole) {
    switch (backendRole.toLowerCase()) {
      case 'stat-keeper':
        return 'statkeeper';
      case 'free-agent':
        return 'freeagent';
      case 'superadmin':
        return 'superadmin';
      default:
        return backendRole.toLowerCase();
    }
  }

  // Login API with automatic URL fallback
  static Future<AuthResponse?> login(String email, String password) async {
    // List of URLs to try (in order)
    final urlsToTry = <String>[AppConfig.baseUrl];

    DioException? lastError;

    // Try each URL until one works
    for (final url in urlsToTry) {
      try {
        print(
          'Platform: ${Platform.isAndroid
              ? "Android"
              : Platform.isIOS
              ? "iOS"
              : "Other"}',
        );

        // Create a fresh Dio instance for this attempt
        final dio = Dio(
          BaseOptions(
            baseUrl: url,
            connectTimeout: const Duration(
              seconds: 120,
            ), // Increased timeout to handle network delays
            receiveTimeout: const Duration(seconds: 300),
            sendTimeout: const Duration(seconds: 300),
            headers: {'Content-Type': 'application/json'},
            // Additional options for better connectivity
            followRedirects: true,
            maxRedirects: 5,
          ),
        );

        final response = await dio.post(
          AppConfig.loginEndpoint,
          data: {'email': email.trim(), 'password': password},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
          final tempResponse = AuthResponse.fromJson(data);

          // Map role from backend to frontend format
          final mappedRole = mapRole(tempResponse.data.role);
          final mappedUserData = UserData(
            id: tempResponse.data.id,
            firstName: tempResponse.data.firstName,
            lastName: tempResponse.data.lastName,
            email: tempResponse.data.email,
            phone: tempResponse.data.phone,
            role: mappedRole,
            needsProfileCompletion: tempResponse.data.needsProfileCompletion,
            needsProfileForm: tempResponse.data.needsProfileForm,
            needsTeamForm: tempResponse.data.needsTeamForm,
          );

          final authResponse = AuthResponse(
            message: tempResponse.message,
            data: mappedUserData,
            token: tempResponse.token,
          );

          // Save token and working URL for future requests
          await saveToken(authResponse.token);
          // Save the working URL for other services to use
          _workingBaseUrl = url;
          // Update the main Dio instance with working URL
          _dioInstance?.options.baseUrl = url;
          if (_dioInstance != null) {
            _dioInstance!.options.baseUrl = url;
          }

          return authResponse;
        } else {
          print(
            'Login failed with status: ${response.statusCode}, message: ${response.statusMessage}',
          );
          return null;
        }
      } on DioException catch (e) {
        lastError = e;

        // If we got a 401 (Unauthorized), don't try other URLs - this is a valid auth error
        // Rethrow immediately so the auth_provider can handle it
        if (e.response?.statusCode == 401) {
          rethrow;
        }

        // If this is not the last URL and it's a connection error, continue to next
        if (url != urlsToTry.last) {
          continue;
        }

        // If all URLs failed, throw the last error
        rethrow;
      } catch (e) {
        if (url != urlsToTry.last) {
          continue;
        }
        rethrow;
      }
    }

    // If we get here, all URLs failed

    // Final error handling
    if (lastError != null) {

      // Handle different error types
      if (lastError.type == DioExceptionType.connectionTimeout ||
          lastError.type == DioExceptionType.sendTimeout ||
          lastError.type == DioExceptionType.receiveTimeout) {
        for (final url in urlsToTry) {
        }
      }

      // Re-throw to let AuthProvider handle the error
      throw lastError;
    }

    return null;
  }

  // Register API with automatic URL fallback (same as login)
  static Future<AuthResponse?> register(Map<String, dynamic> userData) async {
    // List of URLs to try (in order) - same as login
    final urlsToTry = <String>[AppConfig.baseUrl];

    DioException? lastError;

    // Try each URL until one works
    for (final url in urlsToTry) {
      try {
        print(
          'Platform: ${Platform.isAndroid
              ? "Android"
              : Platform.isIOS
              ? "iOS"
              : "Other"}',
        );

        // Create a fresh Dio instance for this attempt
        // Use adequate timeout for reliable connections
        final dio = Dio(
          BaseOptions(
            baseUrl: url,
            connectTimeout: const Duration(seconds: 300),
            receiveTimeout: const Duration(seconds: 300),
            sendTimeout: const Duration(seconds: 300),
            headers: {'Content-Type': 'application/json'},
            followRedirects: true,
            maxRedirects: 5,
          ),
        );

        final response = await dio.post(
          AppConfig.registerEndpoint,
          data: userData,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
          final authResponse = AuthResponse.fromJson(data);

          // Save token for future requests
          await saveToken(authResponse.token);

          // Save the working URL for other services to use
          _workingBaseUrl = url;
          // Update the main Dio instance with working URL
          _dioInstance?.options.baseUrl = url;
          if (_dioInstance != null) {
            _dioInstance!.options.baseUrl = url;
          }

          return authResponse;
        } else {
          return null;
        }
      } on DioException catch (e) {
        lastError = e;

        // If this is not the last URL, continue to next
        if (url != urlsToTry.last) {
          continue;
        }

        // If all URLs failed, throw the last error
        rethrow;
      } catch (e) {
        if (url != urlsToTry.last) {
          continue;
        }
        rethrow;
      }
    }

    // If we get here, all URLs failed

    // Final error handling
    if (lastError != null) {

      // Handle different error types
      if (lastError.type == DioExceptionType.connectionTimeout ||
          lastError.type == DioExceptionType.sendTimeout ||
          lastError.type == DioExceptionType.receiveTimeout) {
        for (final url in urlsToTry) {
        }
      }

      // Re-throw to let SignupProvider handle the error
      throw lastError;
    }

    return null;
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

  // Track if interceptors are already configured
  static bool _interceptorsConfigured = false;

  // Configure Dio with interceptors
  static void configureDio() {
    // Prevent duplicate interceptors
    if (_interceptorsConfigured) {
      return;
    }

    // Ensure baseUrl and timeouts are set correctly
    _dio.options.baseUrl = AppConfig.baseUrl; // Use getter to get current URL
    _dio.options.connectTimeout = AppConfig.connectTimeout;
    _dio.options.receiveTimeout = AppConfig.receiveTimeout;
    _dio.options.sendTimeout = AppConfig.sendTimeout;
    print(
      'Platform: ${Platform.isAndroid
          ? "Android"
          : Platform.isIOS
          ? "iOS"
          : "Other"}',
    );

    // Add interceptor to automatically attach token to requests
    _dio.interceptors.add(
      InterceptorsWrapper(
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
      ),
    );

    _interceptorsConfigured = true;
  }

  // Test server connectivity
  static Future<bool> testConnection() async {
    try {
      final response = await _dio.get(
        '/test-db',
        options: Options(
          receiveTimeout: const Duration(seconds: 300),
          sendTimeout: const Duration(seconds: 300),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Change password
  /// PUT /api/user/change-password
  static Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      print(
        '🔐 [AUTH SERVICE] Current password length: ${currentPassword.length}',
      );

      // Check if token exists
      final token = await getToken();
      if (token != null) {
      }

      final dio = await getWorkingDio();
      print(
        '🔐 [AUTH SERVICE] Making request to: ${dio.options.baseUrl}/user/change-password',
      );

      final response = await dio.put(
        '/user/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = response.data['error'] ?? 'Failed to change password';
        throw Exception(error);
      }
    } on DioException catch (e) {

      if (e.response != null) {
        final errorData = e.response?.data;
        final error = errorData is Map
            ? (errorData['error'] ?? 'Failed to change password').toString()
            : 'Failed to change password';
        throw Exception(error);
      }
      throw Exception('Failed to connect to server');
    } catch (e) {
      rethrow;
    }
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
    return {'message': message, 'data': data.toJson(), 'token': token};
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
    // Handle both string and ObjectId types for id
    final id = json['id']?.toString() ?? json['_id']?.toString() ?? '';

    return UserData(
      id: id,
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? '',
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


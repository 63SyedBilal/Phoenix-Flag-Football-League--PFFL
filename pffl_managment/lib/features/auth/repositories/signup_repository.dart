import 'package:dio/dio.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

/// Result of a signup attempt
class SignupResult {
  final bool success;
  final Map<String, String?>? fieldErrors;
  final String? generalError;

  const SignupResult({
    required this.success,
    this.fieldErrors,
    this.generalError,
  });

  factory SignupResult.success() {
    return const SignupResult(success: true);
  }

  factory SignupResult.failure({
    Map<String, String?>? fieldErrors,
    String? generalError,
  }) {
    return SignupResult(
      success: false,
      fieldErrors: fieldErrors,
      generalError: generalError,
    );
  }
}

/// Repository for handling signup API calls
class SignupRepository {
  /// Register a new user
  static Future<SignupResult> signup(Map<String, dynamic> userData) async {
    try {

      // Call AuthService register method
      final authResponse = await AuthService.register(userData);

      if (authResponse != null) {
        return SignupResult.success();
      } else {
        // This should not happen as exceptions are re-thrown, but handle it anyway
        return SignupResult.failure(
          generalError: 'Registration failed. Please try again.',
        );
      }
    } on DioException catch (e) {

      return _handleDioError(e);
    } catch (e) {
      return SignupResult.failure(
        generalError: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Handle DioException and map to appropriate errors
  static SignupResult _handleDioError(DioException e) {
    // Handle specific error cases
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final errorData = e.response!.data;

      if (statusCode == 409) {
        // Conflict - email or phone already exists
        final errorMessage =
            errorData['error'] ?? 'Email or phone already exists';

        final fieldErrors = <String, String?>{};

        if (errorMessage.toLowerCase().contains('email')) {
          fieldErrors['email'] = 'This email is already registered';
        } else if (errorMessage.toLowerCase().contains('phone')) {
          fieldErrors['phone'] = 'This phone number is already registered';
        } else {
          return SignupResult.failure(generalError: errorMessage);
        }

        return SignupResult.failure(fieldErrors: fieldErrors);
      } else if (statusCode == 400) {
        // Bad request - validation error
        final errorMessage =
            errorData['error'] ?? 'Invalid data. Please check your input.';
        return SignupResult.failure(generalError: errorMessage);
      } else if (statusCode == 500) {
        // Server error
        return SignupResult.failure(
          generalError: 'Server error. Please try again later.',
        );
      } else {
        return SignupResult.failure(
          generalError:
              errorData['error'] ?? 'Registration failed. Please try again.',
        );
      }
    } else {
      // Network or connection error
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return SignupResult.failure(
          generalError:
              'Connection timeout. Please check:\n1. Backend server is running\n2. Both devices are on same WiFi\n3. Firewall allows port 3000',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return SignupResult.failure(
          generalError:
              'Cannot connect to server. Please check:\n1. Backend server is running at http://192.168.1.13:3000\n2. Both devices are on same WiFi network\n3. Try restarting the backend server',
        );
      } else {
        return SignupResult.failure(
          generalError:
              'Network error. Please check your connection and try again.',
        );
      }
    }
  }
}


import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/services/device_service.dart';

/// Service for handling error reporting and logging to backend
class ErrorReportingService {
  static bool _initialized = false;
  static String? _deviceId;
  static String? _deviceInfo;

  /// Initialize error reporting
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Get device information
      _deviceId = DeviceService.deviceId;
      await _collectDeviceInfo();

      // Set up global error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        _reportError(
          'Flutter Framework Error',
          details.exception.toString(),
          details.stack.toString(),
          'framework_error',
        );
      };

      // Handle uncaught asynchronous errors
      PlatformDispatcher.instance.onError = (error, stack) {
        _reportError(
          'Uncaught Async Error',
          error.toString(),
          stack.toString(),
          'async_error',
        );
        return true;
      };

      _initialized = true;
      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  /// Collect device information for error reports
  static Future<void> _collectDeviceInfo() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final Map<String, dynamic> deviceData = {};

      if (DeviceService.deviceId?.startsWith('android') == true || DeviceService.deviceId?.contains('.') == false) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceData.addAll({
          'platform': 'android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdkVersion': androidInfo.version.sdkInt,
          'brand': androidInfo.brand,
        });
      } else {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceData.addAll({
          'platform': 'ios',
          'model': iosInfo.model,
          'systemVersion': iosInfo.systemVersion,
          'name': iosInfo.name,
        });
      }

      _deviceInfo = json.encode(deviceData);
    } catch (e) {
      _deviceInfo = json.encode({'platform': 'unknown', 'error': e.toString()});
    }
  }

  /// Report an error to the backend
  static Future<void> _reportError(
    String title,
    String error,
    String stackTrace,
    String errorType, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Don't report errors in debug mode to avoid spam during development
      if (kDebugMode && !kProfileMode) {
        return;
      }

      final errorData = {
        'title': title,
        'error': error,
        'stackTrace': stackTrace,
        'errorType': errorType,
        'deviceId': _deviceId ?? 'unknown',
        'deviceInfo': _deviceInfo ?? '{}',
        'timestamp': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
        'platform': _getPlatformName(),
        if (additionalData != null) ...additionalData,
      };

      // Send error to backend (fire and forget - don't await)
      unawaited(_sendErrorToBackend(errorData).catchError((e) {
        if (kDebugMode) {
        }
      }));

    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  /// Send error data to backend
  static Future<void> _sendErrorToBackend(Map<String, dynamic> errorData) async {
    try {
      final dio = await AuthService.getWorkingDio();
      await dio.post('/error-report', data: errorData);
    } catch (e) {
      // If we can't send to authenticated endpoint, try unauthenticated
      try {
        final dio = await AuthService.getWorkingDio();
        await dio.post('/error-report', data: errorData);
      } catch (e2) {
        // Last resort - just log locally
        if (kDebugMode) {
        }
      }
    }
  }

  /// Record a caught exception
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    Map<String, dynamic>? additionalData,
  }) async {
    await _reportError(
      reason ?? 'Caught Exception',
      exception.toString(),
      stack?.toString() ?? 'No stack trace',
      'caught_exception',
      additionalData: additionalData,
    );

    if (kDebugMode) {
    }
  }

  /// Record a non-fatal error
  static Future<void> recordNonFatalError(
    dynamic exception,
    StackTrace? stack, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) async {
    await _reportError(
      context ?? 'Non-Fatal Error',
      exception.toString(),
      stack?.toString() ?? 'No stack trace',
      'non_fatal_error',
      additionalData: additionalData,
    );

    if (kDebugMode) {
    }
  }

  /// Set user identifier for error reports
  static Future<void> setUserIdentifier(String userId) async {
    // Store user ID for future error reports
    _deviceId = userId; // Override device ID with user ID for better tracking
    if (kDebugMode) {
    }
  }

  /// Log a message to error reports
  static Future<void> log(String message, {String? category}) async {
    try {
      final logData = {
        'message': message,
        'category': category ?? 'general',
        'timestamp': DateTime.now().toIso8601String(),
        'deviceId': _deviceId ?? 'unknown',
        'level': 'info',
      };

      // Send log to backend (fire and forget)
      unawaited(_sendLogToBackend(logData).catchError((e) {
        if (kDebugMode) {
        }
      }));

      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  /// Send log data to backend
  static Future<void> _sendLogToBackend(Map<String, dynamic> logData) async {
    try {
      final dio = await AuthService.getWorkingDio();
      await dio.post('/error-log', data: logData);
    } catch (e) {
      // If authenticated endpoint fails, try unauthenticated
      try {
        final dio = await AuthService.getWorkingDio();
        await dio.post('/error-log', data: logData);
      } catch (e2) {
        // Silently fail for logs
      }
    }
  }

  /// Get platform name
  static String _getPlatformName() {
    if (DeviceService.deviceId?.startsWith('android') == true || DeviceService.deviceId?.contains('.') == false) {
      return 'android';
    } else {
      return 'ios';
    }
  }

  // Getters
  static bool get isInitialized => _initialized;
  static String? get deviceId => _deviceId;
}


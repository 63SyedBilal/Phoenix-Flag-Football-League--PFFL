import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Service for handling stat-related errors with user-friendly messages
class StatErrorHandler {
  /// Convert technical errors to user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is Exception) {
      return _handleGeneralException(error);
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Handle Dio-specific errors
  static String _handleDioError(DioException error) {
    switch (error.response?.statusCode) {
      case 400:
        return 'Invalid data provided. Please check your inputs and try again.';
      case 401:
        return 'Authentication failed. Please login again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The stats service is currently unavailable. Please contact support.';
      case 422:
        return 'The data provided is invalid. Please check all fields.';
      case 500:
        return 'Server error occurred. Please try again later.';
      case 503:
        return 'Service temporarily unavailable. Please try again in a few minutes.';
      default:
        if (error.type == DioExceptionType.connectionTimeout) {
          return 'Connection timeout. Please check your internet connection.';
        } else if (error.type == DioExceptionType.receiveTimeout) {
          return 'Server response timeout. Please try again.';
        } else if (error.type == DioExceptionType.connectionError) {
          return 'Network connection error. Please check your internet.';
        } else {
          return 'Network error occurred. Please try again.';
        }
    }
  }

  /// Handle general exceptions
  static String _handleGeneralException(Exception error) {
    final message = error.toString();

    if (message.contains('Player ID is required')) {
      return 'Please select a player before saving stats.';
    } else if (message.contains('Match does not have a valid league')) {
      return 'This match is not properly configured. Please contact support.';
    } else if (message.contains('Failed to save stat')) {
      return 'Unable to save stats. Please try again or contact support.';
    } else if (message.contains('User ID not found')) {
      return 'Please logout and login again to refresh your session.';
    } else {
      return 'An error occurred while saving stats. Please try again.';
    }
  }

  /// Show error dialog with retry option
  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  /// Show error snackbar with action
  static void showErrorSnackBar(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Check if error is retryable
  static bool isRetryableError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      return statusCode == 500 ||
          statusCode == 503 ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError;
    }
    return false;
  }

  /// Get retry delay based on attempt number
  static Duration getRetryDelay(int attemptNumber) {
    // Exponential backoff: 2s, 4s, 8s
    return Duration(seconds: 2 * attemptNumber);
  }
}

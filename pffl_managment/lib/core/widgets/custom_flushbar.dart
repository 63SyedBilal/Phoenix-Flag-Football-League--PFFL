import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class CustomFlushbar {
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    Flushbar(
      title: title,
      message: message,
      icon: const Icon(
        Icons.check_circle,
        color: Colors.green,
      ),
      backgroundColor: Colors.green.shade100,
      duration: duration,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      borderColor: Colors.green,
      borderWidth: 1,
    ).show(context);
  }

  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    Flushbar(
      title: title,
      message: message,
      icon: const Icon(
        Icons.error,
        color: Colors.red,
      ),
      backgroundColor: Colors.red.shade100,
      duration: duration,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      borderColor: Colors.red,
      borderWidth: 1,
    ).show(context);
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    Flushbar(
      title: title,
      message: message,
      icon: const Icon(
        Icons.info,
        color: Colors.blue,
      ),
      backgroundColor: Colors.blue.shade100,
      duration: duration,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      borderColor: Colors.blue,
      borderWidth: 1,
    ).show(context);
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    Flushbar(
      title: title,
      message: message,
      icon: const Icon(
        Icons.warning,
        color: Colors.orange,
      ),
      backgroundColor: Colors.orange.shade100,
      duration: duration,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      borderColor: Colors.orange,
      borderWidth: 1,
    ).show(context);
  }
}
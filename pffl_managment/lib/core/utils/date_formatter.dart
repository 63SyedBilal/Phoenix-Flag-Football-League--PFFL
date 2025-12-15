import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility class for consistent date and time formatting across the app
class DateFormatter {
  /// Format date in a standard format (MM/dd/yyyy)
  /// Example: DateTime(2024, 10, 28) -> "10/28/2024"
  static String format(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MM/dd/yyyy').format(date);
  }

  /// Format date in a standard format (MM/dd/yyyy)
  /// Example: DateTime(2024, 10, 28) -> "10/28/2024"
  static String formatDate(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  /// Format game date as "Sat 28 Oct"
  /// Example: DateTime(2024, 10, 28) -> "Sat 28 Oct"
  static String formatGameDate(DateTime date) {
    return DateFormat('EEE d MMM').format(date);
  }

  /// Format game time as "01:05 AM PKT" or appropriate format
  /// Example: TimeOfDay(hour: 1, minute: 5) -> "01:05 AM PKT"
  static String formatGameTime(TimeOfDay time, {String timezone = 'PKT'}) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period $timezone';
  }

  /// Format date and time together
  static String formatGameDateTime(DateTime dateTime, {String timezone = 'PKT'}) {
    final dateStr = formatGameDate(dateTime);
    final time = TimeOfDay.fromDateTime(dateTime);
    final timeStr = formatGameTime(time, timezone: timezone);
    return '$dateStr $timeStr';
  }
}

class DateFormatter {
  static const List<String> _months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Formats a DateTime to a readable string format
  /// Example: December 10, 2025
  static String format(DateTime? date) {
    if (date == null) return '10 December 2025';
    return '${date.day} ${_months[date.month]} ${date.year}';
  }

  /// Formats a DateTime to a short format
  /// Example: Dec 10, 2025
  static String formatShort(DateTime? date) {
    if (date == null) return 'Dec 10, 2025';
    const List<String> shortMonths = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${shortMonths[date.month]} ${date.day}, ${date.year}';
  }

  /// Formats a DateTime to numeric format
  /// Example: 12/10/2025
  static String formatNumeric(DateTime? date) {
    if (date == null) return '12/10/2025';
    return '${date.month}/${date.day}/${date.year}';
  }

  /// Formats a DateTime to ISO format
  /// Example: 2025-12-10
  static String formatISO(DateTime? date) {
    if (date == null) return '2025-12-10';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Model class for payment history items
class PaymentHistoryItem {
  final String id;
  final String userId;
  final String leagueId;
  final String leagueName;
  final String? leagueLogo;
  final String leagueFormat;
  final String leagueStartDate;
  final String leagueEndDate;
  final double amount;
  final String paymentMethod;
  final String status;
  final String transactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentHistoryItem({
    required this.id,
    required this.userId,
    required this.leagueId,
    required this.leagueName,
    this.leagueLogo,
    required this.leagueFormat,
    required this.leagueStartDate,
    required this.leagueEndDate,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.transactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor to create PaymentHistoryItem from JSON
  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    // Handle populated userId object
    final userData = json['userId'];
    String userId = '';
    if (userData is Map<String, dynamic>) {
      userId = userData['_id'] ?? userData['id'] ?? '';
    } else if (userData is String) {
      userId = userData;
    }

    // Handle populated leagueId object
    final leagueData = json['leagueId'];
    String leagueId = '';
    String leagueName = 'Unknown League';
    String? leagueLogo;
    String leagueFormat = 'Unknown Format';
    String leagueStartDate = 'N/A';
    String leagueEndDate = 'N/A';

    if (leagueData is Map<String, dynamic>) {
      // League is populated as an object
      leagueId = leagueData['_id'] ?? leagueData['id'] ?? '';
      leagueName = leagueData['leagueName'] ?? 'Unknown League';
      leagueLogo = leagueData['logo'];
      leagueFormat = leagueData['format'] ?? 'Unknown Format';
      leagueStartDate = _formatDate(leagueData['startDate']);
      leagueEndDate = _formatDate(leagueData['endDate']);
    } else if (leagueData is String) {
      // League is just an ID string (fallback)
      leagueId = leagueData;
      leagueName = json['leagueName'] ?? 'Unknown League';
      leagueLogo = json['leagueLogo'];
      leagueFormat = json['leagueFormat'] ?? 'Unknown Format';
      leagueStartDate = _formatDate(json['leagueStartDate']);
      leagueEndDate = _formatDate(json['leagueEndDate']);
    }

    return PaymentHistoryItem(
      id: json['_id'] ?? json['id'] ?? '',
      userId: userId,
      leagueId: leagueId,
      leagueName: leagueName,
      leagueLogo: leagueLogo,
      leagueFormat: leagueFormat,
      leagueStartDate: leagueStartDate,
      leagueEndDate: leagueEndDate,
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'Unknown',
      status: json['status'] ?? 'unknown',
      transactionId: json['transactionId'] ?? json['stripePaymentIntentId'] ?? 'N/A',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Helper method to format dates
  static String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateValue.toString());
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'leagueId': leagueId,
      'leagueName': leagueName,
      'leagueLogo': leagueLogo,
      'leagueFormat': leagueFormat,
      'leagueStartDate': leagueStartDate,
      'leagueEndDate': leagueEndDate,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionId': transactionId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Get formatted date for display
  String get formattedDate {
    return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
  }

  /// Get formatted time for display
  String get formattedTime {
    final hour = createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour;
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')} $period';
  }

  /// Create a copy with updated fields
  PaymentHistoryItem copyWith({
    String? id,
    String? userId,
    String? leagueId,
    String? leagueName,
    String? leagueLogo,
    String? leagueFormat,
    String? leagueStartDate,
    String? leagueEndDate,
    double? amount,
    String? paymentMethod,
    String? status,
    String? transactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentHistoryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      leagueId: leagueId ?? this.leagueId,
      leagueName: leagueName ?? this.leagueName,
      leagueLogo: leagueLogo ?? this.leagueLogo,
      leagueFormat: leagueFormat ?? this.leagueFormat,
      leagueStartDate: leagueStartDate ?? this.leagueStartDate,
      leagueEndDate: leagueEndDate ?? this.leagueEndDate,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

import 'package:pffl_managment/core/services/payment_service.dart';
import 'package:pffl_managment/core/services/notification_local_service.dart';
import 'package:flutter/material.dart';

/// Model for payment display
class PaymentModel {
  final String id;
  final String recordNumber;
  final String date;
  final String player;
  final String team;
  final String league;
  final String amount;
  final String method;
  final String status; // 'completed', 'pending', 'refunded'
  final String? refundDate;
  final String? transactionId;
  final String? refundReason;
  final String? playerId;
  final String? leagueId;

  PaymentModel({
    required this.id,
    required this.recordNumber,
    required this.date,
    required this.player,
    required this.team,
    required this.league,
    required this.amount,
    required this.method,
    required this.status,
    this.refundDate,
    this.transactionId,
    this.refundReason,
    this.playerId,
    this.leagueId,
  });
}

/// Provider for Payment History Screen
class PaymentHistoryProvider extends ChangeNotifier {
  // State variables
  List<PaymentModel> _allPayments = [];
  List<PaymentModel> _filteredPayments = [];
  List<Map<String, dynamic>> _teams = [];
  int _selectedTabIndex = 0; // 0: Completed, 1: Pending, 2: Refunded
  String? _selectedTeamId;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  // Getters
  List<PaymentModel> get payments => _filteredPayments;
  List<Map<String, dynamic>> get teams => _teams;
  int get selectedTabIndex => _selectedTabIndex;
  String? get selectedTeamId => _selectedTeamId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get selectedTeamName {
    if (_selectedTeamId == null) return null;
    final team = _teams.firstWhere(
      (t) => (t['_id']?.toString() ?? t['id']?.toString()) == _selectedTeamId,
      orElse: () => {},
    );
    return team['teamName'] as String?;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Initialize and fetch data
  Future<void> initialize() async {
    if (_isLoading || _disposed) return;
    await NotificationLocalService.init();
    await Future.wait([fetchTeams(), fetchPayments()]);
  }

  /// Fetch all teams
  Future<void> fetchTeams() async {
    if (_disposed) return;

    try {
      final teamsList = await PaymentService.getAllTeams();

      if (_disposed) return; // Check again after async operation

      _teams = teamsList;
      _safeNotifyListeners();
    } catch (e) {}
  }

  /// Fetch payments from backend
  Future<void> fetchPayments() async {
    if (_disposed) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      _safeNotifyListeners();

      // Fetch all payments (we'll filter by status on the client side)
      final paymentsList = await PaymentService.getAllPayments('all');

      if (_disposed) return; // Check again after async operation

      // Convert to PaymentModel
      _allPayments = paymentsList.asMap().entries.map((entry) {
        final index = entry.key;
        final payment = entry.value;
        return _convertPaymentToModel(payment, index + 1);
      }).toList();

      // Apply filters
      _applyFilters();

      _isLoading = false;
      _safeNotifyListeners();
    } catch (e) {
      if (_disposed) return; // Don't update state if disposed
      _errorMessage = 'Failed to load payment history';
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  /// Convert backend payment to PaymentModel
  PaymentModel _convertPaymentToModel(
    Map<String, dynamic> payment,
    int recordNumber,
  ) {
    final status = payment['status'] as String? ?? 'unpaid';
    final createdAt =
        payment['createdAt'] as String? ??
        payment['updatedAt'] as String? ??
        DateTime.now().toIso8601String();
    final amount = payment['amount'] as num? ?? 0;
    final userId = payment['userId'];
    final leagueId = payment['leagueId'];
    final teamId = payment['teamId'];

    String playerName = 'Unknown Player';
    if (userId != null && userId is Map) {
      final firstName = userId['firstName'] as String? ?? '';
      final lastName = userId['lastName'] as String? ?? '';
      playerName = '${firstName} ${lastName}'.trim();
      if (playerName.isEmpty) {
        playerName = userId['email'] as String? ?? 'Unknown Player';
      }
    } else if (payment['playerName'] != null) {
      playerName = payment['playerName'] as String;
    }

    String teamName = 'Unknown Team';
    if (teamId != null && teamId is Map) {
      teamName = teamId['teamName'] as String? ?? 'Unknown Team';
    } else if (payment['teamName'] != null) {
      teamName = payment['teamName'] as String;
    } else if (_teams.isNotEmpty && teamId != null) {
      final team = _teams.firstWhere(
        (t) =>
            (t['_id']?.toString() ?? t['id']?.toString()) == teamId.toString(),
        orElse: () => {},
      );
      teamName = team['teamName'] as String? ?? 'Unknown Team';
    }

    String leagueName = 'Unknown League';
    if (leagueId != null && leagueId is Map) {
      leagueName = leagueId['leagueName'] as String? ?? 'Unknown League';
    }

    String paymentMethod = 'N/A';
    if (payment['paymentMethod'] != null) {
      final method = payment['paymentMethod'] as String;
      switch (method.toLowerCase()) {
        case 'stripe':
          paymentMethod = 'Stripe';
          break;
        case 'paypal':
          paymentMethod = 'PayPal';
          break;
        default:
          paymentMethod = method;
      }
    }

    String displayStatus = 'pending';
    if (status.toLowerCase() == 'paid') {
      displayStatus = 'completed';
    } else if (status.toLowerCase() == 'unpaid' ||
        status.toLowerCase() == 'pending') {
      displayStatus = 'pending';
    } else if (status.toLowerCase() == 'refunded') {
      displayStatus = 'refunded';
    }

    return PaymentModel(
      id:
          payment['_id']?.toString() ??
          payment['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      recordNumber: recordNumber.toString().padLeft(2, '0'),
      date: _formatDate(createdAt),
      player: playerName,
      team: teamName,
      league: leagueName,
      amount: '\$${amount.toStringAsFixed(2)}',
      method: paymentMethod,
      status: displayStatus,
      transactionId:
          payment['transactionId'] as String? ??
          payment['stripePaymentIntentId'] as String?,
      refundDate: displayStatus == 'refunded' ? _formatDate(createdAt) : null,
      refundReason: displayStatus == 'refunded' ? 'Others' : null,
      playerId: userId is Map
          ? (userId['_id']?.toString() ?? userId['id']?.toString())
          : userId?.toString(),
      leagueId: leagueId is Map
          ? (leagueId['_id']?.toString() ?? leagueId['id']?.toString())
          : leagueId?.toString(),
    );
  }

  /// Format date string to display format
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
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
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return DateTime.now().toString().substring(0, 10);
    }
  }

  /// Set selected tab index
  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    _applyFilters();
    _safeNotifyListeners();
  }

  /// Set selected team
  void setSelectedTeam(String? teamId) {
    _selectedTeamId = teamId;
    _applyFilters();
    _safeNotifyListeners();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    _safeNotifyListeners();
  }

  /// Apply all filters (status, team, search)
  void _applyFilters() {
    var filtered = List<PaymentModel>.from(_allPayments);

    // Filter by status (tab)
    switch (_selectedTabIndex) {
      case 0: // Completed
        filtered = filtered.where((p) => p.status == 'completed').toList();
        break;
      case 1: // Pending
        filtered = filtered.where((p) => p.status == 'pending').toList();
        break;
      case 2: // Refunded
        filtered = filtered.where((p) => p.status == 'refunded').toList();
        break;
    }

    // Filter by team
    if (_selectedTeamId != null) {
      filtered = filtered.where((p) {
        // Match by team name or team ID
        final team = _teams.firstWhere(
          (t) =>
              (t['_id']?.toString() ?? t['id']?.toString()) == _selectedTeamId,
          orElse: () => {},
        );
        final teamName = team['teamName'] as String? ?? '';
        return p.team == teamName;
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.player.toLowerCase().contains(lowerQuery) ||
            p.team.toLowerCase().contains(lowerQuery) ||
            p.league.toLowerCase().contains(lowerQuery) ||
            p.amount.toLowerCase().contains(lowerQuery) ||
            p.recordNumber.contains(lowerQuery);
      }).toList();
    }

    _filteredPayments = filtered;
  }

  Future<bool> sendPaymentReminder(PaymentModel payment) async {
    if (payment.playerId == null) return false;

    try {
      final body =
          'You have not paid for ${payment.league}, please pay your league fee of ${payment.amount}';

      await NotificationLocalService.showNotification(
        id: payment.id.hashCode,
        title: 'Payment Reminder: ${payment.player}',
        body: body,
      );

      return true;
    } catch (e) {
      debugPrint('Error sending payment reminder: $e');
      return false;
    }
  }

  /// Refresh payments
  Future<void> refresh() async {
    await fetchPayments();
  }
}

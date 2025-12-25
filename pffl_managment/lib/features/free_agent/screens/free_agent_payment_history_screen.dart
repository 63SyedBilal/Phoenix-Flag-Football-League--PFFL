import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';

class FreeAgentPaymentHistoryScreen extends StatefulWidget {
  const FreeAgentPaymentHistoryScreen({super.key});

  @override
  State<FreeAgentPaymentHistoryScreen> createState() =>
      _FreeAgentPaymentHistoryScreenState();
}

class _FreeAgentPaymentHistoryScreenState
    extends State<FreeAgentPaymentHistoryScreen> {
  bool _isLoading = false;
  List<PaymentHistoryItem> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  Future<void> _loadPaymentHistory() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data based on your design
    _payments = [
      PaymentHistoryItem(
        id: "01",
        date: DateTime(2025, 12, 9),
        amount: 250.0,
        method: "Stripe",
        status: "Paid",
        type: PaymentType.league,
        leagueName: "Phoenix Winter 2025",
        leagueDetails: LeagueDetails(
          format: "5v5",
          fee: 250.0,
          startDate: DateTime(2025, 12, 10),
          endDate: DateTime(2026, 2, 25),
        ),
      ),
      PaymentHistoryItem(
        id: "01",
        date: DateTime(2025, 12, 9),
        amount: 250.0,
        method: "Stripe",
        status: "Paid",
        type: PaymentType.league,
        leagueName: "Phoenix Winter 2025",
        leagueDetails: LeagueDetails(
          format: "5v5",
          fee: 250.0,
          startDate: DateTime(2025, 12, 10),
          endDate: DateTime(2026, 2, 25),
        ),
      ),
      PaymentHistoryItem(
        id: "01",
        date: DateTime(2025, 12, 9),
        amount: 25.0,
        method: "Stripe",
        status: "Paid",
        type: PaymentType.match,
        leagueName: "Phoenix Winter 2025",
        matchDetails: MatchDetails(
          matchTime: DateTime(2025, 12, 10, 1, 5),
          teams: "RC vs STA",
        ),
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: ArrowBackButton(onPressed: () => Navigator.pop(context)),
        title: const Text(
          "Payment History",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadPaymentHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "Track all your league payments and receipts.",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),

              /// PAYMENT HISTORY LIST
              Expanded(child: _buildPaymentList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No payment history found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your payments will appear here once you join leagues or matches.",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPaymentHistory,
      child: ListView.builder(
        itemCount: _payments.length,
        itemBuilder: (context, index) {
          final payment = _payments[index];
          return FreeAgentPaymentCard(payment: payment);
        },
      ),
    );
  }
}

class FreeAgentPaymentCard extends StatefulWidget {
  final PaymentHistoryItem payment;

  const FreeAgentPaymentCard({super.key, required this.payment});

  @override
  State<FreeAgentPaymentCard> createState() => _FreeAgentPaymentCardState();
}

class _FreeAgentPaymentCardState extends State<FreeAgentPaymentCard> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with payment ID and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Payment #${payment.id}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  _formatDate(payment.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Payment details
            _buildDetailRow(
              "Amount:",
              "\$${payment.amount.toStringAsFixed(0)}",
            ),
            _buildDetailRow("Method:", payment.method),
            _buildDetailRow("Status:", payment.status, isStatus: true),

            if (payment.type == PaymentType.match) ...[
              _buildDetailRow("League:", payment.leagueName),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                if (payment.type == PaymentType.league) ...[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showDetails = !_showDetails;
                      });
                    },
                    child: Text(
                      "View League Details",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ] else if (payment.type == PaymentType.match) ...[
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to match details
                    },
                    child: Text(
                      "View Match Details",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                GestureDetector(
                  onTap: () {
                    // TODO: Show/download receipt
                    _showReceipt(payment);
                  },
                  child: Text(
                    "View Receipt",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),

            // League details (expandable)
            if (_showDetails && payment.leagueDetails != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.leagueName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildLeagueDetailRow(
                      "Format:",
                      payment.leagueDetails!.format,
                    ),
                    _buildLeagueDetailRow(
                      "League Fee:",
                      "\$${payment.leagueDetails!.fee.toStringAsFixed(0)}",
                    ),
                    _buildLeagueDetailRow(
                      "Start Date:",
                      _formatDate(payment.leagueDetails!.startDate),
                    ),
                    _buildLeagueDetailRow(
                      "End Date:",
                      _formatDate(payment.leagueDetails!.endDate),
                    ),
                  ],
                ),
              ),
            ],

            // Match details for match payments
            if (payment.type == PaymentType.match &&
                payment.matchDetails != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.matchDetails!.teams,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatMatchTime(payment.matchDetails!.matchTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(value).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(value),
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeagueDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green.shade700;
      case 'pending':
        return Colors.orange.shade700;
      case 'failed':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _formatDate(DateTime dateTime) {
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

    return '${dateTime.day.toString().padLeft(2, '0')} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  String _formatMatchTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return "Today ${_formatTime(dateTime)}";
    } else if (difference.inDays == 1) {
      return "Tomorrow ${_formatTime(dateTime)}";
    } else if (difference.inDays > 1) {
      return "${difference.inDays} days ${_formatTime(dateTime)}";
    } else {
      return _formatDate(dateTime);
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $period PKT';
  }

  void _showReceipt(PaymentHistoryItem payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Receipt #${payment.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: \$${payment.amount.toStringAsFixed(2)}'),
            Text('Method: ${payment.method}'),
            Text('Status: ${payment.status}'),
            Text('Date: ${_formatDate(payment.date)}'),
            if (payment.type == PaymentType.league)
              Text('League: ${payment.leagueName}')
            else
              Text('Match: ${payment.matchDetails?.teams ?? 'N/A'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Download receipt
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Receipt downloaded')),
              );
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }
}

// Data models
enum PaymentType { league, match }

class PaymentHistoryItem {
  final String id;
  final DateTime date;
  final double amount;
  final String method;
  final String status;
  final PaymentType type;
  final String leagueName;
  final LeagueDetails? leagueDetails;
  final MatchDetails? matchDetails;

  PaymentHistoryItem({
    required this.id,
    required this.date,
    required this.amount,
    required this.method,
    required this.status,
    required this.type,
    required this.leagueName,
    this.leagueDetails,
    this.matchDetails,
  });
}

class LeagueDetails {
  final String format;
  final double fee;
  final DateTime startDate;
  final DateTime endDate;

  LeagueDetails({
    required this.format,
    required this.fee,
    required this.startDate,
    required this.endDate,
  });
}

class MatchDetails {
  final DateTime matchTime;
  final String teams;

  MatchDetails({required this.matchTime, required this.teams});
}

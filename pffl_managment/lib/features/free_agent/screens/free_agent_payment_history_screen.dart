import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/pending_payment_provider.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_league_selection/providers/league_selection_provider.dart';
import 'package:pffl_managment/core/services/league_service.dart'; // For LeagueModel if needed
import 'package:pffl_managment/core/services/payment_service.dart';
import 'package:pffl_managment/core/services/pdf_service.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class FreeAgentPaymentHistoryScreen extends StatefulWidget {
  const FreeAgentPaymentHistoryScreen({super.key});

  @override
  State<FreeAgentPaymentHistoryScreen> createState() =>
      _FreeAgentPaymentHistoryScreenState();
}

class _FreeAgentPaymentHistoryScreenState
    extends State<FreeAgentPaymentHistoryScreen> {
  bool _isLoading = false;
  List<FreeAgentPaymentHistoryItem> _payments = [];

  @override
  void initState() {
    super.initState();
    // Force reload pending payment to ensure fresh data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentHistory();
    });
  }

  Future<void> _loadPaymentHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pendingProvider = Provider.of<PendingPaymentProvider>(
        context,
        listen: false,
      );
      await pendingProvider.loadPendingPayment(context);

      _payments = [];

      // Add pending payment if exists
      if (pendingProvider.hasPendingPayment &&
          pendingProvider.pendingPayment != null) {
        final pending = pendingProvider.pendingPayment!;
        // Parse amount string "$200" -> 200.0
        double amount = 0.0;
        try {
          amount = double.parse(pending.amount.replaceAll('\$', '').trim());
        } catch (e) {
        }

        // Parse dates
        DateTime start = DateTime.now();
        DateTime end = DateTime.now();
        // Assuming format is "10 Dec 2025"
        // For now, let's just use current date or try to parse if robust parser available.
        // Or keep it simple for UI display as string in details.
        // Since PaymentHistoryItem expects DateTime, we might need to be careful.
        // Ideally PendingPaymentModel should store DateTime objects too.
        // For MVP, we'll just new DateTime() for dates if parsing is complex.

        _payments.add(
          FreeAgentPaymentHistoryItem(
            id: "PENDING",
            date: DateTime.now(),
            amount: amount,
            method: "Pending",
            status: "Pending",
            type: PaymentType.league,
            leagueName: pending.leagueName,
            leagueId: pending.leagueId, // Added field
            leagueDetails: LeagueDetails(
              format: pending.format,
              fee: amount,
              startDate: start, // Placeholder or parse real date
              endDate: end,
            ),
          ),
        );
      }

      // Fetch real paid history from PaymentService
      try {
        final paymentResponse = await PaymentService.fetchUserPayments();
        if (paymentResponse['success'] == true) {
          final paidPayments = paymentResponse['data'] as List<dynamic>? ?? [];
          for (final paymentData in paidPayments) {
            // Create PaymentHistoryItem from payment data
            final paymentDataMap = paymentData as Map<String, dynamic>;
            final payment = FreeAgentPaymentHistoryItem(
              id: paymentDataMap['_id'] ?? paymentDataMap['id'] ?? '',
              date:
                  DateTime.tryParse(paymentDataMap['createdAt'] ?? '') ??
                  DateTime.now(),
              amount: (paymentDataMap['amount'] ?? 0).toDouble(),
              method: paymentDataMap['paymentMethod'] ?? 'Unknown',
              status: paymentDataMap['status'] ?? 'unknown',
              type: PaymentType.league,
              leagueName: paymentDataMap['leagueName'] ?? 'Unknown League',
              leagueId: paymentDataMap['leagueId'],
            );
            if (payment.status.toLowerCase() == 'paid') {
              DateTime startDate = DateTime.now();
              DateTime endDate = DateTime.now();

              // Use league dates from payment object
              startDate = payment.leagueStartDate;
              endDate = payment.leagueEndDate;

              _payments.add(
                FreeAgentPaymentHistoryItem(
                  id: payment.id,
                  date: payment.createdAt,
                  amount: payment.amount,
                  method: payment.paymentMethod,
                  status: payment.status,
                  type: PaymentType.league,
                  leagueName: payment.leagueName,
                  leagueId: payment.leagueId,
                  leagueDetails: LeagueDetails(
                    format: payment.leagueFormat,
                    fee: payment.amount,
                    startDate: startDate,
                    endDate: endDate,
                  ),
                ),
              );
            }
          }
        }
      } catch (e) {
        // Continue without paid history
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
  final FreeAgentPaymentHistoryItem payment;

  const FreeAgentPaymentCard({super.key, required this.payment});

  @override
  State<FreeAgentPaymentCard> createState() => _FreeAgentPaymentCardState();
}

class _FreeAgentPaymentCardState extends State<FreeAgentPaymentCard> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;
    final isPending = payment.status.toLowerCase() == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                  isPending ? "Pending Payment" : "Payment #${payment.id}",
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
                      // Navigate to match details screen (to be implemented)
                      // Navigator.pushNamed(context, AppRoutes.matchDetails, arguments: payment.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Match details coming soon!'),
                        ),
                      );
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

                if (isPending)
                  ElevatedButton(
                    onPressed: () async {
                      // Handle Pay Now
                      if (payment.leagueId != null) {
                        // We need to set the selected league in LeagueSelectionProvider
                        // But LeagueSelectionProvider expects LeagueModel.
                        // We might need to fetch it or create a minimal one.
                        // Let's fetch it to be safe and correct.
                        try {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          final league = await LeagueService.getLeagueById(
                            payment.leagueId!,
                          );
                          Navigator.pop(context); // Close loader

                          if (league != null) {
                            // Map LeagueDetailModel to LeagueModel (simplified for provider)
                            // Or adjust provider to accept Detail.
                            // LeagueSelectionProvider list uses LeagueModel.
                            // Let's assume we can cast or convert.
                            // Actually LeagueDetailModel fields overlap with LeagueModel.

                            final leagueModel = LeagueModel(
                              id: league.id,
                              leagueName: league.leagueName,
                              format: league.format,
                              startDate: league.startDate,
                              endDate: league.endDate,
                              minimumPlayers: 0, // Not needed for payment
                              perPlayerLeagueFee: league.perPlayerLeagueFee,
                              status: 'open',
                              logo: null,
                            );

                            final leagueProvider =
                                Provider.of<LeagueSelectionProvider>(
                                  context,
                                  listen: false,
                                );
                            leagueProvider.clearAllSelections();
                            leagueProvider.selectLeague(
                              leagueModel,
                            ); // Select this league

                            Navigator.pushNamed(
                              context,
                              AppRoutes.freeAgentAddPaymentDetails,
                            );
                          }
                        } catch (e) {
                          Navigator.pop(context); // Close loader
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error loading league: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Pay Now'),
                  )
                else
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
                color: _getStatusColor(value).withValues(alpha: 0.1),
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

  void _showReceipt(FreeAgentPaymentHistoryItem payment) {
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
            onPressed: () async {
              Navigator.pop(context);
              try {
                await PdfService.generateAndShareReceipt(payment.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Receipt downloaded successfully!'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to download receipt: $e')),
                  );
                }
              }
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

class FreeAgentPaymentHistoryItem {
  final String id;
  final DateTime date;
  final double amount;
  final String method;
  final String status;
  final PaymentType type;
  final String leagueName;
  final String? leagueId; // Added for Pay Now
  final LeagueDetails? leagueDetails;
  final MatchDetails? matchDetails;

  FreeAgentPaymentHistoryItem({
    required this.id,
    required this.date,
    required this.amount,
    required this.method,
    required this.status,
    required this.type,
    required this.leagueName,
    this.leagueId,
    this.leagueDetails,
    this.matchDetails,
  });

  // Getters for compatibility
  DateTime get createdAt => date;
  String get paymentMethod => method;
  String get leagueFormat => leagueDetails?.format ?? 'Unknown';
  DateTime get leagueStartDate => leagueDetails?.startDate ?? DateTime.now();
  DateTime get leagueEndDate => leagueDetails?.endDate ?? DateTime.now();
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


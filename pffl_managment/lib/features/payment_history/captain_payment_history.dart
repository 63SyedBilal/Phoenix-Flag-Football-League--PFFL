import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/features/payment_history/providers/captain_payment_history_provider.dart';
import 'package:pffl_managment/features/payment_history/providers/player_payment_history_provider.dart';
import 'package:provider/provider.dart';

class CaptainPaymentHistory extends StatefulWidget {
  const CaptainPaymentHistory({super.key});

  @override
  State<CaptainPaymentHistory> createState() => _CaptainPaymentHistoryState();
}

class _CaptainPaymentHistoryState extends State<CaptainPaymentHistory> {
  final Map<int, bool> _expandedCards = {};

  @override
  void initState() {
    super.initState();
    // Load payment history when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CaptainPaymentHistoryProvider>().loadPaymentHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: ArrowBackButton()),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<CaptainPaymentHistoryProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading payment history',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadPaymentHistory(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            if (provider.payments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.payment, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No Team Payments',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No team members have made league payments yet.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Team Payment History',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Serotive",
                          color: Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track payments made by your team members.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Lato",
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Summary cards
                      _buildSummaryCard(provider),
                      const SizedBox(height: 24),
                      ...provider.payments.asMap().entries.map((entry) {
                        final index = entry.key;
                        final payment = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildPaymentCard(
                            index: index,
                            payment: payment,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                _buildBottomNav(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(CaptainPaymentHistoryProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Total Revenue',
                '\$${provider.totalTeamRevenue.toStringAsFixed(0)}',
                Colors.green,
              ),
              Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
              _buildSummaryItem(
                'Paid',
                '${provider.paidPaymentsCount}',
                Colors.green,
              ),
              Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
              _buildSummaryItem(
                'Pending',
                '${provider.pendingPaymentsCount}',
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildStatusRow(String label, String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'paid':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'failed':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard({
    required int index,
    required PaymentHistoryItem payment,
  }) {
    final isExpanded = _expandedCards[index] ?? false;

    return GestureDetector(
      onTap: () {
        if (isExpanded) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentReceiptScreen(payment: payment),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment #${payment.id.substring(payment.id.length - 6)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Lato",
                    color: Color(0xFF101828),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F173E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    payment.formattedDate,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Lato",
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Amount:', '\$${payment.amount}'),
            const SizedBox(height: 6),
            _buildInfoRow('Method:', payment.paymentMethod),
            const SizedBox(height: 6),
            _buildStatusRow('Status:', payment.status),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandedCards[index] = !isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'View League Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6A7282),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[400],
                    size: 24,
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: payment.leagueLogo != null
                        ? Image.network(
                            payment.leagueLogo!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.shield,
                              size: 16,
                              color: Colors.grey,
                            ),
                          )
                        : const Icon(
                            Icons.shield,
                            size: 16,
                            color: Colors.grey,
                          ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    payment.leagueName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Format:',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          payment.leagueFormat,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: const Color(0xFFE5E7EB),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'League Fee:',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${payment.amount}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: "Lato",
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Date:',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          payment.leagueStartDate,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: const Color(0xFFE5E7EB),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End Date:',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            payment.leagueEndDate,
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: "Lato",
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            _buildViewReceiptButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: 'Lato',
            color: Color(0xFF6A7282),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: 'Lato',
            color: Color(0xFF6A7282),
          ),
        ),
      ],
    );
  }

  Widget _buildViewReceiptButton() {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {},
          child: const Center(
            child: Text(
              'View Receipt',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: 'Lato',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? const Color(0xFF3B82F6) : Colors.grey[400],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? const Color(0xFF3B82F6) : Colors.grey[400],
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Payment Receipt Detail Screen
class PaymentReceiptScreen extends StatefulWidget {
  final PaymentHistoryItem payment;

  const PaymentReceiptScreen({super.key, required this.payment});

  @override
  State<PaymentReceiptScreen> createState() => _PaymentReceiptScreenState();
}

class _PaymentReceiptScreenState extends State<PaymentReceiptScreen> {
  bool _isLeagueExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Payment Receipt',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Serotiva',
                      color: Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Transaction details for your league payment.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Record #${widget.payment.id.substring(widget.payment.id.length - 6)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Lato',
                      color: Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Transaction ID:',
                    widget.payment.transactionId ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Date:', widget.payment.formattedDate),
                  const SizedBox(height: 12),
                  _buildDetailRow('League:', widget.payment.leagueName),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Total Amount:',
                    '\$${widget.payment.amount}',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Method:', widget.payment.paymentMethod),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Status:',
                    widget.payment.status,
                    statusColor: const Color(0xFF3B82F6),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLeagueExpanded = !_isLeagueExpanded;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'View League Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Lato',
                            color: Color(0xFF6A7282),
                          ),
                        ),
                        Icon(
                          _isLeagueExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                  if (_isLeagueExpanded) ...[
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: widget.payment.leagueLogo != null
                              ? Image.network(
                                  widget.payment.leagueLogo!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.shield,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                )
                              : const Icon(
                                  Icons.shield,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.payment.leagueName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Lato',
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Format:',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.payment.leagueFormat,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: const Color(0xFFE5E7EB),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'League Fee:',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${widget.payment.amount}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Date:',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.payment.leagueStartDate,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: const Color(0xFFE5E7EB),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'End Date:',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.payment.leagueEndDate,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildDownloadButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? statusColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: 'Lato',
              color: statusColor ?? const Color(0xFF6A7282),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: 'Lato',
              color: statusColor ?? const Color(0xFF6A7282),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadButton() {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {},
          child: const Center(
            child: Text(
              'Download Receipt',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: 'Lato',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

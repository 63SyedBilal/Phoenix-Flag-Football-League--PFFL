import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_setting_widgets/providers/payment_history_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentHistory extends StatelessWidget {
  const PaymentHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentHistoryProvider()..initialize(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading:ArrowBackButton()
        ),
        body: SafeArea(
          child: Consumer<PaymentHistoryProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && provider.payments.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Payment History',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Serotiva',
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Track all your league payments and receipts.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF2E2E2E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icons/home_icons/Group 2.svg',
                                    width: 20,
                                    height: 20,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.black,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    prefixIcon: Container(
                                      width: 20,
                                      height: 20,
                                      alignment: Alignment.center,
                                      child: SvgPicture.asset(
                                        'assets/icons/home_icons/searchrightIcon.svg',
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.contain,
                                        colorFilter: const ColorFilter.mode(
                                          Colors.grey,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    hintText: 'Search payments...',
                                    onChanged: (value) {
                                      provider.updateSearchQuery(value);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: DropdownButton<String?>(
                                      isExpanded: true,
                                      value: provider.selectedTeamId,
                                      hint: const Text('Select Teams'),
                                      underline: Container(),
                                      icon: SvgPicture.asset(
                                        'assets/icons/home_icons/arrowDounIcon.svg',
                                        width: 14,
                                        height: 14,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFF9CA3AF),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                          value: null,
                                          child: Text(
                                            'All Teams',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: provider.selectedTeamId == null
                                                  ? Colors.black
                                                  : const Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        ),
                                        ...provider.teams.map((team) {
                                          final teamId = team['_id']?.toString() ?? team['id']?.toString();
                                          final teamName = team['teamName'] as String? ?? 'Unknown Team';
                                          return DropdownMenuItem(
                                            value: teamId,
                                            child: Text(
                                              teamName,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: provider.selectedTeamId == teamId
                                                    ? Colors.black
                                                    : const Color(0xFF9CA3AF),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                      onChanged: (String? value) {
                                        provider.setSelectedTeam(value);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Tabs
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildTab(
                                    context,
                                    provider,
                                    'Completed Payments',
                                    0,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildTab(
                                    context,
                                    provider,
                                    'Pending Payments',
                                    1,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildTab(
                                    context,
                                    provider,
                                    'Refunded Payments',
                                    2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Payment Cards
                            if (provider.payments.isEmpty) ...[
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.payment_outlined,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No ${['Completed', 'Pending', 'Refunded'][provider.selectedTabIndex]} Payments',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'All your ${['completed', 'pending', 'refunded'][provider.selectedTabIndex]} payments will appear here',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              ...provider.payments.map((payment) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: _buildPaymentCard(
                                    context,
                                    payment,
                                    provider.selectedTabIndex,
                                  ),
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Navigation
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFFE5E7EB),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    PaymentHistoryProvider provider,
    String title,
    int index,
  ) {
    final isSelected = provider.selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        provider.setSelectedTab(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: isSelected ? 0.67 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    PaymentModel payment,
    int tabIndex,
  ) {
    if (tabIndex == 0) {
      return _buildCompletedPaymentCard(context, payment);
    } else if (tabIndex == 1) {
      return _buildPendingPaymentCard(context, payment);
    } else {
      return _buildRefundPaymentCard(context, payment);
    }
  }

  Widget _buildCompletedPaymentCard(
    BuildContext context,
    PaymentModel payment,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Record #${payment.recordNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F173E),
                  borderRadius: BorderRadius.circular(200),
                ),
                child: Text(
                  payment.date,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildDetailRow('Player:', payment.player),
          _buildDetailRow('Team:', payment.team),
          _buildDetailRow('League:', payment.league),
          _buildDetailRow('Amount:', payment.amount),
          _buildDetailRow('Method:', payment.method),
          Row(
            children: [
              const Text(
                'Status: ',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6A7282),
                  height: 1.625,
                ),
              ),
              const Text(
                'Completed',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF246300),
                  height: 1.625,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: const Text(
                  'View League Details',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6A7282)),
                ),
              ),
              SvgPicture.asset(
                'assets/icons/home_icons/arrowDounIcon.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF6A7282),
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'View Receipt',
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.paymentReceipt,
                arguments: {
                  'id': payment.id,
                  'recordNumber': payment.recordNumber,
                  'date': payment.date,
                  'player': payment.player,
                  'team': payment.team,
                  'league': payment.league,
                  'amount': payment.amount,
                  'method': payment.method,
                },
              );
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingPaymentCard(BuildContext context, PaymentModel payment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Record #${payment.recordNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F173E),
                  borderRadius: BorderRadius.circular(200),
                ),
                child: Text(
                  payment.date,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildDetailRow('Player:', payment.player),
          _buildDetailRow('Team:', payment.team),
          _buildDetailRow('League:', payment.league),
          _buildDetailRow('Amount:', payment.amount),
          _buildDetailRow('Method:', payment.method),
          Row(
            children: [
              const Text(
                'Status: ',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6A7282),
                  height: 1.625,
                ),
              ),
              Text(
                'Unpaid',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFFF51000),
                  height: 1.625,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: Colors.black),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: const Text(
                  'View League Details',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6A7282)),
                ),
              ),
              SvgPicture.asset(
                'assets/icons/home_icons/arrowDounIcon.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF6A7282),
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomButton(
            width: double.infinity,
            text: 'Send Reminder',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildRefundPaymentCard(BuildContext context, PaymentModel payment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              'Record #${payment.recordNumber}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
          ),
          const SizedBox(height: 4),
          if (payment.refundDate != null)
            _buildDetailRow('Refund Date:', payment.refundDate!),
          if (payment.transactionId != null)
            _buildDetailRow('Transaction ID:', payment.transactionId!),
          _buildDetailRow('Player:', payment.player),
          if (payment.refundReason != null)
            _buildDetailRow('Refund Reason:', payment.refundReason!),
          _buildDetailRow('Team:', payment.team),
          _buildDetailRow('League:', payment.league),
          _buildDetailRow('Amount Refunded:', payment.amount),
          _buildDetailRow('Method:', payment.method),
          Row(
            children: [
              const Text(
                'Status: ',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6A7282),
                  height: 1.625,
                ),
              ),
              const Text(
                'Refunded',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF246300),
                  height: 1.625,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomButton(
            fontSize: 14,
            text: 'Refund Details',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Refund Details'),
                    content: Text(
                      'Transaction ID: ${payment.transactionId ?? 'N/A'}\n'
                      'Refund Date: ${payment.refundDate ?? payment.date}\n'
                      'Amount: ${payment.amount}\n'
                      'Player: ${payment.player}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            width: double.infinity,
            height: 39,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6A7282),
                height: 1.625,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6A7282),
                height: 1.625,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/routes/app_routes.dart';




class PaymentHistory extends StatefulWidget {
  const PaymentHistory({Key? key}) : super(key: key);

  @override
  State<PaymentHistory> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistory> {
  int selectedTabIndex = 1; 
  int selectedBottomNavIndex = 4; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        
      ),
      body: SafeArea(
        child: Column(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                color: Colors.black,
                              ),
                            ),
                            child: Icon(
                              Icons.download_outlined,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                                            Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Search payments...',
                             ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Select Teams',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 18,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ],
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
                            _buildTab('Completed Payments', 0),
                            const SizedBox(width: 8),
                            _buildTab('Pending Payments', 1),
                            const SizedBox(width: 8),
                            _buildTab('Refends Payments', 2),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      
                      // Payment Cards
                      if (selectedTabIndex == 0) ...[
                        _buildCompletedPaymentCard(
                          recordNumber: '01',
                          date: '09 Dec 2025',
                          player: 'Alex Morgan',
                          team: 'Red Cobras',
                          league: 'Phoenix Winter 2025',
                          amount: '\$250',
                          method: 'Stripe',
                        ),
                        const SizedBox(height: 18),
                        _buildCompletedPaymentCard(
                          recordNumber: '02',
                          date: '10 Dec 2025',
                          player: 'John Smith',
                          team: 'Blue Eagles',
                          league: 'Phoenix Winter 2025',
                          amount: '\$200',
                          method: 'PayPal',
                        ),
                        const SizedBox(height: 18),
                        _buildCompletedPaymentCard(
                          recordNumber: '03',
                          date: '11 Dec 2025',
                          player: 'Sarah Johnson',
                          team: 'Green Hawks',
                          league: 'Phoenix Winter 2025',
                          amount: '\$300',
                          method: 'Credit Card',
                        ),
                      ] else if (selectedTabIndex == 1) ...[
                        _buildPendingPaymentCard(
                          recordNumber: '01',
                          date: '09 Dec 2025',
                          player: 'Alex Morgan',
                          team: 'Red Cobras',
                          league: 'Phoenix Winter 2025',
                          amount: '\$250',
                          method: 'Stripe',
                          status: 'Unpaid',
                          statusColor: const Color(0xFFF51000),
                        ),
                        const SizedBox(height: 18),
                        _buildPendingPaymentCard(
                          recordNumber: '01',
                          date: '09 Dec 2025',
                          player: 'Alex Morgan',
                          team: 'Red Cobras',
                          league: 'Phoenix Winter 2025',
                          amount: '\$250',
                          method: 'Stripe',
                          status: 'Unpaid',
                          statusColor: const Color(0xFFF51000),
                        ),
                      ] else if (selectedTabIndex == 2) ...[
                        _buildRefundPaymentCard(
                          recordNumber: '02',
                          refundDate: '12 Dec 2025',
                          transactionId: 'STRP-98234723',
                          player: 'Alex Morgan',
                          refundReason: 'Others',
                          team: 'Red Cobras',
                          league: 'Phoenix Winter 2025',
                          amount: '\$250',
                          method: 'Stripe',
                        ),
                        const SizedBox(height: 18),
                        _buildRefundPaymentCard(
                          recordNumber: '03',
                          refundDate: '13 Dec 2025',
                          transactionId: 'STRP-98234723',
                          player: 'Alex Morgan',
                          refundReason: 'Others',
                          team: 'Red Cobras',
                          league: 'Phoenix Winter 2025',
                          amount: '\$250',
                          method: 'Stripe',
                        ),
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
                    color: Colors.black,
                    width: 1,
                  ),
                ),
              ),
        
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.black,
            width: isSelected ? 0.67 : 1,
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

  Widget _buildCompletedPaymentCard({
    required String recordNumber,
    required String date,
    required String player,
    required String team,
    required String league,
    required String amount,
    required String method,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Record #$recordNumber',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101828),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F173E),
                  borderRadius: BorderRadius.circular(200),
                ),
                child: Text(
                  date,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildDetailRow('Player:', player),
          _buildDetailRow('Team:', team),
          _buildDetailRow('League:', league),
          _buildDetailRow('Amount:', amount),
          _buildDetailRow('Method:', method),
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
          Container(
            height: 1,
            color: Colors.black,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'View League Details',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6A7282),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: const Color(0xFF6A7282),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'View Receipt',
            onPressed: () {
              // Navigate to payment receipt screen
              Navigator.pushNamed(
                context,
                AppRoutes.paymentReceipt,
                arguments: {
                  'recordNumber': recordNumber,
                  'date': date,
                  'player': player,
                  'team': team,
                  'league': league,
                  'amount': amount,
                  'method': method,
                },
              );
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingPaymentCard({
    required String recordNumber,
    required String date,
    required String player,
    required String team,
    required String league,
    required String amount,
    required String method,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Record #$recordNumber',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101828),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F173E),
                  borderRadius: BorderRadius.circular(200),
                ),
                child: Text(
                  date,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildDetailRow('Player:', player),
          _buildDetailRow('Team:', team),
          _buildDetailRow('League:', league),
          _buildDetailRow('Amount:', amount),
          _buildDetailRow('Method:', method),
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
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  height: 1.625,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: Colors.black,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'View League Details',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6A7282),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: const Color(0xFF6A7282),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomButton(text: 'Send Reminder', onPressed: () {})
        ],
      ),
    );
  }

  Widget _buildRefundPaymentCard({
    required String recordNumber,
    required String refundDate,
    required String transactionId,
    required String player,
    required String refundReason,
    required String team,
    required String league,
    required String amount,
    required String method,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Record #$recordNumber',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 4),
          _buildDetailRow('Refund Date', refundDate),
          _buildDetailRow('Transaction ID:', transactionId),
          _buildDetailRow('Player:', player),
          _buildDetailRow('Refund Reason:', refundReason),
          _buildDetailRow('Team:', team),
          _buildDetailRow('League:', league),
          _buildDetailRow('Amount Refunded:', amount),
          _buildDetailRow('Method:', method),
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
          const SizedBox(height: 12),
          CustomButton(
            text: 'Refund Details',
            onPressed: () {
              // Show refund details dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Refund Details'),
                    content: const Text('This is a popup dialog showing refund details.'),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6A7282),
              height: 1.625,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6A7282),
              height: 1.625,
            ),
          ),
        ],
      ),
    );
  }
}

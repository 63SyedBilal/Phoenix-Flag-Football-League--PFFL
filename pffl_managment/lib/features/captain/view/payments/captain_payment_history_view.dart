import 'package:flutter/material.dart';

class CaptainPaymentHistoryView extends StatefulWidget {
  const CaptainPaymentHistoryView({Key? key}) : super(key: key);

  @override
  State<CaptainPaymentHistoryView> createState() => _CaptainPaymentHistoryViewState();
}

class _CaptainPaymentHistoryViewState extends State<CaptainPaymentHistoryView> {
  int selectedTabIndex = 0;

  // Sample data for demonstration
  final List<Map<String, dynamic>> completedPayments = [
    {
      'id': 'PMT-001',
      'date': 'Dec 15, 2025',
      'league': 'Summer Championship League',
      'team': 'Red Dragons',
      'amount': '\$250.00',
      'method': 'Stripe',
      'status': 'Completed',
    },
    {
      'id': 'PMT-002',
      'date': 'Nov 28, 2025',
      'league': 'Fall Tournament Series',
      'team': 'Red Dragons',
      'amount': '\$200.00',
      'method': 'PayPal',
      'status': 'Completed',
    },
    {
      'id': 'PMT-003',
      'date': 'Oct 10, 2025',
      'league': 'Autumn League',
      'team': 'Red Dragons',
      'amount': '\$300.00',
      'method': 'Credit Card',
      'status': 'Completed',
    },
  ];

  final List<Map<String, dynamic>> pendingPayments = [
    {
      'id': 'PMT-004',
      'date': 'Jan 5, 2026',
      'league': 'Winter Elite League',
      'team': 'Red Dragons',
      'amount': '\$350.00',
      'method': 'Stripe',
      'status': 'Pending',
    },
    {
      'id': 'PMT-005',
      'date': 'Feb 12, 2026',
      'league': 'Spring Championship',
      'team': 'Red Dragons',
      'amount': '\$275.00',
      'method': 'Bank Transfer',
      'status': 'Pending',
    },
  ];

  final List<Map<String, dynamic>> refundedPayments = [
    {
      'id': 'PMT-006',
      'date': 'Sep 22, 2025',
      'league': 'Regional Tournament',
      'team': 'Red Dragons',
      'amount': '\$150.00',
      'method': 'Stripe',
      'status': 'Refunded',
      'refundDate': 'Sep 25, 2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Payment History'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment History',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'View and manage all your team payments',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search payments...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Leagues'),
                      selected: true,
                      onSelected: (bool selected) {},
                      backgroundColor: Colors.grey[200],
                      selectedColor: const Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('This Year'),
                      selected: false,
                      onSelected: (bool selected) {},
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('High Amount'),
                      selected: false,
                      onSelected: (bool selected) {},
                      backgroundColor: Colors.grey[200],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTab('Completed', 0),
                    _buildTab('Pending', 1),
                    _buildTab('Refunded', 2),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Payment list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildPaymentList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentList() {
    List<Map<String, dynamic>> payments;
    
    switch (selectedTabIndex) {
      case 0:
        payments = completedPayments;
        break;
      case 1:
        payments = pendingPayments;
        break;
      case 2:
        payments = refundedPayments;
        break;
      default:
        payments = completedPayments;
    }
    
    if (payments.isEmpty) {
      return Center(
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
              'No ${['Completed', 'Pending', 'Refunded'][selectedTabIndex]} Payments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All your ${['completed', 'pending', 'refunded'][selectedTabIndex]} payments will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return _buildPaymentCard(payment);
      },
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with ID and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  payment['id'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(payment['status']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    payment['status'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Payment details
            _buildDetailRow('Date', payment['date']),
            _buildDetailRow('League', payment['league']),
            _buildDetailRow('Team', payment['team']),
            _buildDetailRow('Amount', payment['amount'], isAmount: true),
            _buildDetailRow('Method', payment['method']),
            
            if (payment.containsKey('refundDate'))
              _buildDetailRow('Refund Date', payment['refundDate']),
            
            const SizedBox(height: 16),
            
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // View payment details
                  _showPaymentDetails(payment);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  selectedTabIndex == 0 
                    ? 'View Receipt' 
                    : selectedTabIndex == 1 
                      ? 'Pay Now' 
                      : 'View Refund Details',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
              color: isAmount ? const Color(0xFF0F172A) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Payment Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Payment info
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    size: 48,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Details
              _buildDetailRow('Payment ID', payment['id']),
              _buildDetailRow('Date', payment['date']),
              _buildDetailRow('League', payment['league']),
              _buildDetailRow('Team', payment['team']),
              _buildDetailRow('Amount', payment['amount'], isAmount: true),
              _buildDetailRow('Method', payment['method']),
              _buildDetailRow('Status', payment['status']),
              
              if (payment.containsKey('refundDate'))
                _buildDetailRow('Refund Date', payment['refundDate']),
              
              const SizedBox(height: 20),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Handle primary action based on status
                        if (payment['status'] == 'Completed') {
                          // Download receipt
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Receipt downloaded')),
                          );
                        } else if (payment['status'] == 'Pending') {
                          // Process payment
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing payment...')),
                          );
                        } else if (payment['status'] == 'Refunded') {
                          // Show refund details
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Refund details displayed')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        payment['status'] == 'Completed' 
                          ? 'Download Receipt' 
                          : payment['status'] == 'Pending' 
                            ? 'Pay Now' 
                            : 'Refund Info',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
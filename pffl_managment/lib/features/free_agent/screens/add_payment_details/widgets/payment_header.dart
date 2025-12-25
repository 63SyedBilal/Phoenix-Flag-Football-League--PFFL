import 'package:flutter/material.dart';

class PaymentHeader extends StatelessWidget {
  const PaymentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Payment',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF000000),
            fontFamily: "Lato",
          ),
        ),
        const Text(
          'Details',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF000000),
            fontFamily: "Lato",
            height: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Enter your card information below to\ncomplete the payment securely.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
            fontFamily: "Lato",
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

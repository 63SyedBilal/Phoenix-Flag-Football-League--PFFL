import 'package:flutter/material.dart';

class TotalAmountDisplay extends StatelessWidget {
  final double amount;

  const TotalAmountDisplay({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Amount',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF000000),
              fontFamily: "Lato",
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF000000),
              fontFamily: "Lato",
            ),
          ),
        ],
      ),
    );
  }
}

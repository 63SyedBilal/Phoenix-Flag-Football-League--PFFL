import 'package:flutter/material.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class ProceedButton extends StatelessWidget {
  final bool isEnabled;
  final int selectedCount;

  const ProceedButton({
    super.key,
    required this.isEnabled,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: isEnabled
              ? () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.freeAgentPaymentOption,
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F173E),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            disabledBackgroundColor: const Color(0xFF94A3B8),
          ),
          child: const Text(
            'Proceed to Payment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

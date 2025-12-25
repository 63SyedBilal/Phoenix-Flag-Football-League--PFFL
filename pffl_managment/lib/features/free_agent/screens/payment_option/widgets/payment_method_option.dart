import 'package:flutter/material.dart';

class PaymentMethodOption extends StatelessWidget {
  final String type;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodOption({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Row(
          children: [
            if (type == 'paypal')
              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/b/b5/PayPal.svg',
                width: 60,
                height: 20,
                errorBuilder: (_, __, ___) => const Text(
                  'PayPal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF003087),
                    fontFamily: "Lato",
                  ),
                ),
              )
            else
              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/b/ba/Stripe_Logo%2C_revised_2016.svg',
                width: 50,
                height: 20,
                errorBuilder: (_, __, ___) => const Text(
                  'stripe',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF635BFF),
                    fontFamily: "Lato",
                  ),
                ),
              ),
            const Spacer(),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFFD1D5DB),
                  width: isSelected ? 2 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

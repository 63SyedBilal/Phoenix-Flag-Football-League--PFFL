import 'package:flutter/material.dart';

class PayNowButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const PayNowButton({super.key, required this.isLoading, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F173E), // Dark navy from image/theme
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Pill shape as in image
        ),
        elevation: 0,
        disabledBackgroundColor: const Color(0xFF0F173E).withValues(alpha: 0.6),
      ),
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Pay Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: "Lato",
              ),
            ),
    );
  }
}

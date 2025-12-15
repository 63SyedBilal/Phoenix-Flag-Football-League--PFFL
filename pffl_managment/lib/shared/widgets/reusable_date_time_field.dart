import 'package:flutter/material.dart';

class ReusableDateTimeField extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPlaceholder;

  const ReusableDateTimeField({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isPlaceholder
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF374151),
                fontSize: 14,
              ),
            ),
            Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }
}

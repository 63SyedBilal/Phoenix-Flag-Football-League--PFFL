import 'package:flutter/material.dart';
import 'package:pffl_managment/features/auth/screens/widgets/error_container.dart';

class PaymentTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? error;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final bool isObscureText;

  const PaymentTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.error,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.isObscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
            fontFamily: "Lato",
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: isObscureText,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1F2937),
            fontFamily: "Lato",
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: "Lato",
              fontWeight: FontWeight.w400,
            ),
            filled: true,

            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: suffixIcon,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          ErrorContainer(message: error!),
        ],
      ],
    );
  }
}

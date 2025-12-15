import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';

class TextWithTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;

  const TextWithTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Removed the label text widget
        CustomTextField(
          controller: controller,
          hintText: hintText,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          suffixIcon: suffixIcon,
        ),
      ],
    );
  }
}

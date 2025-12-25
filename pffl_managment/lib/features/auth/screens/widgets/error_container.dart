import 'package:flutter/material.dart';
import 'package:pffl_managment/core/utils/svg_icons.dart';

class ErrorContainer extends StatelessWidget {
  final String message;

  const ErrorContainer({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgIcons.infoFill(size: 16, color: Colors.red),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Colors.red, fontSize: 10),
          ),
        ),
      ],
    );
  }
}

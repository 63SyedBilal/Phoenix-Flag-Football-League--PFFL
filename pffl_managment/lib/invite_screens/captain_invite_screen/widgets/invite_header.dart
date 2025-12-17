import 'package:flutter/material.dart';

/// Header widget with back button
class InviteHeader extends StatelessWidget {
  const InviteHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';

/// Title section widget
class InviteTitle extends StatelessWidget {
  const InviteTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Invite Players',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF000000),
          ),
        ),

        Text(
          'Add or invite new players to complete your team roster.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: "Lato",
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class SkipButton extends StatelessWidget {
  const SkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/free-agent/dashboard',
            (route) => false,
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Skip',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
                fontFamily: "Lato",
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 20, color: Color(0xFF000000)),
          ],
        ),
      ),
    );
  }
}

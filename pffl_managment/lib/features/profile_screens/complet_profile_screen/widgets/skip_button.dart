import 'package:flutter/material.dart';
import 'package:pffl_managment/routes/app_routes.dart';

/// Skip button widget for navigating to dashboard
class SkipButton extends StatelessWidget {
  const SkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.playerDashboard,
            (route) => false,
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Skip for now',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward, size: 16, color: Colors.grey[700]),
          ],
        ),
      ),
    );
  }
}


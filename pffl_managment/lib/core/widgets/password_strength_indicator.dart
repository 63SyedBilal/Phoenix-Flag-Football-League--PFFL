import 'package:flutter/material.dart';
import 'package:pffl_managment/features/auth/models/signup_state.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';

/// Widget to display password strength indicator
class PasswordStrengthIndicator extends StatelessWidget {
  final PasswordStrength strength;
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.strength,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    // Get strength properties
    final strengthData = _getStrengthData(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: strengthData['progress'] as double,
            backgroundColor: AppColors.borderLight,
            minHeight: 4,
            valueColor: AlwaysStoppedAnimation<Color>(
              strengthData['color'] as Color,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Strength text
        Text(
          strengthData['text'] as String,
          style: theme.textTheme.bodySmall?.copyWith(
            color: strengthData['color'] as Color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getStrengthData(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return {'progress': 0.33, 'color': Colors.red, 'text': 'Weak'};
      case PasswordStrength.medium:
        return {'progress': 0.66, 'color': Colors.orange, 'text': 'Medium'};
      case PasswordStrength.strong:
        return {'progress': 1.0, 'color': AppColors.success, 'text': 'Strong'};
    }
  }
}

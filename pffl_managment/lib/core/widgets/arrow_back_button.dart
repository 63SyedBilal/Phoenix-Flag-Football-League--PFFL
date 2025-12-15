import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';

class ArrowBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ArrowBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDarkMode ? Colors.black : AppColors.circleColor,
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: onPressed ?? () => Navigator.pop(context),
        ),
      ),
    );
  }
}

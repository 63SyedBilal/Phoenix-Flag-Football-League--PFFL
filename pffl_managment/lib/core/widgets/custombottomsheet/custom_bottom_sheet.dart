import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';

class CustomBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final Widget content;

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onButtonPressed,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.only(top: 34, left: 16, right: 16, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header section with title
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.subtitleColor,
            ),
          ),
          const SizedBox(height: 20),
          
          // Content area
          content,
          const SizedBox(height: 20),
          
          // Action button
          CustomButton.primary(
            text: buttonText,
            onPressed: onButtonPressed,
          ),
        ],
      ),
    );
  }
}

// Helper function to show the custom bottom sheet
Future<void> showCustomBottomSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String buttonText,
  required VoidCallback onButtonPressed,
  required Widget content,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return CustomBottomSheet(
        title: title,
        subtitle: subtitle,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
        content: content,
      );
    },
  );
}
import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/custombottomsheet/custom_bottom_sheet.dart';

/// Helper function to show a custom bottom sheet
void showCustomBottomSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String buttonText,
  required VoidCallback onButtonPressed,
  required Widget content,
  IconData? icon,
}) {
  showModalBottomSheet(
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
        icon: icon,
      );
    },
  );
}
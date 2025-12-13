import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String message;
  final String? positiveButtonText;
  final String? negativeButtonText;
  final VoidCallback? onPositiveButtonPressed;
  final VoidCallback? onNegativeButtonPressed;
  final bool isDestructiveDialog;
  final Widget? content;

  const CustomDialog({
    super.key,
    required this.message,
    this.positiveButtonText,
    this.negativeButtonText,
    this.onPositiveButtonPressed,
    this.onNegativeButtonPressed,
    this.isDestructiveDialog = false,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Widget> actions = [];

    if (negativeButtonText != null && onNegativeButtonPressed != null) {
      actions.add(
        TextButton(
          onPressed: onNegativeButtonPressed,
          child: Text(
            negativeButtonText!,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isDestructiveDialog
                  ? (theme.brightness == Brightness.light
                        ? Colors.red
                        : Colors.red.shade300)
                  : theme.primaryColor,
            ),
          ),
        ),
      );
    }

    // Add positive button if provided
    if (positiveButtonText != null && onPositiveButtonPressed != null) {
      actions.add(
        TextButton(
          onPressed: onPositiveButtonPressed,
          child: Text(
            positiveButtonText!,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isDestructiveDialog
                  ? (theme.brightness == Brightness.light
                        ? Colors.red
                        : Colors.red.shade300)
                  : theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content:
          content ??
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(message, style: theme.textTheme.bodyMedium),
          ),
      actions: actions,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      backgroundColor: Colors.white,
    );
  }
}

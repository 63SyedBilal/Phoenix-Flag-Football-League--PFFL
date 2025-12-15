import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/core/providers/base_provider.dart';

class CustomErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final bool showRetryButton;

  const CustomErrorWidget({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'An error occurred while loading the content',
    this.onRetry,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    // Get the base provider instance (listen: false since we only need it for the callback)
    final baseProvider = Provider.of<BaseProvider>(context, listen: false);
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Icon(
              Icons.error_outline,
              size: 60,
              color: theme.brightness == Brightness.light 
                  ? Colors.red.shade300 
                  : Colors.red.shade700,
            ),
            const SizedBox(height: 16),

            // Error Title
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Error Message
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Retry Button
            if (showRetryButton && onRetry != null)
              CustomButton(
                text: 'Retry',
                onPressed: () {
                  baseProvider.clearMessages();
                  onRetry!();
                },
                width: 150,
                backgroundColor: theme.brightness == Brightness.light 
                    ? Colors.red.shade300 
                    : Colors.red.shade700,
              ),
          ],
        ),
      ),
    );
  }
}
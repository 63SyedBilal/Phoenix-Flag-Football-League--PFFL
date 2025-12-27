import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';

/// Dialog widget for displaying user positions throughout the app
/// Shows positions in a clean, readable format with the app's color scheme
class PositionDisplayDialog extends StatelessWidget {
  final List<String> positions;
  final String title;

  const PositionDisplayDialog({
    super.key,
    required this.positions,
    this.title = 'Player Positions',
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F173E),
              ),
            ),
            const SizedBox(height: 16),

            // Positions
            if (positions.isEmpty)
              Text(
                'No positions selected',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: positions.map((position) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F173E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      position,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),

            // Close button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF0F173E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Static method to show the dialog
  static void show(
    BuildContext context, {
    required List<String> positions,
    String title = 'Player Positions',
  }) {
    showDialog(
      context: context,
      builder: (context) =>
          PositionDisplayDialog(positions: positions, title: title),
    );
  }
}

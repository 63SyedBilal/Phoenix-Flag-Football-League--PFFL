import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';

/// Widget for selecting multiple positions with visual feedback
/// Selected positions are highlighted with the specified color (#0F173E)
class MultiplePositionSelector extends StatelessWidget {
  final List<String> availablePositions;
  final List<String> selectedPositions;
  final Function(String) onPositionToggle;
  final String? errorText;

  const MultiplePositionSelector({
    super.key,
    required this.availablePositions,
    required this.selectedPositions,
    required this.onPositionToggle,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Position chips
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: availablePositions.map((position) {
            final isSelected = selectedPositions.contains(position);
            return GestureDetector(
              onTap: () => onPositionToggle(position),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0F173E)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0F173E)
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  position,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Selected positions display
        if (selectedPositions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Positions:',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedPositions.join(', '),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF0F173E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Error text
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart';

/// Position dropdown widget
class PositionDropdown extends StatelessWidget {
  const PositionDropdown({super.key});

  static const List<String> positions = [
    'Center',
    'Blocker',
    'Receiver',
    'Slot',
    'QB',
    'Star QB',
    'Rusher',
    'LB',
    'Corner',
    'Safety',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<CompleteProfileProvider>(
      builder: (context, provider, _) {
        final hasError = provider.fieldErrors['position'] != null;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Positions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: provider.togglePositionDropdown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasError
                        ? Colors.red
                        : const Color(0xFFE5E7EB),
                    width: hasError ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        provider.positionsDisplayText,
                        style: TextStyle(
                          fontSize: 14,
                          color: provider.selectedPositions.isNotEmpty
                              ? const Color(0xFF000000)
                              : Colors.grey[400],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      provider.showPositionDropdown
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
            if (provider.showPositionDropdown) _buildDropdown(provider),
            if (hasError) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  provider.fieldErrors['position']!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDropdown(CompleteProfileProvider provider) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: positions.length,
        itemBuilder: (context, index) {
          final position = positions[index];
          final isSelected = provider.isPositionSelected(position);
          
          return InkWell(
            onTap: () => provider.togglePosition(position),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.white,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => provider.togglePosition(position),
                      activeColor: Colors.white,
                      checkColor: const Color(0xFF0F172A),
                      side: BorderSide(
                        color: isSelected ? Colors.white : Colors.grey[400]!,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      position,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF000000),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


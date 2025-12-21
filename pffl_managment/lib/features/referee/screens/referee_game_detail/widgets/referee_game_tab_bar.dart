import 'package:flutter/material.dart';

class RefereeGameTabBar extends StatelessWidget {
  const RefereeGameTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _RefereeTabButton(
            label: 'Game actions',
            isSelected: selectedIndex == 0,
            onTap: () => onTabSelected(0),
          ),
          const SizedBox(width: 8),
          _RefereeTabButton(
            label: 'Mark Attendance',
            isSelected: selectedIndex == 1,
            onTap: () => onTabSelected(1),
          ),
          const SizedBox(width: 8),
          _RefereeTabButton(
            label: 'Select Players',
            isSelected: selectedIndex == 2,
            onTap: () => onTabSelected(2),
          ),
        ],
      ),
    );
  }
}

class _RefereeTabButton extends StatelessWidget {
  const _RefereeTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A5F) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A5F) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

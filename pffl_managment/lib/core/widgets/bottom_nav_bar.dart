import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/admin_navigation_provider.dart';
import 'package:provider/provider.dart';

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminNavigationProvider>(
      builder: (context, viewModel, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.black.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NavItem(
                    icon: Icons.home,
                    label: 'Home',
                    isActive: viewModel.selectedIndex == 0,
                    onTap: () => viewModel.setIndex(0),
                  ),
                  NavItem(
                    icon: Icons.emoji_events,
                    label: 'Leagues',
                    isActive: viewModel.selectedIndex == 1,
                    onTap: () => viewModel.setIndex(1),
                  ),
                  NavItem(
                    icon: Icons.calendar_today,
                    label: 'Games',
                    isActive: viewModel.selectedIndex == 2,
                    onTap: () => viewModel.setIndex(2),
                  ),
                  NavItem(
                    icon: Icons.people,
                    label: 'Users',
                    isActive: viewModel.selectedIndex == 3,
                    onTap: () => viewModel.setIndex(3),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFF111827),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                color: isActive
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/admin_navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/svg_icons.dart';

class AdminBottomNevigation extends StatelessWidget {
  const AdminBottomNevigation({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<AdminNavigationProvider>(
      builder: (context, viewModel, child) {
        return Container(
          decoration: BoxDecoration(
            color: theme.bottomAppBarTheme.color ?? theme.cardColor,
            border: Border(
              top: BorderSide(color: colorScheme.outlineVariant, width: 1),
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
                    svgIcon: SvgIcons.homeunselected(size: 24),
                    svgIconSelected: SvgIcons.homeFilled(size: 24),
                    label: 'Home',
                    isActive: viewModel.selectedIndex == 0,
                    onTap: () => viewModel.setIndex(0),
                  ),
                  NavItem(
                    svgIcon: SvgIcons.leagues(size: 24),
                    svgIconSelected: SvgIcons.leaguesFilled(size: 24),
                    label: 'Leagues',
                    isActive: viewModel.selectedIndex == 1,
                    onTap: () => viewModel.setIndex(1),
                  ),
                  NavItem(
                    svgIcon: SvgIcons.games(size: 24),
                    svgIconSelected: SvgIcons.gamesFilled(size: 24),
                    label: 'Games',
                    isActive: viewModel.selectedIndex == 2,
                    onTap: () => viewModel.setIndex(2),
                  ),
                  NavItem(
                    svgIcon: SvgIcons.users(size: 24),
                    svgIconSelected: SvgIcons.usersFilled(size: 24),
                    label: 'Users',
                    isActive: viewModel.selectedIndex == 3,
                    onTap: () => viewModel.setIndex(3),
                  ),
                  NavItem(
                    svgIcon: SvgIcons.setting(size: 24),
                    svgIconSelected: SvgIcons.settingFilled(size: 24),
                    label: 'Settings',
                    isActive: viewModel.selectedIndex == 4,
                    onTap: () => viewModel.setIndex(4),
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
  final Widget svgIcon;
  final Widget svgIconSelected;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.svgIcon,
    required this.svgIconSelected,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Use different icons for selected vs unselected states
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              isActive
                  ? const Color(0xFF3B82F6) // Use #3B82F6 for selected items
                  : colorScheme.onSurface,
              BlendMode.srcIn,
            ),
            child: isActive ? svgIconSelected : svgIcon,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              color: isActive
                  ? const Color(0xFF3B82F6) // Use #3B82F6 for selected items
                  : colorScheme.onSurface, // Theme-appropriate text color
            ),
          ),
        ],
      ),
    );
  }
}

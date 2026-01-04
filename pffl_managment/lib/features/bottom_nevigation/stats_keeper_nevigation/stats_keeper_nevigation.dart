import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/svg_icons.dart';
import 'package:pffl_managment/core/providers/bottom_nevigation_provider/stat_keeper_navigation_provider.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_add/stat_add_screen.dart';

class StatsKeeperNevigation extends StatelessWidget {
  const StatsKeeperNevigation({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<StatKeeperNavigationProvider>(
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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NavItem(
                    svgIcon: SvgIcons.home(size: 20),
                    svgIconSelected: SvgIcons.homeFilled(size: 20),
                    label: 'Home',
                    isActive: viewModel.selectedIndex == 0,
                    onTap: () => viewModel.setIndex(0),
                  ),
                  NavItem(
                    svgIcon: SvgIcons.games(size: 20),
                    svgIconSelected: SvgIcons.gamesFilled(size: 20),
                    label: 'Games',
                    isActive: viewModel.selectedIndex == 1,
                    onTap: () => viewModel.setIndex(1),
                  ),
                  NavItem(
                    svgIcon: SvgIcons.add(size: 20),
                    svgIconSelected: SvgIcons.addFilled(size: 20),
                    label: 'Add',
                    isActive: viewModel.selectedIndex == 2,
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ),
                              child: Material(child: StatAddScreen()),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  NavItem(
                    svgIcon: SvgIcons.leagues(size: 20),
                    svgIconSelected: SvgIcons.leaguesFilled(size: 20),
                    label: 'Stats',
                    isActive: viewModel.selectedIndex == 3,
                    onTap: () => viewModel.setIndex(3),
                  ),
                  NavItem(
                    svgIcon: SvgIcons.setting(size: 20),
                    svgIconSelected: SvgIcons.settingFilled(size: 20),
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
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

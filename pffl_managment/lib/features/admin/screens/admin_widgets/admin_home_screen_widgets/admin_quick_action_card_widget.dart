import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/models/quick_action_model.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class AdminQuickActionCardWidget extends StatelessWidget {
  final QuickActionModel action;
  final bool isBlurred;

  const AdminQuickActionCardWidget({
    super.key,
    required this.action,
    this.isBlurred = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget iconWidget;
    String lowerTitle = action.title.toLowerCase();

    if (lowerTitle.contains('create') && lowerTitle.contains('league')) {
      iconWidget = SvgPicture.asset(
        'assets/icons/home_icons/BlackplusIcon.svg',
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Color(0xFF111827), BlendMode.srcIn),
      );
    } else if (lowerTitle.contains('schedule') && lowerTitle.contains('game')) {
      iconWidget = SvgPicture.asset(
        'assets/icons/home_icons/dateVectorIcon.svg',
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Color(0xFF111827), BlendMode.srcIn),
      );
    } else if (lowerTitle.contains('view') && lowerTitle.contains('schedule')) {
      iconWidget = SvgPicture.asset(
        'assets/icons/home_icons/dateShadowIcon.svg',
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Color(0xFF111827), BlendMode.srcIn),
      );
    } else if (lowerTitle.contains('view') && lowerTitle.contains('stat')) {
      iconWidget = SvgPicture.asset(
        'assets/icons/home_icons/StatsshadowIcon.svg',
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Color(0xFF111827), BlendMode.srcIn),
      );
    } else if (lowerTitle.contains('manage') && lowerTitle.contains('stat')) {
      iconWidget = SvgPicture.asset(
        'assets/icons/home_icons/dateShadowIcon.svg', // Using the same icon as stats for manage stats
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Color(0xFF111827), BlendMode.srcIn),
      );
    } else if (lowerTitle.contains('view') && lowerTitle.contains('report')) {
      iconWidget = SvgPicture.asset(
        'assets/icons/home_icons/StatsshadowIcon.svg', // Using the same icon as stats for reports
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Color(0xFF111827), BlendMode.srcIn),
      );
    } else {
      // Fallback to the original icon if title doesn't match
      iconWidget = Icon(action.icon, size: 24, color: const Color(0xFF111827));
    }

    return InkWell(
      onTap: isBlurred
          ? null
          : () {
              if (action.title == 'Create League') {
                Navigator.pushNamed(context, AppRoutes.adminCreateLeague);
              } else {
                action.onTap();
              }
            },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shadowColor: Colors.transparent,
        child: ImageFiltered(
          imageFilter: isBlurred
              ? ImageFilter.blur(sigmaX: 1.8, sigmaY: 1.8)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconWidget,
                const SizedBox(height: 10),
                Text(
                  action.title,
                  textAlign: TextAlign.center,
                  style: action.title == 'Create League'
                      ? AppTextStyles.labelSmall.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        )
                      : AppTextStyles.labelSmall.copyWith(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

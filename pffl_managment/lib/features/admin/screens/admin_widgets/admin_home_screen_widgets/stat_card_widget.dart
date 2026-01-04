import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/models/stat_card_model.dart';

class StatCardWidget extends StatelessWidget {
  final StatCardModel stat;

  const StatCardWidget({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget iconWidget;
    if (stat.title.toLowerCase().contains('league')) {
      iconWidget = SvgPicture.asset(
        'assets/icons/home_icons/trophyIcon.svg',
        width: 14,
        height: 14,
        colorFilter: ColorFilter.mode(stat.iconColor, BlendMode.srcIn),
      );
    } else if (stat.title.toLowerCase().contains('game')) {
      iconWidget = SvgPicture.asset(
        'assets/icons/home_icons/bluehomedateIcon.svg',
        width: 14,
        height: 14,
        colorFilter: ColorFilter.mode(stat.iconColor, BlendMode.srcIn),
      );
    } else if (stat.title.toLowerCase().contains('user')) {
      iconWidget = SvgPicture.asset(
        'assets/icons/home_icons/redManIcon.svg',
        width: 14,
        height: 14,
        colorFilter: ColorFilter.mode(stat.iconColor, BlendMode.srcIn),
      );
    } else if (stat.title.toLowerCase().contains('payment')) {
      iconWidget = SvgPicture.asset(
        'assets/icons/home_icons/dollarIcon.svg',
        width: 14,
        height: 14,
        colorFilter: ColorFilter.mode(stat.iconColor, BlendMode.srcIn),
      );
    } else {
      // Fallback to the original icon if title doesn't match
      iconWidget = Icon(stat.icon, size: 16, color: stat.iconColor);
    }

    return Card(
      shadowColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: stat.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            stat.title,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Lato',
                            ),
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: iconWidget),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stat.value,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Lato',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat.subtitle,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Lato',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

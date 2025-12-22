import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/models/stat_card_model.dart';

class StatCardWidget extends StatelessWidget {
  final StatCardModel stat;

  const StatCardWidget({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      shadowColor: Colors.transparent,
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
                          style: AppTextStyles.labelLarge,
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                           color: const Color(0xFFFBFBFB),
                         // color: AppColors.circleColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(stat.icon, size: 16, color: stat.iconColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stat.value,
                    style: AppTextStyles.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.subtitle,
                    style: AppTextStyles.labelSmall,
                    
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
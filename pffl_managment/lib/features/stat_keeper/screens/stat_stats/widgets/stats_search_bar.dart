import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StatsSearchBar extends StatelessWidget {
  final String? searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterTap;

  const StatsSearchBar({
    super.key,
    this.searchQuery,
    this.onSearchChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by name here',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: Color(0xFF000000),
                fontSize: 14,
              ),
              suffixIcon: const Icon(
                Icons.search,
                 color: Color(0xFF000000),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onFilterTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderLight, width: 1),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/filtterIcon.svg',
                colorFilter: ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
                width: 18,
                height: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
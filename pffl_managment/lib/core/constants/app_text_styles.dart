import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';

class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 48.0,
    fontWeight: FontWeight.w700,
    color: AppColors.lightTextPrimary,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 40.0,
    fontWeight: FontWeight.w700,
    color: AppColors.lightTextPrimary,
    height: 1.1,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 36.0,
    fontWeight: FontWeight.w700,
    color: AppColors.lightTextPrimary,
    height: 1.1,
  );

  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    color: AppColors.lightTextPrimary,
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
    height: 1.2,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    color: AppColors.lightTextPrimary,
    height: 1.2,
  );

  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
    height: 1.3,
  );
  //enter league information below to create a new tournament./
  static final TextStyle titleSmall = TextStyle(
    fontFamily: 'Lato',
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: Colors.brown[500],
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Lato',
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    color: AppColors.lightTextPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Lato',
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.darkAppBarBackground,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Lato',
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextSecondary,
    height: 1.4,
  );

  // Label styles //labels/image pic field title
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Lato',
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.lightTextPrimary,
    height: 1.2,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Lato',
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.lightTextPrimary,
    height: 1.2,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Lato',
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryColor,
    height: 1.2,
  );

  // Custom styles for specific use cases
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Lato',
    fontSize: 10.0,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextSecondary,
    height: 1.2,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: 'Lato',
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    color: AppColors.lightTextSecondary,
    height: 1.2,
    letterSpacing: 1.5,
  );

  // Dark theme variants - Updated to use dark colors for better contrast on white cards
  static const TextStyle displayLargeDark = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 48.0,
    fontWeight: FontWeight.w700,
    color: AppColors
        .lightTextPrimary, // Using light text primary (black) for better contrast on white cards
    height: 1.1,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMediumDark = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 40.0,
    fontWeight: FontWeight.w700,
    color: AppColors
        .lightTextPrimary, // Using light text primary (black) for better contrast on white cards
    height: 1.1,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmallDark = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 36.0,
    fontWeight: FontWeight.w700,
    color: AppColors
        .lightTextPrimary, // Using light text primary (black) for better contrast on white cards
    height: 1.1,
  );

  static const TextStyle headlineLargeDark = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    color: AppColors
        .lightTextPrimary, // Using light text primary (black) for better contrast on white cards
    height: 1.2,
  );

  static const TextStyle headlineMediumDark = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
    color: AppColors
        .lightTextPrimary, // Using light text primary (black) for better contrast on white cards
    height: 1.2,
  );

  static const TextStyle headlineSmallDark = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    color: AppColors
        .lightTextPrimary, // Using light text primary (black) for better contrast on white cards
    height: 1.2,
  );

  static const TextStyle titleLargeDark = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: AppColors
        .lightTextPrimary, // Using light text primary (black) for better contrast on white cards
    height: 1.3,
  );

  static const TextStyle titleMediumDark = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors
        .lightTextPrimary, // Using light text primary (black) for better contrast on white cards
    height: 1.3,
  );

  static const TextStyle titleSmallDark = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors
        .lightTextSecondary, // Using light text secondary (dark gray) for better contrast on white cards
    height: 1.3,
  );

  static const TextStyle bodyLargeDark = TextStyle(
    fontFamily: 'Lato',
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors
        .lightTextPrimary, // Using light text primary (black) for better contrast on white cards
    height: 1.5,
  );

  static const TextStyle bodyMediumDark = TextStyle(
    fontFamily: 'Lato',
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors
        .lightTextPrimary, // Using light text primary (black) for better contrast on white cards
    height: 1.4,
  );

  static const TextStyle bodySmallDark = TextStyle(
    fontFamily: 'Lato',
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors
        .lightTextSecondary, // Using light text secondary (dark gray) for better contrast on white cards
    height: 1.4,
  );

  static const TextStyle labelLargeDark = TextStyle(
    fontFamily: 'Lato',
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors
        .lightTextPrimary, // Using light text primary (black) for better contrast on white cards
    height: 1.2,
  );

  static const TextStyle labelMediumDark = TextStyle(
    fontFamily: 'Lato',
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors
        .lightTextPrimary, // Using light text primary (black) for better contrast on white cards
    height: 1.2,
  );

  static const TextStyle labelSmallDark = TextStyle(
    fontFamily: 'Lato',
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors
        .lightTextPrimary, // Using light text primary (black) for better contrast on white cards
    height: 1.2,
  );

  static const TextStyle buttonLargeDark = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle buttonMediumDark = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle buttonSmallDark = TextStyle(
    fontFamily: 'Serotiva',
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle captionDark = TextStyle(
    fontFamily: 'Lato',
    fontSize: 10.0,
    fontWeight: FontWeight.normal,
    color: AppColors
        .lightTextSecondary, // Using light text secondary (dark gray) for better contrast on white cards
    height: 1.2,
  );

  static const TextStyle overlineDark = TextStyle(
    fontFamily: 'Lato',
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    color: AppColors
        .lightTextSecondary, // Using light text secondary (dark gray) for better contrast on white cards
    height: 1.2,
    letterSpacing: 1.5,
  );
}

import 'dart:ui';
import 'package:flutter/material.dart';
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
                Icon(action.icon, size: 24, color: colorScheme.onSurface),
                const SizedBox(height: 10),
                Text(
                  action.title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class StatCardModel {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;

  StatCardModel({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.onTap,
  });

  StatCardModel copyWith({
    String? title,
    String? value,
    String? subtitle,
    IconData? icon,
    Color? iconColor,
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    return StatCardModel(
      title: title ?? this.title,
      value: value ?? this.value,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      onTap: onTap ?? this.onTap,
    );
  }
}

import 'package:flutter/material.dart';

class QuickActionModel {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  QuickActionModel({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

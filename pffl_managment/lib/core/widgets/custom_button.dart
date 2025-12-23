import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool isLoading;
  final IconData? icon;
  final BorderSide? border;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.isLoading = false,
    this.icon,
    this.border,
  });

  factory CustomButton.primary({
    Key? key,
    required String text,
    required VoidCallback onPressed,
    double? width,
    double? height,
    bool isLoading = false,
    IconData? icon,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      backgroundColor: const Color(0xFF0D1A42),
      textColor: Colors.white,
      width: width,
      height: height,
      isLoading: isLoading,
      icon: icon,
    );
  }

  factory CustomButton.secondary({
    Key? key,
    required String text,
    required VoidCallback onPressed,
    double? width,
    double? height,
    bool isLoading = false,
    IconData? icon,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      width: width,
      height: height,
      isLoading: isLoading,
      icon: icon,
      border: BorderSide(color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      height: height ?? 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.primaryColor,
          foregroundColor: textColor ?? Colors.white,
          side: border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  textColor ?? Colors.white,
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: textColor ?? Colors.white,
                        size: fontSize != null ? fontSize! + 2 : 18,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.buttonMedium.copyWith(color: textColor),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class RightAlignedButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;

  const RightAlignedButton({
    super.key,
    required this.text,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 120,
          height: 58,
          decoration: ShapeDecoration(
            color:
                backgroundColor ??
                (theme.brightness == Brightness.light
                    ? const Color(0xFFE7EAEB)
                    : const Color(0xFF2E2E2E)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  color:
                      textColor ??
                      (theme.brightness == Brightness.light
                          ? const Color(0x662E2E2E)
                          : Colors.white70),
                  fontSize: 16,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Transform.translate(
                offset: const Offset(0.0, 1.5),
                child: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color:
                      textColor ??
                      (theme.brightness == Brightness.light
                          ? Colors.black
                          : Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

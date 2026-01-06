import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:pffl_managment/core/services/url_launcher_service.dart';

class TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String? error;

  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: const Color(0xFF0F173E),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: 'I agree to ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                    fontFamily: "Lato",
                  ),
                  children: [
                    TextSpan(
                      text: 'Terms & Privacy',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () =>
                            UrlLauncherService.launchPrivacyPolicy(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 10,
              fontFamily: "Lato",
            ),
          ),
        ],
      ],
    );
  }
}

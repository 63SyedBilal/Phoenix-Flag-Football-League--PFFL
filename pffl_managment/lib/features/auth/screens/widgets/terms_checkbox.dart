import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:pffl_managment/features/auth/providers/signup_provider.dart';
import 'package:pffl_managment/features/auth/screens/widgets/error_container.dart';
import 'package:pffl_managment/core/services/url_launcher_service.dart';

class TermsCheckbox extends StatelessWidget {
  final SignupProvider provider;
  const TermsCheckbox({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: provider.agreedToTerms,
              onChanged: (value) =>
                  provider.updateAgreedToTerms(value ?? false),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),

            Expanded(
              child: RichText(
                text: TextSpan(
                  text: 'I Agree to ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white70
                        : AppColors.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
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
        if (provider.agreementError != null)
          ErrorContainer(message: provider.agreementError!),
      ],
    );
  }
}

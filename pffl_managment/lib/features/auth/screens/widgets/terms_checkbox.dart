import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_colors.dart';
import 'package:pffl_managment/features/auth/providers/signup_provider.dart';
import 'package:pffl_managment/features/auth/screens/widgets/error_container.dart';

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
              child: GestureDetector(
                onTap: () =>
                    provider.updateAgreedToTerms(!provider.agreedToTerms),
                child: Text(
                  'I Agree to Terms & Privacy',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white70
                        : AppColors.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
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

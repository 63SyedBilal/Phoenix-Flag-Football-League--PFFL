import 'package:flutter/material.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:pffl_managment/core/widgets/improved_phone_field.dart';
import 'package:pffl_managment/features/auth/providers/signup_provider.dart';
import 'package:pffl_managment/features/auth/screens/widgets/error_container.dart';

class PhoneNumberField extends StatelessWidget {
  final SignupProvider provider;

  const PhoneNumberField({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone Number', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        ImprovedPhoneField(
          onInputChanged: (PhoneNumber number) {
            provider.updatePhoneNumber(number);
          },
          onInputValidated: (bool value) {},
          initialCountryCode: 'US',
          hintText: 'Enter phone number',
          errorText: null,
        ),
        if (provider.phoneError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: ErrorContainer(message: provider.phoneError!),
          ),
      ],
    );
  }
}

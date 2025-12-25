import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/features/auth/providers/signup_provider.dart';
import 'package:pffl_managment/features/auth/screens/widgets/error_container.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final SignupProvider provider;

  const EmailField({
    super.key,
    required this.controller,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email Address', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          hintText: 'e.g john@example.com',
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => provider.updateEmail(value),
        ),
        if (provider.emailError != null)
          ErrorContainer(message: provider.emailError!),
      ],
    );
  }
}

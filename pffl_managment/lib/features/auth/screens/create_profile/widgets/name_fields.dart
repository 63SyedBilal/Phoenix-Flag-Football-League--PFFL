import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/features/auth/providers/signup_provider.dart';
import 'package:pffl_managment/features/auth/screens/widgets/error_container.dart';

class NameFields extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final SignupProvider provider;

  const NameFields({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('First Name', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              CustomTextField(
                controller: firstNameController,
                hintText: 'e.g John',
                onChanged: (value) => provider.updateFirstName(value),
              ),
              if (provider.firstNameError != null)
                ErrorContainer(message: provider.firstNameError!),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last Name', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              CustomTextField(
                controller: lastNameController,
                hintText: 'e.g Doe',
                onChanged: (value) => provider.updateLastName(value),
              ),
              if (provider.lastNameError != null)
                ErrorContainer(message: provider.lastNameError!),
            ],
          ),
        ),
      ],
    );
  }
}

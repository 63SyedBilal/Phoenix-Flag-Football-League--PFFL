import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/core/widgets/custom_button.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'providers/change_password_provider.dart';

class SharedChangePassowrd extends StatelessWidget {
  const SharedChangePassowrd({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChangePasswordProvider(),
      child: _SharedChangePasswordContent(),
    );
  }
}

class _SharedChangePasswordContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ChangePasswordProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: ArrowBackButton(onPressed: () => Navigator.pop(context)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Change Password",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Update your password to keep your account secure.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 25),

              // Current Password
              Text(
                "Current Password",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: provider.currentPasswordController,
                hintText: "Enter your current password",
                obscureText: provider.obscureCurrent,
                suffixIcon: IconButton(
                  icon: Icon(
                    provider.obscureCurrent
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.black54,
                    size: 20,
                  ),
                  onPressed: () => provider.toggleObscureCurrent(),
                ),
              ),
              const SizedBox(height: 18),

              // New Password
              Text(
                "New Password",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: provider.newPasswordController,
                hintText: "Create a new password (min 6 characters)",
                obscureText: provider.obscureNew,
                suffixIcon: IconButton(
                  icon: Icon(
                    provider.obscureNew
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.black54,
                    size: 20,
                  ),
                  onPressed: () => provider.toggleObscureNew(),
                ),
              ),
              const SizedBox(height: 18),

              // Confirm Password
              Text(
                "Confirm New Password",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: provider.confirmPasswordController,
                hintText: "Re-enter new password",
                obscureText: provider.obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    provider.obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.black54,
                    size: 20,
                  ),
                  onPressed: () => provider.toggleObscureConfirm(),
                ),
              ),
              const SizedBox(height: 30),

              // Save Button
              CustomButton(
                width: double.infinity,
                text: provider.isLoading ? 'Saving...' : 'Save Changes',
                isLoading: provider.isLoading,
                onPressed: () {
                  provider.handleSave(context);
                },
                textColor: Colors.white,
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

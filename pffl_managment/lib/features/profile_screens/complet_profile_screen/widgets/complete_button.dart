import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/widgets/custom_flushbar.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart';

/// Complete profile submission button widget
class CompleteButton extends StatelessWidget {
  const CompleteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompleteProfileProvider>(
      builder: (context, provider, _) {
        final isEnabled = !provider.isLoading && provider.isFormValid;

        return Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: isEnabled
                ? const Color(0xFF0F172A)
                : const Color(0xFF0F172A).withOpacity(0.5),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(26),
              onTap: !provider.isLoading
                  ? () async {
                      if (!provider.isFormValid) {
                        // Trigger validation to show error messages
                        provider.submitProfile();
                        if (context.mounted) {
                          CustomFlushbar.showError(
                            context,
                            message:
                                'Please fill all fields and upload a profile image',
                          );
                        }
                        return;
                      }

                      final success = await provider.submitProfile();
                      // Navigation is now handled by the SuccessBottomSheet after clicking 'Continue'
                      if (!success && context.mounted) {
                        // Show error from provider if submission fails (including upload failure)
                        CustomFlushbar.showError(
                          context,
                          message:
                              provider.errorMessage ??
                              'Failed to complete profile. Please check your connection and image.',
                        );
                      }
                    }
                  : null,
              child: Center(
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Complete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

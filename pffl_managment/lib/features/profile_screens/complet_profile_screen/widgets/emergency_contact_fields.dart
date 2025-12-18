import 'package:flutter/material.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/widgets/improved_phone_field.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart';

/// Emergency contact name and phone fields widget
class EmergencyContactFields extends StatelessWidget {
  const EmergencyContactFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompleteProfileProvider>(
      builder: (context, provider, _) {
        final nameError = provider.fieldErrors['emergencyContactName'];
        final phoneError = provider.fieldErrors['emergencyPhone'];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Name Field
            const Text(
              'Emergency Contact Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: provider.setEmergencyContactName,
              decoration: InputDecoration(
                hintText: 'e.g Tyler',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: nameError != null ? Colors.red : const Color(0xFFE5E7EB),
                    width: nameError != null ? 1.5 : 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: nameError != null ? Colors.red : const Color(0xFFE5E7EB),
                    width: nameError != null ? 1.5 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: nameError != null ? Colors.red : const Color(0xFF3B82F6),
                    width: nameError != null ? 1.5 : 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            if (nameError != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  nameError,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    height: 1.0,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Phone Field
            const Text(
              'Emergency Phone Number',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 8),
            ImprovedPhoneField(
              onInputChanged: (PhoneNumber number) {
                String fullNumber;
                if (number.completeNumber.isNotEmpty) {
                  fullNumber = number.completeNumber;
                } else if (number.number.isNotEmpty) {
                  fullNumber = '${number.countryCode}${number.number}';
                } else {
                  fullNumber = number.countryCode;
                }
                provider.setEmergencyPhone(fullNumber);
              },
              onInputValidated: (bool isValid) {
                // Validation handled in provider
              },
              initialCountryCode: 'US',
              hintText: 'Enter phone number',
              errorText: phoneError,
            ),
          ],
        );
      },
    );
  }
}


import 'package:flutter/material.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/widgets/improved_phone_field.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart';

/// Emergency contact name and phone fields widget
/// Uses same styling as Create Account screen for consistency
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
            // Contact Name Field - same styling as Create Account
            Text('Emergency Contact Name', style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Lato',
              color: Color(0xFF000000),
            )),
            const SizedBox(height: 8),
            TextField(
              onChanged: provider.setEmergencyContactName,
              style: const TextStyle(
                fontSize: 12, // Reduced font size for text inside the field
              ),
              decoration: InputDecoration(
                hintText: 'e.g Tyler',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: nameError != null ? Colors.red : const Color(0xFFE5E7EB),
                    width: nameError != null ? 1.5 : 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: nameError != null ? Colors.red : const Color(0xFFE5E7EB),
                    width: nameError != null ? 1.5 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: nameError != null ? Colors.red : const Color(0xFF3B82F6),
                    width: nameError != null ? 1.5 : 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
            if (nameError != null) ...[
              const SizedBox(height: 6),
              Text(
                nameError,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Phone Field - EXACT same as Create Account screen
            Text('Emergency Phone Number', style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Lato',
              color: Color(0xFF000000),
            )),
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
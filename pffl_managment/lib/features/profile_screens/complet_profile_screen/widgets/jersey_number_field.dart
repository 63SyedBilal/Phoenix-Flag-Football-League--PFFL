import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/profile_screens/complet_profile_screen/providers/complete_profile_provider.dart';

/// Jersey number input field widget
class JerseyNumberField extends StatelessWidget {
  const JerseyNumberField({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompleteProfileProvider>(
      builder: (context, provider, _) {
        final hasError = provider.fieldErrors['jerseyNumber'] != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jersey Number',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: provider.setJerseyNumber,
              decoration: InputDecoration(
                hintText: '17',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: hasError ? Colors.red : const Color(0xFFE5E7EB),
                    width: hasError ? 1.5 : 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: hasError ? Colors.red : const Color(0xFFE5E7EB),
                    width: hasError ? 1.5 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: hasError ? Colors.red : const Color(0xFF3B82F6),
                    width: hasError ? 1.5 : 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  provider.fieldErrors['jerseyNumber']!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}


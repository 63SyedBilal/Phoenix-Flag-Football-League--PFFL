import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/captain/screens/captain_create_team/providers/create_team_provider.dart';

/// Team name input field widget
class TeamNameField extends StatelessWidget {
  const TeamNameField({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateTeamProvider>(
      builder: (context, provider, _) {
        final hasError = provider.fieldErrors['teamName'] != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Team Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: provider.setTeamName,
              decoration: InputDecoration(
                hintText: 'e.g Star Eleven',
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
                  provider.fieldErrors['teamName']!,
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

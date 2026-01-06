import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/captain/screens/captain_create_team/providers/create_team_provider.dart';

/// Skill level dropdown widget
class SkillLevelDropdown extends StatelessWidget {
  const SkillLevelDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateTeamProvider>(
      builder: (context, provider, _) {
        final hasError = provider.fieldErrors['skillLevel'] != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Skill level',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: provider.toggleSkillDropdown,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasError ? Colors.red : const Color(0xFFE5E7EB),
                    width: hasError ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.skillLevel ?? 'e.g recreational',
                      style: TextStyle(
                        fontSize: 14,
                        color: provider.skillLevel != null
                            ? const Color(0xFF000000)
                            : Colors.grey[400],
                      ),
                    ),
                    Icon(
                      provider.showSkillDropdown
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
            if (provider.showSkillDropdown) _buildDropdown(provider),
            if (hasError) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  provider.fieldErrors['skillLevel']!,
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

  Widget _buildDropdown(CreateTeamProvider provider) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: CreateTeamProvider.skillLevels.map((skill) {
          final isSelected = provider.skillLevel == skill;
          return InkWell(
            onTap: () => provider.setSkillLevel(skill),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: CreateTeamProvider.skillLevels.indexOf(skill) == 0
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      )
                    : CreateTeamProvider.skillLevels.indexOf(skill) ==
                          CreateTeamProvider.skillLevels.length - 1
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      )
                    : BorderRadius.zero,
              ),
              child: Text(
                skill,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF000000),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

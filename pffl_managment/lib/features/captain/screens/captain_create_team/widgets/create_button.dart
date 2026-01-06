import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/captain/screens/captain_create_team/providers/create_team_provider.dart';

/// Create team button widget
class CreateButton extends StatelessWidget {
  const CreateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateTeamProvider>(
      builder: (context, provider, _) {
        return Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: provider.isFormValid
                ? const Color(0xFF0F172A)
                : Colors.grey[400],
            borderRadius: BorderRadius.circular(26),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(26),
              onTap: provider.isFormValid && !provider.isLoading
                  ? () => provider.submitTeam()
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
                        'Create Team',
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

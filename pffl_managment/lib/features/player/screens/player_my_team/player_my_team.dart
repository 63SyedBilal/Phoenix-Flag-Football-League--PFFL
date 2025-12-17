import 'package:flutter/material.dart';
import 'package:pffl_managment/features/captain/view/teams/widgets/player_list_item.dart';
import 'package:pffl_managment/features/captain/view/teams/widgets/team_info_section.dart';
import 'package:pffl_managment/features/player/providers/player_team_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';

class PlayerMyTeam extends StatelessWidget {
  const PlayerMyTeam({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlayerTeamProvider(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer2<PlayerTeamProvider, AuthProvider>(
            builder: (context, provider, authProvider, child) {
              // Load team data when userId is available and not already loading/loaded
              if (authProvider.userId.isNotEmpty &&
                  !provider.isLoading &&
                  provider.team == null &&
                  provider.errorMessage == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  provider.loadTeamData(userId: authProvider.userId);
                });
              }

              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Show error state if there's an error
              if (provider.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              provider.refresh(userId: authProvider.userId),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Show empty state if no team found
              final team = provider.team;
              if (team == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'You haven\'t joined any team yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Accept a team invitation from your notifications to join a team.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Show team data
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TeamInfoSection(
                      team: team,
                      selectedFormat: provider.selectedFormat,
                      onFormatChanged: (format) => provider.setFormat(format),
                    ),
                    const SizedBox(height: 24),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: team.players.length,
                      itemBuilder: (context, index) {
                        return PlayerListItem(player: team.players[index]);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

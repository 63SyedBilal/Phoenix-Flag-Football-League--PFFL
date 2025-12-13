import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/captain_team_provider.dart';
import 'widgets/player_list_item.dart';
import 'widgets/team_info_section.dart';

class TeamManagementScreen extends StatelessWidget {
  const TeamManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CaptainTeamProvider(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer<CaptainTeamProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final team = provider.team;
              if (team == null) {
                return const Center(child: Text('Failed to load team data'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TeamInfoSection(team: team),
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

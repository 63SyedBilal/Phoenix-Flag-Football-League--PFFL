import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_card_widget.dart';
import 'package:pffl_managment/features/admin/models/leagues_models/league_creation_model.dart';
import 'package:pffl_managment/features/admin/leagues/providers/enhanced_leagues_provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';
import 'package:provider/provider.dart';

class AdminLeaguesScreen extends StatelessWidget {
  const AdminLeaguesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Hardcoded existing leagues
    final existingLeagues = [
      LeagueCreationModel(
        id: '1',
        leagueName: 'Phoenix Winter 2025',
        teamLogo: '',
        selectedPlayerIds: [],
        captainId: '',
        registrationFee: 250,
        createdAt: DateTime.now(),
        status: 'Active',
        format: '5v5',
        startDate: DateTime(2025, 12, 10),
        endDate: DateTime(2026, 2, 25),
      ),
      LeagueCreationModel(
        id: '2',
        leagueName: 'Champions Cup 2025',
        teamLogo: '',
        selectedPlayerIds: [],
        captainId: '',
        registrationFee: 250,
        createdAt: DateTime.now(),
        status: 'Active',
        format: '5v5',
        startDate: DateTime(2025, 12, 10),
        endDate: DateTime(2026, 2, 25),
      ),
      LeagueCreationModel(
        id: '3',
        leagueName: 'Phoenix Winter 2025',
        teamLogo: '',
        selectedPlayerIds: [],
        captainId: '',
        registrationFee: 250,
        createdAt: DateTime.now(),
        status: 'Active',
        format: '5v5',
        startDate: DateTime(2025, 12, 10),
        endDate: DateTime(2026, 2, 25),
      ),
      LeagueCreationModel(
        id: '4',
        leagueName: 'Phoenix Winter 2025',
        teamLogo: '',
        selectedPlayerIds: [],
        captainId: '',
        registrationFee: 250,
        createdAt: DateTime.now(),
        status: 'Pending',
        format: '5v5',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 25),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Consumer<EnhancedLeaguesProvider>(
          builder: (context, provider, child) {
            final allLeagues = [...existingLeagues, ...provider.createdLeagues];
            
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        ...allLeagues.map(
                          (league) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: LeagueCardWidget(
                              league: league,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.adminLeagueDetail,
                                  arguments: league,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

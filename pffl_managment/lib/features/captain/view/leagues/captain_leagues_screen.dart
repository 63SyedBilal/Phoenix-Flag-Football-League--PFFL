import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/screens/admin_widgets/admin_leagues_widgets/league_card_widget.dart';
import 'package:pffl_managment/features/captain/providers/captain_leagues_provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class CaptainLeaguesScreen extends StatelessWidget {
  const CaptainLeaguesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CaptainLeaguesProvider(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer<CaptainLeaguesProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          ...provider.leagues.map(
                            (league) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: LeagueCardWidget(
                                league: league,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.captainLeagueDetail,
                                    arguments: league,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
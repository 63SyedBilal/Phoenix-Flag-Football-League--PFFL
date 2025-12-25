import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_league_selection/providers/league_selection_provider.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_league_selection/widgets/header_section.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_league_selection/widgets/empty_leagues_state.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_league_selection/widgets/league_card.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_league_selection/widgets/proceed_button.dart';
import 'package:pffl_managment/features/free_agent/screens/free_agent_league_selection/widgets/skip_button.dart';

class LeagueSelectionScreen extends StatefulWidget {
  const LeagueSelectionScreen({super.key});

  @override
  State<LeagueSelectionScreen> createState() => _LeagueSelectionScreenState();
}

class _LeagueSelectionScreenState extends State<LeagueSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LeagueSelectionProvider>().fetchAllLeagues();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: ArrowBackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Consumer<LeagueSelectionProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeaderSection(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Select League',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Lato",
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (provider.totalCount > 0)
                        Text(
                          '${provider.selectedCount}/${provider.totalCount}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: "Lato",
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: provider.availableLeagues.isEmpty
                        ? const EmptyLeaguesState()
                        : ListView.builder(
                            itemCount: provider.availableLeagues.length,
                            itemBuilder: (context, index) {
                              final league = provider.availableLeagues[index];
                              return LeagueCard(
                                league: league,
                                isSelected: provider.isLeagueSelected(league),
                                onSelect: () =>
                                    provider.toggleLeagueSelection(league),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 20),
                  ProceedButton(
                    isEnabled: provider.selectedCount > 0,
                    selectedCount: provider.selectedCount,
                  ),
                  const SkipButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

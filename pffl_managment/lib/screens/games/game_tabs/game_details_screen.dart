import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/screens/games/game_tabs/game_tabs_provider.dart';
import 'package:pffl_managment/screens/games/game_tabs/tabs/leaderboard_tab.dart';
import 'package:pffl_managment/screens/games/game_tabs/tabs/officials_tab.dart';
import 'package:pffl_managment/screens/games/game_tabs/tabs/players_tab.dart';
import 'package:pffl_managment/screens/games/game_tabs/tabs/stats_tab.dart';
import 'package:pffl_managment/screens/games/game_tabs/tabs/summary_tab.dart';

class GameDetailsScreen extends StatelessWidget {
  final MatchModel match;

  const GameDetailsScreen({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameTabsProvider(match: match)..initialize(),
      child: const _GameDetailsContent(),
    );
  }
}

class _GameDetailsContent extends StatelessWidget {
  const _GameDetailsContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameTabsProvider>(context);
    final match = provider.match;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,

        leading: ArrowBackButton(),

        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Score Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTeamHeader(match.homeTeam, match.homeTeamLogo, true),
                _buildScore(match),
                _buildTeamHeader(match.awayTeam, match.awayTeamLogo, false),
              ],
            ),
          ),

          // Custom Tab Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTabButton(context, 0, "Summary"),
                _buildTabButton(context, 1, "Leaderboard"),
                _buildTabButton(context, 2, "Players"),
                _buildTabButton(context, 3, "Officials"),
                _buildTabButton(context, 4, "Stats"),
              ],
            ),
          ),

          // Tab Content
          Expanded(child: _buildCurrentTab(provider.selectedTabIndex)),
        ],
      ),
    );
  }

  Widget _buildCurrentTab(int index) {
    switch (index) {
      case 0:
        return const SummaryTab();
      case 1:
        return const LeaderboardTab();
      case 2:
        return const PlayersTab();
      case 3:
        return const OfficialsTab();
      case 4:
        return const StatsTab();
      default:
        return const SummaryTab();
    }
  }

  Widget _buildTabButton(BuildContext context, int index, String text) {
    final provider = Provider.of<GameTabsProvider>(context);
    final isSelected = provider.selectedTabIndex == index;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () => provider.setTabIndex(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF374151),
              fontWeight: FontWeight.w500,
              fontSize: 14,
              fontFamily: 'Lato',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamHeader(String name, String logo, bool isHome) {
    // Shorten name if needed or just logo for the score header part?
    // Image shows Logo + Name acronym (e.g. BS, STA)
    // I'll assume valid short names or just use truncated
    String shortName = name.length > 3
        ? name.substring(0, 3).toUpperCase()
        : name.toUpperCase();
    if (shortName == "HOME TEAM") shortName = "BS"; // Match image stub
    if (shortName == "AWAY TEAM") shortName = "STA";

    return Row(
      children: isHome
          ? [
              _buildLogo(logo),
              const SizedBox(width: 8),
              Text(
                shortName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,

                  fontFamily: 'Lato',
                ),
              ),
            ]
          : [
        const SizedBox(width: 8),
        _buildLogo(logo),
              Text(
                shortName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFamily: 'Lato',
                ),
              ),

            ],
    );
  }

  Widget _buildLogo(String url) {
    return Container(
      width: 40,
      height: 40,
      child: Image.network(
        url,
        errorBuilder: (c, e, s) =>
            const Icon(Icons.shield, size: 30, color: Colors.grey),
      ),
    );
  }

  Widget _buildScore(MatchModel match) {
    // Mock score if null
    final home = match.homeScore ?? 30;
    final away = match.awayScore ?? 27;

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: 'Lato',
        ),
        children: [
          TextSpan(text: "$home"),
          TextSpan(
            text: " \\ ",
            style: TextStyle(color: Colors.grey.shade300),
          ),
          TextSpan(
            text: "$away",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

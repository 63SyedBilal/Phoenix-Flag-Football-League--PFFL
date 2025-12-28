import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/widgets/simple_dropdown_list.dart';
import 'package:pffl_managment/features/stat_keeper/providers/approved_stats_provider.dart';

class ApprovedStatsScreen extends StatelessWidget {
  const ApprovedStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ApprovedStatsProvider()..loadApprovedStats(),
      child: const _ApprovedStatsContent(),
    );
  }
}

class _ApprovedStatsContent extends StatelessWidget {
  const _ApprovedStatsContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Approved Stats'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Consumer<ApprovedStatsProvider>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: provider.isLoading ? null : provider.refreshStats,
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              );
            },
          ),
        ],
      ),
      body: Consumer<ApprovedStatsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.approvedStats.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading approved stats',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.refreshStats,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.approvedStats.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Approved Stats Found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Stats will appear here once they are approved by the admin.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter by League',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SimpleDropdownList(
                      selectedValue: provider.selectedFilter,
                      items: provider.availableLeagues,
                      onSelected: provider.setLeagueFilter,
                      hintText: 'Select League',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Showing ${provider.filteredStats.length} approved stats',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Stats List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Group by Player
                    ...provider.statsByPlayer.entries.map((entry) {
                      final playerKey = entry.key;
                      final playerStats = entry.value;
                      final totals = provider.calculatePlayerTotals(playerKey);

                      return _PlayerStatsCard(
                        playerKey: playerKey,
                        playerStats: playerStats,
                        totals: totals,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlayerStatsCard extends StatefulWidget {
  final String playerKey;
  final List<ApprovedStatModel> playerStats;
  final Map<String, int> totals;

  const _PlayerStatsCard({
    required this.playerKey,
    required this.playerStats,
    required this.totals,
  });

  @override
  State<_PlayerStatsCard> createState() => _PlayerStatsCardState();
}

class _PlayerStatsCardState extends State<_PlayerStatsCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Player Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.playerKey,
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.playerStats.length} approved stat entries',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Total Stats Summary
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _StatChip(
                        label: 'TDs',
                        value: widget.totals['touchdowns'] ?? 0,
                        color: Colors.green,
                      ),
                      _StatChip(
                        label: 'Catches',
                        value: widget.totals['catches'] ?? 0,
                        color: Colors.blue,
                      ),
                      _StatChip(
                        label: 'Catch Yds',
                        value: widget.totals['catchYards'] ?? 0,
                        color: Colors.purple,
                      ),
                      _StatChip(
                        label: 'Rush Yds',
                        value: widget.totals['rushYards'] ?? 0,
                        color: Colors.orange,
                      ),
                      _StatChip(
                        label: 'Pass Yds',
                        value: widget.totals['passYards'] ?? 0,
                        color: Colors.teal,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded Details
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Individual Stat Entries',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.playerStats.map((stat) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  stat.leagueName,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                _formatDate(stat.createdAt),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              if (stat.touchdowns > 0)
                                _StatChip(
                                  label: 'TDs',
                                  value: stat.touchdowns,
                                  color: Colors.green,
                                  isSmall: true,
                                ),
                              if (stat.catches > 0)
                                _StatChip(
                                  label: 'Catches',
                                  value: stat.catches,
                                  color: Colors.blue,
                                  isSmall: true,
                                ),
                              if (stat.catchYards > 0)
                                _StatChip(
                                  label: 'Catch Yds',
                                  value: stat.catchYards,
                                  color: Colors.purple,
                                  isSmall: true,
                                ),
                              if (stat.rushYards > 0)
                                _StatChip(
                                  label: 'Rush Yds',
                                  value: stat.rushYards,
                                  color: Colors.orange,
                                  isSmall: true,
                                ),
                              if (stat.passYards > 0)
                                _StatChip(
                                  label: 'Pass Yds',
                                  value: stat.passYards,
                                  color: Colors.teal,
                                  isSmall: true,
                                ),
                              if (stat.completions > 0)
                                _StatChip(
                                  label: 'Completions',
                                  value: stat.completions,
                                  color: Colors.indigo,
                                  isSmall: true,
                                ),
                              if (stat.interceptions > 0)
                                _StatChip(
                                  label: 'INTs',
                                  value: stat.interceptions,
                                  color: Colors.red,
                                  isSmall: true,
                                ),
                              if (stat.sack > 0)
                                _StatChip(
                                  label: 'Sacks',
                                  value: stat.sack,
                                  color: Colors.brown,
                                  isSmall: true,
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool isSmall;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isSmall ? 4 : 6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

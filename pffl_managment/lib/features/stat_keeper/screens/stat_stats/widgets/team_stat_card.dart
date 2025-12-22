import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/features/stat_keeper/models/game_stat_model.dart';
import 'package:pffl_managment/features/stat_keeper/models/team_stat_model.dart';
import 'package:pffl_managment/features/stat_keeper/screens/stat_stats/widgets/stat_detail_row.dart';

class TeamStatCard extends StatefulWidget {
  final GameStatModel gameStat;
  final bool isDraft;
  final VoidCallback? onApprove;

  const TeamStatCard({
    super.key,
    required this.gameStat,
    this.isDraft = false,
    this.onApprove,
  });

  @override
  State<TeamStatCard> createState() => _TeamStatCardState();
}

class _TeamStatCardState extends State<TeamStatCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Team 1 Stats
          _buildTeamSection(widget.gameStat.team1Stats, isFirst: true),

          // Team 2 Stats (only if present)
          if (widget.gameStat.team2Name.isNotEmpty)
            _buildTeamSection(widget.gameStat.team2Stats, isFirst: false),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                widget.gameStat.leagueName,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: widget.isDraft
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.isDraft ? 'Draft' : 'Approved',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(TeamStatModel teamStats, {required bool isFirst}) {
    return Column(
      children: [
        // Team header
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Team logo
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderLight, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3.5),
                    child:
                        teamStats.teamLogo.isEmpty ||
                            !teamStats.teamLogo.startsWith('http')
                        ? const Icon(Icons.sports_football, size: 20)
                        : CachedNetworkImage(
                            imageUrl: teamStats.teamLogo,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(strokeWidth: 2),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.sports_football, size: 20),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${teamStats.teamName} stats',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),

        // Expanded stats
        if (_isExpanded) ...[
          StatDetailRow(label: 'Catches', value: '${teamStats.catches}'),
          StatDetailRow(
            label: 'Catches Yrds',
            value: '${teamStats.catchesYards}',
          ),
          StatDetailRow(label: 'Rushes', value: '${teamStats.rushes}'),
          StatDetailRow(
            label: 'Rushes Yrds',
            value: '${teamStats.rushesYards}',
          ),
          StatDetailRow(
            label: 'Pass Attempts',
            value: '${teamStats.passAttempts}',
          ),
          StatDetailRow(label: 'Pass Yrds', value: '${teamStats.passYards}'),
          StatDetailRow(
            label: 'Completions',
            value: '${teamStats.completions}',
          ),
          StatDetailRow(label: 'TD\'s', value: '${teamStats.tds}'),
          StatDetailRow(label: 'Flag Pull', value: '${teamStats.flagPull}'),
          StatDetailRow(label: 'Sack', value: '${teamStats.sack}'),
          StatDetailRow(label: 'INT', value: '${teamStats.interceptions}'),
          StatDetailRow(label: 'Safety', value: '${teamStats.safety}'),
          StatDetailRow(
            label: 'Conversion Points',
            value: '${teamStats.conversionPoints}',
            showBorder: false,
          ),

          // Player individual stats if available
          if (teamStats.playerStats.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Player Details:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            ...teamStats.playerStats.map(
              (p) => Padding(
                padding: const EdgeInsets.only(left: 16),
                child: StatDetailRow(
                  label: p.playerName,
                  value: 'TD: ${p.tds}, C: ${p.catches}',
                  showBorder: true,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

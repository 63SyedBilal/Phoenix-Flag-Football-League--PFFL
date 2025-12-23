import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/utils/app_colors.dart';
import 'package:pffl_managment/features/stat_keeper/models/game_stat_model.dart';

class StatCard extends StatelessWidget {
  final GameStatModel gameStat;
  final VoidCallback? onTap;

  const StatCard({super.key, required this.gameStat, this.onTap});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // League header (NO divider here now)
          _buildLeagueHeader(),

          // Game info
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Teams row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTeam(
                        gameStat.team1Logo,
                        gameStat.team1Name,
                      ),

                      Column(
                        children: [
                          Text(
                            DateFormat('MM/dd').format(gameStat.date),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            gameStat.time,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),

                      _buildTeam(
                        gameStat.team2Logo,
                        gameStat.team2Name,
                      ),
                    ],
                  ),

                  // Divider + Assigned game label
                  if (gameStat.isAssignedToMe) ...[
                    const SizedBox(height: 12),

                    // ✅ Divider moved here
                    const Divider(
                      color: AppColors.borderLight,
                      thickness: 1,
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'Your Assigned Game',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Color(0xFF000000),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// League header WITHOUT bottom divider
  Widget _buildLeagueHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                gameStat.leagueName,
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
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              gameStat.isCompleted ? 'Completed' : 'Continue',
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

  Widget _buildTeam(String logo, String name) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.5),
            child: logo.isEmpty || !logo.startsWith('http')
                ? const Icon(Icons.sports_football, size: 24)
                : CachedNetworkImage(
                    imageUrl: logo,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(strokeWidth: 2),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.sports_football, size: 24),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
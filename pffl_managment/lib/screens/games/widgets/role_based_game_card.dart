import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/models/match_model.dart';
import 'package:pffl_managment/screens/games/game_tabs/game_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Role-based game card widget
/// Shows different action sections based on user role
class RoleBasedGameCard extends StatelessWidget {
  final MatchModel match;
  final String userRole;
  final bool canEdit;
  final bool shouldShowPaymentPrompt;
  final VoidCallback? onPayLeagueFee;
  final Function(String?)? onTeamTap;

  const RoleBasedGameCard({
    Key? key,
    required this.match,
    required this.userRole,
    this.canEdit = false,
    this.shouldShowPaymentPrompt = false,
    this.onPayLeagueFee,
    this.onTeamTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameDetailsScreen(match: match),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF000000).withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Opacity(
                  opacity: 0.6,
                  child: Row(
                    children: [
                      Text(
                        match.leagueName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Lato',
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xFF111827),
                        size: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 100,
                  child: GestureDetector(
                    onTap: onTeamTap != null && match.homeTeamId != null
                        ? () => onTeamTap!(match.homeTeamId)
                        : null,
                    child: Row(
                      children: [
                        _buildTeamLogo(match.homeTeamLogo),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            match.homeTeam,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Lato',
                              color: Color(0xFF111827),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      match.date,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lato',
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      match.time,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lato',
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                // Away team
                SizedBox(
                  width: 100,
                  child: GestureDetector(
                    onTap: onTeamTap != null && match.awayTeamId != null
                        ? () => onTeamTap!(match.awayTeamId)
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildTeamLogo(match.awayTeamLogo),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            match.awayTeam,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Lato',
                              color: Color(0xFF111827),
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Divider
            Divider(
              height: 0,
              thickness: 0.5,
              color: const Color(0xFF000000).withValues(alpha: 0.12),
            ),

            // Simple text below divider
            const SizedBox(height: 8),
            // Role-based action section
            _buildActionSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String logoUrl) {
    if (logoUrl.isEmpty) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: const Color(0xFF000000).withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
        child: const Center(
          child: Text(
            'No\nLogo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              height: 1.1,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF000000).withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.5),
        child: CachedNetworkImage(
          imageUrl: logoUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: Text(
                'No\nLogo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    // Captain with unpaid league fee
    if (shouldShowPaymentPrompt) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'Your league payment still unpaid',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lato',
                color: Color(0xFFDC2626), // Red color for warning
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onPayLeagueFee,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Pay League Fee',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lato',
              ),
            ),
          ),
        ],
      );
    }

    // Admin or Captain (with paid fee) - show edit option
    if (canEdit) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit, size: 12, color: Colors.blueGrey),
              SizedBox(width: 4),
              Text(
                'Edit Game',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Lato',
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          Icon(Icons.arrow_forward_ios_outlined, size: 12),
        ],
      );
    }

    // Other roles - no action section (view-only)
    return const SizedBox.shrink();
  }
}

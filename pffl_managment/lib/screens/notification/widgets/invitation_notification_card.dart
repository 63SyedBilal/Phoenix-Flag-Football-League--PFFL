import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/screens/notification/models/notification_model.dart';
import 'package:pffl_managment/screens/leagues/common/league_provider.dart';
import 'package:intl/intl.dart';

/// Generic premium invitation widget for all roles (Referee, Stat Keeper, Team Captain)
class InvitationNotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool isExpanded;
  final VoidCallback onToggleExpansion;
  final bool isLoading;

  const InvitationNotificationCard({
    super.key,
    required this.notification,
    this.onAccept,
    this.onReject,
    required this.isExpanded,
    required this.onToggleExpansion,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Date row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _getNotificationTitle(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          fontFamily: 'Serotiva',
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatDate(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Message text
                Text(
                  notification.displayMessage,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF475569), // slate 600
                    height: 1.5,
                    fontFamily: 'Lato',
                  ),
                ),
                const SizedBox(height: 16),

                // League Details Toggle
                Column(
                  children: [
                    const Divider(height: 1),
                    InkWell(
                      onTap: onToggleExpansion,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'View League Details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF475569), // slate 600
                                fontFamily: 'Lato',
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: const Color(0xFF94A3B8), // slate 400
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded) _buildLeagueDetails(context),
                  ],
                ),

                const SizedBox(height: 8),

                // Action buttons
                if (notification.isAccepted)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Color(0xFF10B981),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Accepted',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (notification.status.toLowerCase() == 'rejected')
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cancel,
                            color: Color(0xFFEF4444),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Rejected',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (notification.isPending &&
                    (onAccept != null || onReject != null))
                  Row(
                    children: [
                      if (onReject != null)
                        Expanded(
                          child: _buildButton(
                            onPressed: onReject,
                            label: 'Reject',
                            isPrimary: false,
                          ),
                        ),
                      if (onAccept != null) ...[
                        if (onReject != null) const SizedBox(width: 12),
                        Expanded(
                          child: _buildButton(
                            onPressed: onAccept,
                            label: 'Accept Invite',
                            isPrimary: true,
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeagueDetails(BuildContext context) {
    final leagueProvider = Provider.of<LeagueProvider>(context, listen: false);

    if (leagueProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (leagueProvider.allLeagues.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No league information available.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    // Try to match by league ID first, then by name
    final leagueInfo = leagueProvider.allLeagues.firstWhere(
      (l) =>
          (notification.leagueId != null && l.id == notification.leagueId) ||
          (l.leagueName == notification.league),
      orElse: () => leagueProvider.allLeagues.first,
    );

    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                  image: leagueInfo.logo != null && leagueInfo.logo!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(leagueInfo.logo!),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage('assets/images/logo.png'),
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                leagueInfo.leagueName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Format:',
            leagueInfo.format,
            'League Fee:',
            '\$${leagueInfo.perPlayerLeagueFee}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Start Date:',
            DateFormat('dd MMMM yyyy').format(leagueInfo.startDate),
            'End Date:',
            DateFormat('dd MMMM yyyy').format(leagueInfo.endDate),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label1,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value1,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 30,
          color: Colors.grey.shade200,
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label2,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value2,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required VoidCallback? onPressed,
    required String label,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF0F172A) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF0F172A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  String _getNotificationTitle() {
    switch (notification.type) {
      case 'TEAM_INVITE':
      case 'TEAM_INVITATION':
        return 'Team Invitation Received';
      case 'LEAGUE_REFEREE_INVITE':
        return 'Referee Invitation';
      case 'LEAGUE_STATKEEPER_INVITE':
        return 'Stat Keeper Invitation';
      case 'LEAGUE_TEAM_INVITE':
        return 'League Team Invitation';
      default:
        return 'Invitation Received';
    }
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }
}

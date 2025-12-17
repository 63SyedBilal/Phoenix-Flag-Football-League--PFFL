import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/captain_invite_provider.dart';
import 'invite_user_card.dart';
import 'invite_empty_state.dart';
import 'invite_loading_state.dart';

/// User list widget
class InviteUserList extends StatelessWidget {
  const InviteUserList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CaptainInviteProvider>(
      builder: (context, provider, _) {
        // Show loading state
        if (provider.isLoadingPlayers && provider.selectedTab == 'Players') {
          return const InviteLoadingState();
        }
        if (provider.isLoadingFreeAgents && provider.selectedTab == 'Free Agents') {
          return const InviteLoadingState();
        }

        // Get filtered users
        final users = provider.getFilteredUsers();

        // Show empty state
        if (users.isEmpty) {
          final message = provider.searchController.text.trim().isNotEmpty
              ? 'No users found matching your search'
              : 'No ${provider.selectedTab.toLowerCase()} found';
          return InviteEmptyState(message: message);
        }

        // Show user list
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return InviteUserCard(
              user: users[index],
              provider: provider,
            );
          },
        );
      },
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/captain_invite_provider.dart';
import 'widgets/invite_header.dart';
import 'widgets/invite_title.dart';
import 'widgets/invite_tabs.dart';
import 'widgets/invite_search_bar.dart';
import 'widgets/invite_user_list.dart';
import 'widgets/invite_loading_state.dart';

/// Main screen for captain to invite players to team
class CaptainInviteScreen extends StatelessWidget {
  const CaptainInviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CaptainInviteProvider(),
      child: const _CaptainInviteView(),
    );
  }
}

class _CaptainInviteView extends StatelessWidget {
  const _CaptainInviteView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<CaptainInviteProvider>(
          builder: (context, provider, _) {
            // Show initial loading state
            if (provider.isLoading) {
              return const Column(
                children: [
                  InviteHeader(),
                  InviteTitle(),
                  Expanded(child: InviteLoadingState()),
                ],
              );
            }

            // Show error state
            if (provider.errorMessage != null && provider.teamId == null) {
              return Column(
                children: [
                  const InviteHeader(),
                  const InviteTitle(),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              provider.errorMessage!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => provider.refresh(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Show main content
            return Column(
              children: [
                const InviteHeader(),
                const InviteTitle(),
                const InviteTabs(),
                const InviteSearchBar(),
                Expanded(child: InviteUserList()),
              ],
            );
          },
        ),
      ),
    );
  }
}

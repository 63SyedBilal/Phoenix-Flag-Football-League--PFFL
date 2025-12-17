import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/captain_invite_provider.dart';

/// Search bar widget
class InviteSearchBar extends StatelessWidget {
  const InviteSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CaptainInviteProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: TextField(
              controller: provider.searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name...',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/captain_invite_provider.dart';

/// Tab buttons widget (Players/Free Agents)
class InviteTabs extends StatelessWidget {
  const InviteTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CaptainInviteProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Row(
            children: [
              _buildTabButton(context, 'Players', provider),
              const SizedBox(width: 12),
              _buildTabButton(context, 'Free Agents', provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    String title,
    CaptainInviteProvider provider,
  ) {
    final isSelected = provider.selectedTab == title;
    return GestureDetector(
      onTap: () => provider.selectTab(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: "Lato",
            color: isSelected ? Colors.white : const Color(0xFF000000),
          ),
        ),
      ),
    );
  }
}

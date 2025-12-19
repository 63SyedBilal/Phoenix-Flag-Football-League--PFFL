import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/features/admin/providers/league_officials_provider.dart';
import 'package:pffl_managment/features/admin/providers/add_official_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LeagueOfficialsList extends StatelessWidget {
  final String leagueId;
  
  const LeagueOfficialsList({super.key, required this.leagueId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = LeagueOfficialsProvider(leagueId: leagueId);
        provider.initialize();
        return provider;
      },
      child: Consumer<LeagueOfficialsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading officials: ${provider.errorMessage}',
                      style: const TextStyle(color: Colors.red),
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
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Referee',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Color.fromRGBO(17, 24, 39, 1),
                        fontFamily: 'Lato',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              IconButton(
                icon: const Icon(Icons.add, size: 24),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddOfficialPage(
                            officialType: 'Referee',
                            leagueId: leagueId,
                          ),
                    ),
                  );
                  // Refresh officials when returning from AddOfficialPage
                  if (context.mounted) {
                    final officialsProvider = Provider.of<LeagueOfficialsProvider>(context, listen: false);
                    officialsProvider.refresh();
                  }
                },
              ),
                  ],
                ),
                _RefereeList(referees: provider.referees),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Stat Keeper',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Color.fromRGBO(17, 24, 39, 1),
                        fontFamily: 'Lato',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              IconButton(
                icon: const Icon(Icons.add, size: 24),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddOfficialPage(
                            officialType: 'Stat Keeper',
                            leagueId: leagueId,
                          ),
                    ),
                  );
                  // Refresh officials when returning from AddOfficialPage
                  if (context.mounted) {
                    final officialsProvider = Provider.of<LeagueOfficialsProvider>(context, listen: false);
                    officialsProvider.refresh();
                  }
                },
              ),
                  ],
                ),
                _StatKeeperList(statKeepers: provider.statKeepers),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RefereeList extends StatelessWidget {
  final List<OfficialUser> referees;

  const _RefereeList({required this.referees});

  @override
  Widget build(BuildContext context) {
    if (referees.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          'No referees found',
          style: TextStyle(
            color: Color.fromRGBO(107, 114, 128, 1),
            fontFamily: 'Lato',
            fontSize: 14,
          ),
        ),
      );
    }

    return Column(
      children: referees.map((referee) {
        return _buildRefereeItem(context, referee);
      }).toList(),
    );
  }

  Widget _buildRefereeItem(BuildContext context, OfficialUser referee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(
          color: const Color.fromRGBO(229, 231, 235, 1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromRGBO(229, 231, 235, 1),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: referee.imageUrl != null && referee.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: referee.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: const Color.fromRGBO(243, 244, 246, 1),
                        child: const Icon(
                          Icons.person,
                          color: Color.fromRGBO(156, 163, 175, 1),
                          size: 24,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color.fromRGBO(243, 244, 246, 1),
                        child: const Icon(
                          Icons.person,
                          color: Color.fromRGBO(156, 163, 175, 1),
                          size: 24,
                        ),
                      ),
                    )
                  : Container(
                      color: const Color.fromRGBO(243, 244, 246, 1),
                      child: const Icon(
                        Icons.person,
                        color: Color.fromRGBO(156, 163, 175, 1),
                        size: 24,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Referee name
          Expanded(
            child: Text(
              referee.name,
              style: const TextStyle(
                color: Color.fromRGBO(17, 24, 39, 1),
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Email icon - shows success color if invitation sent
          Consumer<LeagueOfficialsProvider>(
            builder: (context, provider, child) {
              final isInvited = provider.isInvitationSent(referee.id);
              return GestureDetector(
                onTap: () async {
                  // Send invitation
                  final success = await provider.sendInvitation(referee.id, 'referee');
                  if (success && context.mounted) {
                    // Icon color will change automatically via Consumer rebuild
                  }
                },
                child: Icon(
                  Icons.mail_outline,
                  color: isInvited ? Colors.green : Colors.blueGrey,
                  size: 18,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatKeeperList extends StatelessWidget {
  final List<OfficialUser> statKeepers;

  const _StatKeeperList({required this.statKeepers});

  @override
  Widget build(BuildContext context) {
    if (statKeepers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          'No stat keepers found',
          style: TextStyle(
            color: Color.fromRGBO(107, 114, 128, 1),
            fontFamily: 'Lato',
            fontSize: 14,
          ),
        ),
      );
    }

    return Column(
      children: statKeepers.map((statKeeper) {
        return _buildStatKeeperItem(context, statKeeper);
      }).toList(),
    );
  }

  Widget _buildStatKeeperItem(
    BuildContext context,
    OfficialUser statKeeper,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(
          color: const Color.fromRGBO(229, 231, 235, 1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromRGBO(229, 231, 235, 1),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: statKeeper.imageUrl != null && statKeeper.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: statKeeper.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: const Color.fromRGBO(243, 244, 246, 1),
                        child: const Icon(
                          Icons.person,
                          color: Color.fromRGBO(156, 163, 175, 1),
                          size: 24,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color.fromRGBO(243, 244, 246, 1),
                        child: const Icon(
                          Icons.person,
                          color: Color.fromRGBO(156, 163, 175, 1),
                          size: 24,
                        ),
                      ),
                    )
                  : Container(
                      color: const Color.fromRGBO(243, 244, 246, 1),
                      child: const Icon(
                        Icons.person,
                        color: Color.fromRGBO(156, 163, 175, 1),
                        size: 24,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Stat Keeper name
          Expanded(
            child: Text(
              statKeeper.name,
              style: const TextStyle(
                color: Color.fromRGBO(17, 24, 39, 1),
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Email icon - shows success color if invitation sent
          Consumer<LeagueOfficialsProvider>(
            builder: (context, provider, child) {
              final isInvited = provider.isInvitationSent(statKeeper.id);
              return GestureDetector(
                onTap: () async {
                  // Send invitation
                  final success = await provider.sendInvitation(statKeeper.id, 'stat-keeper');
                  if (success && context.mounted) {
                    // Icon color will change automatically via Consumer rebuild
                  }
                },
                child: Icon(
                  Icons.mail_outline,
                  color: isInvited ? Colors.green : Colors.blueGrey,
                  size: 18,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AddOfficialPage extends StatelessWidget {
  final String officialType;
  final String leagueId;

  const AddOfficialPage({
    super.key,
    required this.officialType,
    required this.leagueId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = AddOfficialProvider(leagueId: leagueId, officialType: officialType);
        provider.initialize();
        return provider;
      },
      child: _AddOfficialPageContent(officialType: officialType),
    );
  }
}

class _AddOfficialPageContent extends StatelessWidget {
  final String officialType;

  const _AddOfficialPageContent({required this.officialType});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddOfficialProvider>(
      builder: (context, provider, child) {
        // Determine tabs based on official type
        List<String> tabs = [];
        if (officialType.toLowerCase() == 'referee') {
          tabs = ['Referee', 'Free Agent'];
        } else if (officialType.toLowerCase() == 'stat keeper') {
          tabs = ['Stat Keeper', 'Free Agent'];
        } else {
          tabs = ['Search', 'Suggested'];
        }

        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(leading: ArrowBackButton()),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(leading: ArrowBackButton()),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose $officialType for this league. You can invite new officials or select from existing ones.',
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                ),
                const SizedBox(height: 20),
                _TabSelector(
                  tabs: tabs,
                  selectedIndex: provider.selectedTabIndex,
                  onTabSelected: (index) {
                    provider.setSelectedTabIndex(index);
                  },
                ),
                const SizedBox(height: 20),
                // Search bar
                TextField(
                  onChanged: provider.updateSearchQuery,
                  decoration: const InputDecoration(
                    hintText: 'Search by official name',
                    hintStyle: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12.0,
                    ),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Show selected tab's list
                if (provider.selectedTabIndex == 0)
                  _OfficialsList(
                    officials: provider.filteredOfficials,
                    officialType: officialType,
                  )
                else
                  _OfficialsList(
                    officials: provider.filteredFreeAgents,
                    officialType: officialType,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TabSelector extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const _TabSelector({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onTabSelected(0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              decoration: BoxDecoration(
                color: selectedIndex == 0
                    ? const Color(0xFF4285F4)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selectedIndex == 0
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  tabs[0],
                  style: TextStyle(
                    color: selectedIndex == 0
                        ? Colors.white
                        : const Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => onTabSelected(1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              decoration: BoxDecoration(
                color: selectedIndex == 1
                    ? const Color(0xFF4285F4)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selectedIndex == 1
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  tabs[1],
                  style: TextStyle(
                    color: selectedIndex == 1
                        ? Colors.white
                        : const Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OfficialsList extends StatelessWidget {
  final List<OfficialUser> officials;
  final String officialType;

  const _OfficialsList({
    required this.officials,
    required this.officialType,
  });

  @override
  Widget build(BuildContext context) {
    if (officials.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'No officials found',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    return Column(
      children: officials.map((official) {
        return _buildOfficialItem(context, official);
      }).toList(),
    );
  }

  Widget _buildOfficialItem(BuildContext context, OfficialUser official) {
    return Consumer<AddOfficialProvider>(
      builder: (context, provider, child) {
        final isInvited = provider.isInvitationSent(official.id);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color.fromRGBO(229, 231, 235, 1),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: official.imageUrl != null && official.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: official.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color.fromRGBO(243, 244, 246, 1),
                            child: const Icon(
                              Icons.person,
                              color: Color.fromRGBO(156, 163, 175, 1),
                              size: 16,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color.fromRGBO(243, 244, 246, 1),
                            child: const Icon(
                              Icons.person,
                              color: Color.fromRGBO(156, 163, 175, 1),
                              size: 16,
                            ),
                          ),
                        )
                      : Container(
                          color: const Color.fromRGBO(243, 244, 246, 1),
                          child: const Icon(
                            Icons.person,
                            color: Color.fromRGBO(156, 163, 175, 1),
                            size: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  official.name,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final success = await provider.sendInvitation(
                    official.id,
                    officialType.toLowerCase(),
                  );
                  if (success && context.mounted) {
                    // Icon color changes automatically via Consumer
                  }
                },
                child: Icon(
                  Icons.mail_outline,
                  color: isInvited ? Colors.green : Colors.blueGrey,
                  size: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

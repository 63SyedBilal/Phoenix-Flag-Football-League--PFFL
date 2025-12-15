import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/invite_screens/admin_invite_screen/admin_invite_provider.dart';

class AdminInviteScreen extends StatelessWidget {
  const AdminInviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminInviteProvider()..initialize(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.white,
          leading: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: ArrowBackButton(),
          ),
        ),
        body: Consumer<AdminInviteProvider>(
          builder: (context, provider, child) {
            // Initialize on first build
            if (!provider.isLoading &&
                provider.freeAgents.isEmpty &&
                provider.errorMessage == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                provider.initialize();
              });
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Invite Agent",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Add a new agent to your organization. Choose their role and send an invitation.",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Send invite by email",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Email + Role Row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black26),
                            ),
                            child: TextField(
                              onChanged: (value) =>
                                  provider.updateManualEmail(value),
                              decoration: const InputDecoration(
                                hintText: "james.richardson@pffl.com",
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showRoleSelectionDialog(
                            context,
                            provider.manualSelectedRole,
                            (role) => provider.updateManualRole(role),
                          ),
                          child: Container(
                            height: 48,
                            width: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black26),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  provider.manualSelectedRole ?? "Select role",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: provider.manualSelectedRole == null
                                        ? Colors.black54
                                        : Colors.black,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: provider.isSendingInvite
                          ? null
                          : () async {
                              final success = await provider.sendManualInvite();
                              if (context.mounted) {
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Invitation sent successfully',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        provider.errorMessage ??
                                            'Failed to send invitation',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: provider.isSendingInvite
                              ? Colors.grey
                              : const Color(0xff0B1437),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: provider.isSendingInvite
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  "Send Invite",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Agents",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Free Agents List
                    if (provider.isLoading && provider.freeAgents.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (provider.errorMessage != null &&
                        provider.freeAgents.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                provider.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () => provider.refresh(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (provider.freeAgents.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('No free agents found'),
                        ),
                      )
                    else
                      ...provider.freeAgents.map(
                        (agent) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ExpandableAgentCard(
                            agent: agent,
                            provider: provider,
                          ),
                        ),
                      ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showRoleSelectionDialog(
    BuildContext context,
    String? currentRole,
    Function(String?) onRoleSelected,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String? selectedRole = currentRole;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: const Text(
                'Select Role',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Lato',
                ),
              ),
              content: Container(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 0.67,
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text(
                              'Player',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Lato',
                              ),
                            ),
                            selected: selectedRole == 'Player',
                            onTap: () {
                              setState(() {
                                selectedRole = 'Player';
                              });
                            },
                          ),
                          ListTile(
                            title: const Text(
                              'Captain',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Lato',
                              ),
                            ),
                            selected: selectedRole == 'Captain',
                            onTap: () {
                              setState(() {
                                selectedRole = 'Captain';
                              });
                            },
                          ),
                          ListTile(
                            title: const Text(
                              'Referee',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Lato',
                              ),
                            ),
                            selected: selectedRole == 'Referee',
                            onTap: () {
                              setState(() {
                                selectedRole = 'Referee';
                              });
                            },
                          ),
                          ListTile(
                            title: const Text(
                              'Stat Keeper',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Lato',
                              ),
                            ),
                            selected: selectedRole == 'Stat Keeper',
                            onTap: () {
                              setState(() {
                                selectedRole = 'Stat Keeper';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF0F173E),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 18,
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF0F173E),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: selectedRole == null
                              ? null
                              : () {
                                  onRoleSelected(selectedRole);
                                  Navigator.of(context).pop();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F173E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 18,
                            ),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ExpandableAgentCard extends StatelessWidget {
  final FreeAgentModel agent;
  final AdminInviteProvider provider;

  const ExpandableAgentCard({
    super.key,
    required this.agent,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = provider.isAgentExpanded(agent.id);
    final selectedRole = provider.getAgentSelectedRole(agent.id);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => provider.toggleAgentExpansion(agent.id),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: agent.imageUrl != null
                      ? NetworkImage(agent.imageUrl!)
                      : null,
                  child: agent.imageUrl == null
                      ? const Icon(Icons.person, size: 26)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        agent.email,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () => _showRoleSelectionDialog(
                context,
                selectedRole,
                (role) => provider.updateAgentRole(agent.id, role),
              ),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black26),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedRole ?? "Select role",
                      style: TextStyle(
                        fontSize: 14,
                        color: selectedRole == null
                            ? Colors.black54
                            : Colors.black,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.black),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: provider.isAgentInviteSending(agent.id)
                  ? null
                  : () async {
                      final success = await provider.sendAgentInvite(agent.id);
                      if (context.mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invitation sent successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                provider.errorMessage ??
                                    'Failed to send invitation',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: provider.isAgentInviteSending(agent.id)
                      ? Colors.grey
                      : const Color(0xff0B1437),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: provider.isAgentInviteSending(agent.id)
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          "Send Invite",
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRoleSelectionDialog(
    BuildContext context,
    String? currentRole,
    Function(String?) onRoleSelected,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String? selectedRole = currentRole;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: const Text(
                'Select Role',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Lato',
                ),
              ),
              content: Container(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 0.67,
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text(
                              'Player',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Lato',
                              ),
                            ),
                            selected: selectedRole == 'Player',
                            onTap: () {
                              setState(() {
                                selectedRole = 'Player';
                              });
                            },
                          ),
                          ListTile(
                            title: const Text(
                              'Captain',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Lato',
                              ),
                            ),
                            selected: selectedRole == 'Captain',
                            onTap: () {
                              setState(() {
                                selectedRole = 'Captain';
                              });
                            },
                          ),
                          ListTile(
                            title: const Text(
                              'Referee',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Lato',
                              ),
                            ),
                            selected: selectedRole == 'Referee',
                            onTap: () {
                              setState(() {
                                selectedRole = 'Referee';
                              });
                            },
                          ),
                          ListTile(
                            title: const Text(
                              'Stat Keeper',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Lato',
                              ),
                            ),
                            selected: selectedRole == 'Stat Keeper',
                            onTap: () {
                              setState(() {
                                selectedRole = 'Stat Keeper';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF0F173E),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 18,
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF0F173E),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: selectedRole == null
                              ? null
                              : () {
                                  onRoleSelected(selectedRole);
                                  Navigator.of(context).pop();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F173E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 18,
                            ),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

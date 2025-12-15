import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/users/providers/users_provider.dart';
import 'package:pffl_managment/core/models/user_model.dart';
import 'package:provider/provider.dart';

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Consumer<UsersProvider>(
          builder: (context, viewModel, child) {
            // Initialize provider on first build
            if (!viewModel.isLoading && 
                viewModel.allUsers.isEmpty && 
                viewModel.errorMessage == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                viewModel.initialize();
              });
            }

            return Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search users by name or email...',
                            hintStyle: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 12.0, // Reduced hint text size
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF99A1AF),
                            ),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                          ),
                          onChanged: (value) {
                            viewModel.updateSearchQuery(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Filter tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => viewModel.selectFilter('all'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: viewModel.selectedFilter == 'all'
                                ? const Color(0xFF3B82F6)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 0.67,
                            ),
                          ),
                          child: Text(
                            'All Users',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: viewModel.selectedFilter == 'all'
                                  ? Colors.white
                                  : const Color(0xFF000000),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => viewModel.selectFilter('players'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: viewModel.selectedFilter == 'players'
                                ? const Color(0xFF3B82F6)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 0.67,
                            ),
                          ),
                          child: Text(
                            'Players',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: viewModel.selectedFilter == 'players'
                                  ? Colors.white
                                  : const Color(0xFF000000),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
            
                      GestureDetector(
                        onTap: () => viewModel.selectFilter('captains'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: viewModel.selectedFilter == 'captains'
                                ? const Color(0xFF3B82F6)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 0.67,
                            ),
                          ),
                          child: Text(
                            'Captains',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: viewModel.selectedFilter == 'captains'
                                  ? Colors.white
                                  : const Color(0xFF000000),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Referees tab
                      GestureDetector(
                        onTap: () => viewModel.selectFilter('referees'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: viewModel.selectedFilter == 'referees'
                                ? const Color(0xFF3B82F6)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 0.67,
                            ),
                          ),
                          child: Text(
                            'Referees',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: viewModel.selectedFilter == 'referees'
                                  ? Colors.white
                                  : const Color(0xFF000000),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Stat Keepers tab
                      GestureDetector(
                        onTap: () => viewModel.selectFilter('stat_keepers'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: viewModel.selectedFilter == 'stat_keepers'
                                ? const Color(0xFF3B82F6)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 0.67,
                            ),
                          ),
                          child: Text(
                            'Stat Keepers',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: viewModel.selectedFilter == 'stat_keepers'
                                  ? Colors.white
                                  : const Color(0xFF000000),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Loading state
                if (viewModel.isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            // Error state
            else if (viewModel.errorMessage != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => viewModel.refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            // Empty state
            else if (viewModel.filteredUsers.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    viewModel.searchQuery.isNotEmpty
                        ? 'No users found matching your search'
                        : 'No users found',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              )
            // Users list
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: viewModel.filteredUsers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildUserCard(context, viewModel.filteredUsers[index], viewModel);
                  },
                ),
              ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user, UsersProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.67),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF3F4F6), width: 2),
              image: DecorationImage(
                image: NetworkImage(user.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  user.name,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 4),
                // Email
                Text(
                  user.email,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6A7282),
                  ),
                ),
                const SizedBox(height: 8),
                // Team and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Team
                    if (user.team.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.group,
                            size: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user.team,
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF4A5565),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: user.role.colors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: user.role.colors.border,
                          width: 0.67,
                        ),
                      ),
                      child: Text(
                        user.role.displayName,
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: user.role.colors.text,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 14,
                          color: user.status.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.status.displayName,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: user.status.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_outlined),
            onSelected: (String result) {
              if (result == 'change_role') {
                _showChangeRoleCard(context, user, provider);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'change_role',
                child: Container(
                  width: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    color: Color.fromRGBO(15, 23, 62, 1),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Change Role',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          fontFamily: 'Lato',
                          fontSize: 16,
                          letterSpacing: 0,
                          fontWeight: FontWeight.normal,
                          height: 1.4285714285714286,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleCard(BuildContext context, UserModel user, UsersProvider provider) {
    // Show a dialog or bottom sheet with change role options
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String? selectedRole;
        bool isUpdating = false;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Change User Role',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Serotiva',
                ),
              ),
          content: Container(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Are you sure you want to change this player’s role?', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Lato', color: Colors.black),),
                SizedBox(height: 16),
                Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey, width: 0.67),
  ),
  child: Column(children: [
        ListTile(
                    title: Text('Player'),
                                        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w400,color: Colors.black,fontFamily: 'Lato'),

                    onTap: () {
                      // Handle player role selection
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: Text('Captain'),
                    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w400,color: Colors.black,fontFamily: 'Lato'),
                    onTap: () {
                      // Handle captain role selection
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: Text('Referee'),
                                        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w400,color: Colors.black,fontFamily: 'Lato'),

                    onTap: () {
                      // Handle referee role selection
                      Navigator.of(context).pop();
                    },
                  ),
  
  ],),
),
            
                SizedBox(height: 16),
                // Action buttons in a row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                        // Cancel button with border and rounded corners
                        OutlinedButton(
                          onPressed: isUpdating
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF3B82F6), width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF3B82F6),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Confirm button with primary color and rounded corners
                        ElevatedButton(
                          onPressed: (isUpdating || selectedRole == null)
                              ? null
                              : () async {
                                  setState(() {
                                    isUpdating = true;
                                  });

                                  final success = await provider.updateUserRole(
                                    user.id,
                                    selectedRole!,
                                  );

                                  if (context.mounted) {
                                    if (success) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('User role updated to $selectedRole'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        isUpdating = false;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Failed to update user role'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                          ),
                          child: isUpdating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Confirm',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
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

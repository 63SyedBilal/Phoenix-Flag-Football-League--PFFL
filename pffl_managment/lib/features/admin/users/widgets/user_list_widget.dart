import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/core/models/user_model.dart';
import 'package:pffl_managment/features/admin/users/widgets/users_card_widget.dart';

class UserListWidget extends StatelessWidget {
  final List<UserModel> users;

  const UserListWidget({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('No users found', style: AppTextStyles.bodyMedium),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return UserCardWidget(user: users[index]);
      },
    );
  }
}

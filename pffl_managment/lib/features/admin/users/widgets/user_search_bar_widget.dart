import 'package:flutter/material.dart';
import 'package:pffl_managment/core/utils/app_icons.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'package:pffl_managment/features/admin/users/providers/users_provider.dart';
import 'package:provider/provider.dart';

class UserSearchBarWidget extends StatelessWidget {
  const UserSearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.12),
            width: 0.67,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 17),
            const Icon(AppIcons.search, size: 20, color: Color(0xFF99A1AF)),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                onChanged: (value) {
                  context.read<UsersProvider>().updateSearchQuery(value);
                },
                hintText: 'Search users by name or email...',
              ),
            ),
            const SizedBox(width: 17),
          ],
        ),
      ),
    );
  }
}

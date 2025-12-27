import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';
import 'package:pffl_managment/screens/settings/common/settings_provider.dart';
import 'package:pffl_managment/core/providers/auth_provider.dart';
import 'package:pffl_managment/routes/app_routes.dart';

/// Main settings screen that dynamically loads sections based on user role
/// Uses exact Admin Settings UI structure with logout button
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleBasedSettingsProvider>(
      builder: (context, settingsProvider, child) {
        final sections = settingsProvider.settingsSections;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Column(
                          children: List.generate(sections.length, (index) {
                            final section = sections[index];
                            return Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                      width: 0.67,
                                    ),
                                  ),
                                  child: _buildListTile(
                                    context,
                                    title: section.title,
                                    onTap: () => settingsProvider
                                        .navigateToSection(context, index),
                                  ),
                                ),
                                if (index < sections.length - 1)
                                  const SizedBox(height: 16),
                              ],
                            );
                          }),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Show confirmation dialog
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Logout'),
                              content: const Text(
                                'Are you sure you want to log out?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF0F172A),
                                  ),
                                  child: const Text('Log Out'),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldLogout == true && context.mounted) {
                          try {
                            print(
                              '🔄 [SETTINGS] User confirmed logout, starting process...',
                            );

                            // Show loading indicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const AlertDialog(
                                  content: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(width: 16),
                                      Text('Logging out...'),
                                    ],
                                  ),
                                );
                              },
                            );

                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );

                            await authProvider.logout(context);

                            print(
                              '✅ [SETTINGS] Logout successful, navigating to login...',
                            );

                            if (context.mounted) {
                              // Close loading dialog
                              Navigator.of(context).pop();

                              // Navigate to login screen
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRoutes.login,
                                (route) => false,
                              );
                            }
                          } catch (e) {
                            print('❌ [SETTINGS] Logout error: $e');

                            if (context.mounted) {
                              // Close loading dialog
                              Navigator.of(context).pop();

                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Logout failed: ${e.toString()}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );

                              // Still navigate to login as a fallback
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                AppRoutes.login,
                                (route) => false,
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Log out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return ListTile(
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w500,
          color: const Color(0xFF111827),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF6B7280),
              ),
            )
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFF99A1AF),
      ),
      onTap: enabled ? onTap : null,
      contentPadding: EdgeInsets.zero,
    );
  }
}

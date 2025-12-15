import 'package:flutter/material.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_item.dart';
import 'package:pffl_managment/routes/app_routes.dart';

class CaptainSettingsScreen extends StatelessWidget {
  const CaptainSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsHeader(),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: [
                    SettingsItem(
                      title: 'Profile Information',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.captainDashboard);
                      },
                    ),
                    SettingsItem(
                      title: 'Team',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.captainTeamManagement);
                      },
                    ),
                    SettingsItem(
                      title: 'Payment History',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.captainPaymentHistory);
                      },
                    ),
                    SettingsItem(
                      title: 'Notifications',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.notifications);
                      },
                    ),
                    SettingsItem(
                      title: 'Change Password',
                      onTap: () {
                        // TODO: Implement change password functionality
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Logout logic placeholder
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logging out...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Log out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Settings
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3B82F6), // Blue
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'My Team',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          // Navigation logic would go here
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Enable dark theme and notifications by default
  bool _isDarkMode = true;
  bool _notificationsEnabled = true;
  bool _workoutReminders = true;
  bool _mealReminders = true;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? true;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _workoutReminders = prefs.getBool('workout_reminders') ?? true;
      _mealReminders = prefs.getBool('meal_reminders') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setBool('workout_reminders', _workoutReminders);
    await prefs.setBool('meal_reminders', _mealReminders);
    await prefs.setString('language', _selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF007BFF),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Customize your app experience',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                const SizedBox(height: 24),

                // Appearance Section
                _buildSettingsSection(
                  title: 'Appearance',
                  icon: Icons.palette,
                  children: [
                    _buildSwitchTile(
                      title: 'Dark Mode',
                      subtitle: 'Switch between light and dark themes',
                      icon: Icons.dark_mode,
                      value: _isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          _isDarkMode = value;
                        });
                        // Persist the preference and update the global theme immediately
                        _saveSettings();
                        ThemeService().setDarkMode(value);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Notifications Section
                _buildSettingsSection(
                  title: 'Notifications',
                  icon: Icons.notifications,
                  children: [
                    _buildSwitchTile(
                      title: 'Push Notifications',
                      subtitle: 'Receive app notifications',
                      icon: Icons.notifications_active,
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                        _saveSettings();
                      },
                    ),
                    _buildSwitchTile(
                      title: 'Workout Reminders',
                      subtitle: 'Get reminded to workout',
                      icon: Icons.fitness_center,
                      value: _workoutReminders,
                      onChanged: (value) {
                        setState(() {
                          _workoutReminders = value;
                        });
                        _saveSettings();
                      },
                    ),
                    _buildSwitchTile(
                      title: 'Meal Reminders',
                      subtitle: 'Get reminded about meals',
                      icon: Icons.restaurant,
                      value: _mealReminders,
                      onChanged: (value) {
                        setState(() {
                          _mealReminders = value;
                        });
                        _saveSettings();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // General Section
                _buildSettingsSection(
                  title: 'General',
                  icon: Icons.settings,
                  children: [
                    _buildListTile(
                      title: 'Language',
                      subtitle: _selectedLanguage,
                      icon: Icons.language,
                      onTap: () => _showLanguageDialog(),
                    ),
                    _buildListTile(
                      title: 'About',
                      subtitle: 'App version and info',
                      icon: Icons.info,
                      onTap: () => _showAboutDialog(),
                    ),
                    _buildListTile(
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                      icon: Icons.privacy_tip,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Privacy Policy feature coming soon!',
                            ),
                            backgroundColor: Color(0xFF007BFF),
                          ),
                        );
                      },
                    ),
                    _buildListTile(
                      title: 'Terms of Service',
                      subtitle: 'Read our terms of service',
                      icon: Icons.description,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Terms of Service feature coming soon!',
                            ),
                            backgroundColor: Color(0xFF007BFF),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Account Section (trimmed per request)
                _buildSettingsSection(
                  title: 'Account',
                  icon: Icons.account_circle,
                  children: [
                    _buildListTile(
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      icon: Icons.logout,
                      onTap: () => _showLogoutDialog(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF007BFF)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF007BFF),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[600], size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', 'English'),
            _buildLanguageOption('Spanish', 'Español'),
            _buildLanguageOption('French', 'Français'),
            _buildLanguageOption('German', 'Deutsch'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String value, String label) {
    return ListTile(
      title: Text(label),
      leading: Radio<String>(
        value: value,
        groupValue: _selectedLanguage,
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedLanguage = newValue;
            });
            _saveSettings();
            Navigator.pop(context);
          }
        },
        activeColor: const Color(0xFF007BFF),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'FlexMind Fit',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.fitness_center,
        color: Color(0xFF007BFF),
        size: 48,
      ),
      children: [
        const Text(
          'A comprehensive fitness app to help you achieve your health goals.',
        ),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Personalized workout plans'),
        const Text('• Healthy meal recommendations'),
        const Text('• Progress tracking'),
        const Text('• Goal setting and reminders'),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AuthService().signOut();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007BFF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

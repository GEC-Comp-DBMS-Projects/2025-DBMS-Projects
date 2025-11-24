import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgentSettingsPage extends StatefulWidget {
  const AgentSettingsPage({super.key});

  @override
  State<AgentSettingsPage> createState() => _AgentSettingsPageState();
}

class _AgentSettingsPageState extends State<AgentSettingsPage> {
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color grayBlue = Color(0xFF82A0BC);
  static const Color paleBlue = Color(0xFFA7CCED);

  bool _notificationsEnabled = true;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled =
          prefs.getBool('agentNotificationsEnabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = value;
    });
    await prefs.setBool('agentNotificationsEnabled', value);
  }

  Future<void> _changePassword() async {
    final TextEditingController newPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: TextField(
          controller: newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: "Enter new password",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: grayBlue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: lightBlue),
            onPressed: () async {
              try {
                await _auth.currentUser!.updatePassword(
                  newPasswordController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Password updated successfully"),
                    backgroundColor: lightBlue,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: $e"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "Are you sure you want to permanently delete your account? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: grayBlue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _auth.currentUser!.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account deleted successfully"),
            backgroundColor: lightBlue,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting account: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paleBlue.withValues(alpha: 0.2),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: darkBlue,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          const SizedBox(height: 10),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: lightBlue),
                  title: const Text(
                    "Change Password",
                    style: TextStyle(color: darkBlue),
                  ),
                  onTap: _changePassword,
                ),
                const Divider(),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.notifications_active_outlined,
                    color: lightBlue,
                  ),
                  title: const Text(
                    "Enable Notifications",
                    style: TextStyle(color: darkBlue),
                  ),
                  value: _notificationsEnabled,
                  activeColor: lightBlue,
                  onChanged: _toggleNotifications,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    "Delete Account",
                    style: TextStyle(color: darkBlue),
                  ),
                  onTap: _deleteAccount,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "FAQs",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildFAQ(
            "How do I accept a job?",
            "Go to your Home tab, view new job requests, and tap Accept to start.",
          ),
          _buildFAQ(
            "Can I reject a job?",
            "Yes, you can reject a job if you are unavailable.",
          ),
          _buildFAQ(
            "How do I update my availability?",
            "Go to the Profile or Availability section to set your working hours.",
          ),
          _buildFAQ(
            "Can I report a customer?",
            "Yes, use the Support section to report any issues.",
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFAQ(String question, String answer) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.help_outline, color: lightBlue),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, color: darkBlue),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(answer, style: const TextStyle(color: grayBlue)),
          ),
        ],
      ),
    );
  }
}

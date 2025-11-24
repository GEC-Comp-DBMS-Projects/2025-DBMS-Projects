import 'package:flutter/material.dart';
import 'package:note_organiser/widgets/Button.dart';

class ProfileWidget extends StatelessWidget {
  final String profileImageUrl;
  final String fullName;
  final String status;
  final String username;
 
  final String email;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onSignOutPressed;

  const ProfileWidget({
    super.key,
    required this.profileImageUrl,
    required this.fullName,
    required this.status,
    required this.username,

    required this.email,
    required this.onNotificationsPressed,
    required this.onSignOutPressed,
  });

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w500)),
          const Divider(thickness: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Profile",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Profile Picture + Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundImage: NetworkImage(profileImageUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fullName,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent)),
                    const SizedBox(height: 4),
                    Text(status,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.blueGrey)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          _buildField("Username", username),
         
          _buildField("Email", email),

          const SizedBox(height: 40),
          AddGroupButton(
            buttonText: "NOTIFICATIONS",
            onPressed: onNotificationsPressed,
          ),
          const SizedBox(height: 16),
          AddGroupButton(
            buttonText: "SIGN OUT",
            onPressed: onSignOutPressed,
          ),
        ],
      ),
    );
  }
}

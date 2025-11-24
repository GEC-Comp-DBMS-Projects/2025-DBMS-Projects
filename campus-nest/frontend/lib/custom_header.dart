import 'package:flutter/material.dart';

class CustomAppHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap; // ✨ New callback for the notification icon
  final Color primaryColor;
  final Color darkColor;
  final Color lightColor;

  const CustomAppHeader({
    super.key,
    required this.onProfileTap,
    required this.onNotificationTap, // ✨ Make it required in the constructor
    required this.primaryColor,
    required this.darkColor,
    required this.lightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Logo and App Name (unchanged)
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Image.asset(
                  'assets/images/campusnest_logo.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'CAMPUSNEST',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: darkColor,
                ),
              ),
            ],
          ),
          
          // ✨ Right side: Notification Icon and Profile Avatar wrapped in a Row
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: darkColor),
                onPressed: onNotificationTap,
                tooltip: 'Notifications',
                visualDensity: VisualDensity.compact, // Reduces default padding
              ),
              const SizedBox(width: 8), 
              GestureDetector(
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: darkColor,
                  child: Text(
                    'CN',
                    style: TextStyle(
                      color: lightColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
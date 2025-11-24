import 'package:flutter/material.dart';
import 'package:kart_app/controllers/auth_service.dart';
import 'package:kart_app/providers/user_provider.dart';
import 'package:kart_app/services/order_status_listener.dart'; // ADD THIS IMPORT
import 'package:provider/provider.dart';
import 'package:kart_app/views/logo.dart'; // <-- added import for AppLogo

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Reload user data when page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.edit_outlined),
          //   onPressed: () {
          //     // Navigator.pushNamed(context, "/update_profile");
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text("Edit profile coming soon")),
          //     );
          //   },
          // ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Card
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Text(
                              (userProvider.name.isNotEmpty &&
                                      userProvider.name != "User")
                                  ? userProvider.name[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name
                        Text(
                          userProvider.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Email
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  userProvider.email,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Phone (if available)
                        if (userProvider.phone.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.phone_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  userProvider.phone,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),

            // Quick Stats Card (Optional - can show order count, etc.)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    // children: [
                    //   _buildStatItem(
                    //     icon: Icons.shopping_bag_outlined,
                    //     label: "Orders",
                    //     value: "0",
                    //     color: Colors.blue,
                    //   ),
                    //   Container(
                    //     width: 1,
                    //     height: 40,
                    //     color: Colors.grey.shade300,
                    //   ),
                    //   _buildStatItem(
                    //     icon: Icons.favorite_outline,
                    //     label: "Wishlist",
                    //     value: "0",
                    //     color: Colors.red,
                    //   ),
                    //   Container(
                    //     width: 1,
                    //     height: 40,
                    //     color: Colors.grey.shade300,
                    //   ),
                    //   _buildStatItem(
                    //     icon: Icons.local_offer_outlined,
                    //     label: "Offers",
                    //     value: "0",
                    //     color: Colors.green,
                    //   ),
                    // ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Menu Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      "Account Settings",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),

                  // Menu Items Card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.local_shipping_outlined,
                          title: "Orders",
                          subtitle: "View your rental history",
                          color: Colors.orange,
                          onTap: () {
                            Navigator.pushNamed(context, "/orders");
                          },
                        ),
                        Divider(
                          height: 1,
                          indent: 68,
                          color: Colors.grey.shade200,
                        ),
                        _buildMenuItem(
                          icon: Icons.support_agent,
                          title: "Help & Support",
                          subtitle: "Get assistance from our team",
                          color: Colors.blue,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Mail us at kalakart@shop.com"),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        Divider(
                          height: 1,
                          indent: 68,
                          color: Colors.grey.shade200,
                        ),
                        _buildMenuItem(
                          icon: Icons.info_outline,
                          title: "About Us",
                          subtitle: "Learn more about KalaKart",
                          color: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutUsPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Logout Card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildMenuItem(
                      icon: Icons.logout_outlined,
                      title: "Logout",
                      subtitle: "Sign out from your account",
                      color: Colors.red,
                      onTap: () async {
                        // Show confirmation dialog
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text("Logout"),
                            content: const Text(
                              "Are you sure you want to logout?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text("Logout"),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout == true && mounted) {
                          // ADD THIS LINE: Stop listening to order changes
                          await OrderStatusListener().stopListening();

                          // Cancel the user data stream subscription
                          Provider.of<UserProvider>(
                            context,
                            listen: false,
                          ).cancelProvider();

                          // Logout from Firebase
                          await AuthService().logout();

                          // Navigate to login and clear all previous routes
                          if (mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              "/login",
                              (route) => false,
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade400,
      ),
    );
  }
}

// About Us Page remains the same...
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "About Us",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    // Use the app logo widget instead of the icon
                    const AppLogo(size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      "KalaKart",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Rent Your Stage, Create Your Magic",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Our Story Section
            _buildSection(
              icon: Icons.auto_stories,
              iconColor: Colors.blue,
              title: "Our Story",
              content:
                  "KalaKart was born from a simple idea: to make theatrical dreams accessible to everyone. We understand that behind every great performance, every memorable event, and every creative production, there's a need for quality equipment and costumes. Whether you're staging a school play, organizing a cultural event, shooting a film, or creating content, we're here to support your artistic journey.",
            ),

            // What We Offer Section
            _buildSection(
              icon: Icons.category_outlined,
              iconColor: Colors.purple,
              title: "What We Offer",
              content:
                  "KalaKart is your one-stop rental destination for all things theatrical and creative. Our extensive collection includes:",
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildOfferItem(
                        icon: Icons.checkroom,
                        title: "Theatrical Costumes",
                        description:
                            "Period costumes, character outfits, and accessories",
                        color: Colors.pink,
                      ),
                      const SizedBox(height: 16),
                      _buildOfferItem(
                        icon: Icons.music_note,
                        title: "Musical Instruments",
                        description:
                            "Guitars, keyboards, drums, and traditional instruments",
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(height: 16),
                      _buildOfferItem(
                        icon: Icons.camera_alt,
                        title: "Photography Equipment",
                        description:
                            "Professional cameras, lenses, lighting, and accessories",
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 16),
                      _buildOfferItem(
                        icon: Icons.mic,
                        title: "Audio Equipment",
                        description:
                            "Microphones, speakers, mixers, and recording gear",
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 16),
                      _buildOfferItem(
                        icon: Icons.lightbulb_outline,
                        title: "Stage Lighting",
                        description:
                            "Professional lights, LED panels, and control systems",
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Why Choose Us Section
            _buildSection(
              icon: Icons.star_outline,
              iconColor: Colors.orange,
              title: "Why Choose KalaKart?",
              content: "",
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        icon: Icons.verified_outlined,
                        title: "Quality Guaranteed",
                        description:
                            "Well-maintained equipment and regularly cleaned costumes",
                      ),
                      const Divider(height: 24),
                      _buildFeatureItem(
                        icon: Icons.schedule,
                        title: "Flexible Rental Periods",
                        description:
                            "From a single day to extended periods - rent as per your need",
                      ),
                      const Divider(height: 24),
                      _buildFeatureItem(
                        icon: Icons.attach_money,
                        title: "Affordable Pricing",
                        description: "Competitive rates that fit every budget",
                      ),
                      const Divider(height: 24),
                      _buildFeatureItem(
                        icon: Icons.local_shipping_outlined,
                        title: "Doorstep Delivery",
                        description: "Convenient delivery and pickup services",
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Mission Section
            _buildSection(
              icon: Icons.flag_outlined,
              iconColor: Colors.green,
              title: "Our Mission",
              content:
                  "At KalaKart, we believe that creativity shouldn't be limited by resources. Our mission is to democratize access to professional-grade theatrical and creative equipment, making it easy and affordable for artists, performers, students, and creators to bring their visions to life. We're not just a rental service - we're partners in your creative journey.",
            ),

            // Contact Section
            Container(
              margin: const EdgeInsets.all(16),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 48,
                        color: Colors.orange.shade600,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Get In Touch",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Have questions? We'd love to hear from you!",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "kalakart@shop.com",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Dev: Test notification button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.deepPurple,
                  ),
                  title: const Text('Send Test Notification'),
                  subtitle: const Text(
                    'Triggers a local notification for testing',
                  ),
                  onTap: () async {
                    try {
                      await OrderStatusListener().showTestNotification(
                        title: 'KalaKart Test',
                        body: 'This is a test notification from the app',
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Test notification sent')),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to send test notification: $e'),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (content.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
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
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.orange.shade600, size: 28),
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
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

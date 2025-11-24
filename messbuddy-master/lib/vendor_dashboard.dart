import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

void main() {
  // Ensure the status bar is styled appropriately for the Gen Z vibe
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  // You would run your main app, but for this example,
  // we run the VendorHomePage directly.
  runApp(const MaterialApp(
    home: VendorHomePage(),
    debugShowCheckedModeBanner: false,
  ));
}

class VendorHomePage extends StatefulWidget {
  const VendorHomePage({super.key});

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> with SingleTickerProviderStateMixin {
  String vendorName = "Vendor";
  String totalMeals = "0"; // Initialize to 0, will be updated
  Map<String, int> todaysMealCounts = {}; // Initialize empty, will be updated
  List<Map<String, dynamic>> recentReviews = []; // Initialize empty, will be updated
  bool isLoading = true;
  late AnimationController _pulseController;

  // Theme colors - matching HomeScreen
  final Color _backgroundColor = const Color(0xFF0A0A0A);
  final Color _cardBackgroundColor = const Color(0xFF161616);
  final Color _cardBackgroundAltColor = const Color(0xFF1A1A1A);
  final Color _primaryColor = const Color(0xFFFF2D55); // Hot pink
  final Color _accentColor = const Color(0xFF04E9CC); // Refined mint
  final Color _secondaryAccent = const Color(0xFF7F5AF7); // Purple
  final Color _tertiaryAccent = const Color(0xFFFFD60A); // Gold accent
  final Color _textColor = Colors.white;
  final Color _textSecondaryColor = Colors.white70;
  final Color _successColor = const Color(0xFF33FF99); // Mint green

  // Emojis for Gen Z vibe - kept subtle
  final String _waveEmoji = "👋";
  final String _fireEmoji = "🔥";
  final String _sparkleEmoji = "✨";
  final String _rocketEmoji = "🚀";
  final String _moneyEmoji = "💸";

  @override
  void initState() {
    super.initState();
    _loadVendorData();
    
    // Initialize pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // You can adapt this to fetch your vendor's data
  Future<void> _loadVendorData() async {
    // Simulate a network call

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final fullName = (doc['name'] ?? "") as String;
        setState(() {
          vendorName = fullName.isNotEmpty ? fullName.split(" ")[0] : "Vendor";
        });
      }
    }
    
    // Load total meals
    totalMeals = await _getTotalMealsThisWeek();

    // Load today's meal counts
    todaysMealCounts = await _getTodaysMeals();

    // Load recent reviews
    recentReviews = await _getRecentReviews();

    // Fallback for vendor name
    setState(() {
      vendorName = vendorName == "Vendor" ? "Chinmay" : vendorName; // Using name from image as placeholder
      isLoading = false;
    });
  }

  // Function to calculate total meals this week
  Future<String> _getTotalMealsThisWeek() async {
    try {
      // Get current date
      DateTime now = DateTime.now();
      
      // Find start of week (Monday)
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      
      // Find end of week (Sunday)
      DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
      
      // Query bookings collection
      CollectionReference bookings = FirebaseFirestore.instance.collection('bookings');
      QuerySnapshot snapshot = await bookings.get();
      
      int total = 0;
      
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> bookingsList = data['bookings'] ?? [];
        
        for (var booking in bookingsList) {
          String dateStr = booking['date'];
          DateTime date = DateTime.parse(dateStr); // Assuming format YYYY-MM-DD
          
          // Check if date is within this week
          if (date.isAfter(startOfWeek.subtract(Duration(days: 1))) && date.isBefore(endOfWeek.add(Duration(days: 1)))) {
            total++;
          }
        }
      }
      
      return total.toString();
    } catch (e) {
      // Handle errors, e.g., return 0 or log
      return "0";
    }
  }

  // Function to calculate today's meal counts
  Future<Map<String, int>> _getTodaysMeals() async {
    try {
      // Get today's date
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));
      
      // Query bookings collection
      CollectionReference bookings = FirebaseFirestore.instance.collection('bookings');
      QuerySnapshot snapshot = await bookings.get();
      
      Map<String, int> counts = {'Breakfast': 0, 'Lunch': 0, 'Dinner': 0};
      
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> bookingsList = data['bookings'] ?? [];
        
        for (var booking in bookingsList) {
          String dateStr = booking['date'];
          DateTime date = DateTime.parse(dateStr); // Assuming format YYYY-MM-DD
          
          // Check if date is today
          if (date.isAfter(startOfDay.subtract(Duration(days: 1))) && date.isBefore(endOfDay)) {
            String meal = (booking['meal'] as String).toLowerCase();
            if (meal == 'breakfast') {
              counts['Breakfast'] = (counts['Breakfast'] ?? 0) + 1;
            } else if (meal == 'lunch') {
              counts['Lunch'] = (counts['Lunch'] ?? 0) + 1;
            } else if (meal == 'dinner') {
              counts['Dinner'] = (counts['Dinner'] ?? 0) + 1;
            }
          }
        }
      }
      
      return counts;
    } catch (e) {
      // Handle errors, return zeros
      return {'Breakfast': 0, 'Lunch': 0, 'Dinner': 0};
    }
  }

  // Function to get recent reviews
  Future<List<Map<String, dynamic>>> _getRecentReviews() async {
    try {
      CollectionReference feedback = FirebaseFirestore.instance.collection('daily_feedbacks');
      QuerySnapshot snapshot = await feedback.get();
      List<Map<String, dynamic>> allReviews = [];
      
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data.forEach((reviewId, reviewData) {
          allReviews.add(reviewData as Map<String, dynamic>);
        });
      }
      
      // Sort by timestamp descending
      allReviews.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      
      // Take the most recent 2
      return allReviews.take(2).toList();
    } catch (e) {
      return [];
    }
  }

  // Helper to format timestamp to relative time
  String _formatTime(Timestamp timestamp) {
    DateTime now = DateTime.now();
    DateTime reviewTime = timestamp.toDate();
    Duration diff = now.difference(reviewTime);
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  // Helper to get icon based on rating
  IconData _getIcon(double rating) {
    if (rating >= 4) {
      return Icons.emoji_emotions;
    } else if (rating >= 2) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_very_dissatisfied;
    }
  }

  // Helper to get color based on rating
  Color _getColor(double rating) {
    if (rating >= 4) {
      return _successColor;
    } else if (rating >= 2) {
      return _tertiaryAccent;
    } else {
      return _primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: isLoading
          ? Center(
              child: _buildLoadingIndicator(),
            )
          : Stack(
              children: [
                // Subtle background gradient
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 1.5,
                      colors: [
                        _backgroundColor.withOpacity(0.9),
                        _backgroundColor,
                      ],
                    ),
                  ),
                ),
                
                // Background design elements - minimal glow spots
                Positioned(
                  top: -50,
                  right: -30,
                  child: Opacity(
                    opacity: 0.05,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [_primaryColor, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: -50,
                  child: Opacity(
                    opacity: 0.05,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [_accentColor, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Main content
                SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildHeader(vendorName),
                        _buildBodyContent(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: _buildCentralNavButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// Custom loading indicator with neon effect
  Widget _buildLoadingIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CircularProgressIndicator(
            color: _primaryColor,
            strokeWidth: 5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "loading vibes...",
          style: GoogleFonts.poppins(
            color: _textSecondaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Builds the central floating action button with refined Gen Z styling
  Widget _buildCentralNavButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          height: 65,
          width: 65,
          margin: const EdgeInsets.only(top: 30),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/edit_menu_page');
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing outline
                Container(
                  height: 65 + (_pulseController.value * 5),
                  width: 65 + (_pulseController.value * 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _primaryColor.withOpacity(0.4 - (_pulseController.value * 0.4)),
                      width: 2,
                    ),
                  ),
                ),
                // Inner circle with gradient
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryColor, _secondaryAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the top header section with refined Gen Z style
  Widget _buildHeader(String username) {
    final user = FirebaseAuth.instance.currentUser;
    final todayDate = DateFormat('EEEE, d MMM').format(DateTime.now());
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with profile and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Profile section with avatar
                Row(
                  children: [
                    // Avatar with animated border
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated gradient border
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: SweepGradient(
                                    colors: [
                                      _primaryColor,
                                      _accentColor,
                                      _secondaryAccent,
                                      _primaryColor,
                                    ],
                                    stops: const [0.0, 0.3, 0.7, 1.0],
                                    startAngle: _pulseController.value * 3.14 * 2,
                                    endAngle: (1 + _pulseController.value) * 3.14 * 2,
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          // Actual avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _cardBackgroundColor,
                              image: user?.photoURL != null ? DecorationImage(
                                image: NetworkImage(user!.photoURL!),
                                fit: BoxFit.cover,
                              ) : null,
                            ),
                            child: user?.photoURL == null
                                ? Center(
                                    child: Text(
                                      username.isNotEmpty ? username[0].toUpperCase() : 'V',
                                      style: GoogleFonts.poppins(
                                        color: _textColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    
                    // Username with today's date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'hey, ',
                              style: GoogleFonts.poppins(
                                color: _textSecondaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Text(
                              username.toLowerCase(),
                              style: GoogleFonts.poppins(
                                color: _textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(_waveEmoji, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          todayDate.toLowerCase(),
                          style: GoogleFonts.poppins(
                            color: _textSecondaryColor,
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Notification/chat button
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: _cardBackgroundAltColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: _primaryColor,
                      size: 20,
                    ),
                    onPressed: () {
                      // Add notification handling here
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Headline with gradient accent
            Container(
              margin: const EdgeInsets.only(bottom: 25),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryColor, _accentColor],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VENDOR DASHBOARD',
                          style: GoogleFonts.poppins(
                            color: _textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'manage your mess',
                          style: GoogleFonts.poppins(
                            color: _textSecondaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Stats card - Centered meals this week
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set width to 60% of screen width
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _cardBackgroundColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.restaurant,
                        color: _primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      totalMeals,
                      style: GoogleFonts.poppins(
                        color: _textColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'meals this week',
                      style: GoogleFonts.poppins(
                        color: _textSecondaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main content area with refined styling
  Widget _buildBodyContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title for meal status
          _buildSectionTitle('today\'s status', _sparkleEmoji, _secondaryAccent),
          const SizedBox(height: 15),

          // Today's Status section
          _buildStatusCard(),
          const SizedBox(height: 25),

          // Reviews section
          _buildSectionTitle('latest reviews', '🗣️', _primaryColor),
          const SizedBox(height: 15),
          _buildReviewsCard(),
          
          // Add some space at the bottom (removed Quick Actions section)
          const SizedBox(height: 80),
        ],
      ),
    );
  }
  
  /// Builds a section title with emoji and accent color
  Widget _buildSectionTitle(String title, String emoji, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: accentColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: _textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 6),
          Text(emoji, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  /// Builds the "Today's Status" card with clean styling
  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...todaysMealCounts.entries.map((entry) {
            return _buildMealStatusRow(
              entry.key.toLowerCase(),
              entry.value.toString(),
              _getMealColor(entry.key),
              _getMealIcon(entry.key),
            );
          }).toList(),

          // 🔽 ADDED ATTENDANCE BUTTON HERE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 12), // Only add top padding
            margin: const EdgeInsets.only(top: 12), // Add margin to separate
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: TextButton(
              onPressed: () {
                // Navigate to the attendance page
                Navigator.pushNamed(context, '/attendance_page');
              },
              style: TextButton.styleFrom(
                foregroundColor: _accentColor, // Use mint color
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'view attendance',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.people_alt_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to get appropriate icon for each meal type
  IconData _getMealIcon(String meal) {
    final lowerMeal = meal.toLowerCase();
    if (lowerMeal.contains('breakfast')) return Icons.free_breakfast_rounded;
    if (lowerMeal.contains('lunch')) return Icons.lunch_dining_rounded;
    if (lowerMeal.contains('dinner')) return Icons.dinner_dining_rounded;
    return Icons.restaurant_rounded;
  }

  // Helper to get color for each meal type
  Color _getMealColor(String meal) {
    final lowerMeal = meal.toLowerCase();
    if (lowerMeal.contains('breakfast')) return _tertiaryAccent; // Gold
    if (lowerMeal.contains('lunch')) return _secondaryAccent; // Purple
    if (lowerMeal.contains('dinner')) return _primaryColor; // Pink
    return _accentColor; // Default mint
  }

  /// Helper widget for a single row in the meal status card
  Widget _buildMealStatusRow(String meal, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: todaysMealCounts.keys.last.toLowerCase() != meal ? 
            BorderSide(color: Colors.white.withOpacity(0.05)) : 
            BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            meal,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: _textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              "$count meals",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the reviews card
  Widget _buildReviewsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (recentReviews.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 40, color: Colors.grey[700]),
                  const SizedBox(height: 10),
                  Text(
                    'no reviews yet',
                    style: GoogleFonts.poppins(
                      color: _textSecondaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (recentReviews.isNotEmpty)
            ...recentReviews.map((review) => _buildReviewItem(
              _getIcon(review['rating'] as double),
              review['message'] ?? 'No message',
              _formatTime(review['timestamp'] as Timestamp),
              _getColor(review['rating'] as double),
            )),
          
          // View all button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/vendor_feedback_page');
              },
              style: TextButton.styleFrom(
                foregroundColor: _secondaryAccent,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'view all reviews',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Review item with refined styling
  Widget _buildReviewItem(IconData icon, String message, String time, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: _textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _cardBackgroundAltColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    time,
                    style: GoogleFonts.poppins(
                      color: _textSecondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the bottom navigation bar with refined styling
  /// Builds the bottom navigation bar with refined styling
  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: _cardBackgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_rounded, isSelected: true),
              
              // 🔽 MODIFIED THIS LINE FOR ANALYTICS
              _buildNavItem(Icons.analytics_rounded, routeName: "/analytics"), 
              
              const SizedBox(width: 60), // Space for central button
              _buildNavItem(
                Icons.chat_bubble_outline_rounded,
                onTap: () {
                  Navigator.pushNamed(context, '/vendor_feedback_page');
                },
              ),
              _buildNavItem(
                Icons.person_rounded,
                routeName: "/profile_settings_page",
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper for navigation items
  Widget _buildNavItem(
    IconData icon, {
    bool isSelected = false,
    String? routeName,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        } else if (routeName != null) {
          Navigator.pushNamed(context, routeName);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? _primaryColor : Colors.grey,
          size: 22,
        ),
      ),
    );
  }
}

// Utility extension from your code
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
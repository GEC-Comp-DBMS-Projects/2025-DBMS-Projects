import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';  // Add this import
import 'package:messbuddy/menupage.dart';
import 'package:messbuddy/profile_settings_page.dart';
import 'package:messbuddy/book_meal_page.dart';
import 'package:intl/intl.dart';

void main() {
  // Ensure the status bar is styled appropriately for the Gen Z vibe
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      setState(() {
        final fullName = (doc['name'] ?? "") as String;
        username = fullName.isNotEmpty ? fullName.split(" ")[0] : "User";
      });
      if(doc['isVendor'] != null && doc['isVendor'] == true){
        Navigator.pushNamed(context, '/vendor_dashboard');
      }
    } else {
      setState(() {
        username = "User";
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

// Add this TextStyle class to create a consistent font system
class AppTextStyle {
  static TextStyle get heading => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: Colors.white,
  );
  
  static TextStyle get subheading => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static TextStyle get body => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
  
  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w300,
    color: Colors.white70,
  );
  
  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  
  static TextStyle get stat => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<String> mealTypes = [];
  late AnimationController _pulseController;

  // Refined color palette - still Gen Z but more sophisticated
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
  final Color _dangerColor = const Color(0xFFFF4D4D); // Red for errors

  // Emojis for Gen Z vibe - kept subtle
  final String _waveEmoji = "👋";
  final String _fireEmoji = "🔥";
  final String _sparkleEmoji = "✨";
  final String _rocketEmoji = "🚀";
  final String _moneyEmoji = "💸";

  Stream<DocumentSnapshot<Map<String, dynamic>>>? _activityStream;

  // Meal hours for cutoff calculation
  final Map<String, int> _mealHours = {
    'breakfast': 8,
    'lunch': 14,
    'dinner': 20,
  };

  @override
  void initState() {
    super.initState();
    _loadMenu();
    
    // Initialize pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _activityStream = FirebaseFirestore.instance.collection('recent_activity').doc(user.uid).snapshots();
    }
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadMenu() async {
    final currentDay = DateFormat('EEEE').format(DateTime.now());
    final menuDoc = await FirebaseFirestore.instance.collection('menu').doc(currentDay).get();
    if (menuDoc.exists) {
      final data = menuDoc.data()!;
      setState(() {
        mealTypes = data.keys.whereType<String>().toList();
      });
    } else {
      setState(() {
        mealTypes = ['Breakfast', 'Lunch', 'Dinner'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('pls login first', 
                style: GoogleFonts.poppins(
                  color: _textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Icon(Icons.sentiment_dissatisfied, color: _primaryColor, size: 50),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').doc(user.uid).snapshots(),
      builder: (context, bookingSnapshot) {
        if (bookingSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: _backgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('loading...', 
                    style: GoogleFonts.poppins(
                      color: _textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CircularProgressIndicator(
                    color: _accentColor,
                    strokeWidth: 3,
                  ),
                ],
              ),
            ),
          );
        }

        final bookingData = bookingSnapshot.data?.data() as Map<String, dynamic>? ?? {};
        final totalMeals = bookingData['total_meals_booked'] ?? 0;
        final totalAmount = (bookingData['total_amount'] ?? 0).toDouble();
        final rawBookings = bookingData['bookings'] ?? [];
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final todaysBookings = rawBookings.where((b) => b['date'] == todayStr).toList().cast<Map<String, dynamic>>();

        return Scaffold(
          backgroundColor: _backgroundColor,
          extendBodyBehindAppBar: true,
          extendBody: true,
          body: Stack(
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
                      _buildHeader(totalMeals, totalAmount), 
                      _buildBodyContent(todaysBookings)
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
      },
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
              Navigator.pushNamed(context, '/book_meal_page');
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
                    Icons.restaurant_menu,
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
  Widget _buildHeader(int totalMeals, double totalAmount) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildHeaderContainer("Guest", totalMeals, totalAmount, null);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildHeaderContainer("Loading...", totalMeals, totalAmount, null);
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildHeaderContainer("User", totalMeals, totalAmount, null);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final fullName = (data['name'] ?? "") as String;
        final firstName = fullName.isNotEmpty ? fullName.split(" ")[0] : "User";
        final photoURL = user.photoURL;

        return _buildHeaderContainer(firstName, totalMeals, totalAmount, photoURL);
      },
    );
  }

  /// Extracted header UI for reuse with refined styling
  Widget _buildHeaderContainer(String username, int totalMeals, double totalAmount, String? photoURL) {
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
                              image: photoURL != null ? DecorationImage(
                                image: NetworkImage(photoURL),
                                fit: BoxFit.cover,
                              ) : null,
                            ),
                            child: photoURL == null
                                ? Center(
                                    child: Text(
                                      username.isNotEmpty ? username[0].toUpperCase() : 'U',
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
                      Icons.chat_bubble_outline_rounded,
                      color: _primaryColor,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/feedback_page');
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
                          'GEC MESS',
                          style: GoogleFonts.poppins(
                            color: _textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'MessBuddy',
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
            
            // Stats cards
            Row(
              children: [
                _buildStatCard(
                  '$totalMeals', 
                  'meals this week', 
                  _primaryColor,
                  icon: Icons.restaurant,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  '₹${totalAmount.toInt()}', 
                  'Amount Spent',
                  _accentColor,
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget for the info cards in the header
  Widget _buildStatCard(String value, String label, Color color, {required IconData icon}) {
    return Expanded(
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: _textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: _textSecondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main content area with refined styling
    /// Builds the main content area with refined styling
  Widget _buildBodyContent(List<Map<String, dynamic>> todaysBookings) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          _buildSectionTitle('today\'s plan', _sparkleEmoji, _secondaryAccent),
          const SizedBox(height: 15),

          // Today's Status section
          _buildMealsCard(todaysBookings),
          const SizedBox(height: 25),

          // Activity section
          _buildSectionTitle('recent activity', '➡️', _primaryColor),
          const SizedBox(height: 15),
          if (_activityStream != null)
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _activityStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                    child: Center(
                      child: CircularProgressIndicator(
                        color: _accentColor,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return _buildActivityCard([]);
                }
                final data = snapshot.data!.data();
                final activities = (data?['activities'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];
                // Sort by timestamp descending
                activities.sort((a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));
                // Take first 2
                final recentActivities = activities.take(2).toList();
                return _buildActivityCard(recentActivities);
              },
            )
          else
            _buildActivityCard([]),
          const SizedBox(height: 25),

          // Quick actions section
          _buildSectionTitle('quick actions', _rocketEmoji, _tertiaryAccent),
          const SizedBox(height: 15),

          // Action buttons
          _buildActionButton(
            "subscribe now",
            _primaryColor,
            Icons.star_rounded,
            '/subscription_page',
            hasPulse: true,
          ),
          const SizedBox(height: 12),

          _buildActionButton(
            "view payments",
            _secondaryAccent,
            Icons.receipt_long_rounded,
            '/payment_logs_page',
          ),
          
          // Add some space at the bottom
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
  /// Builds an action button with refined styling
  Widget _buildActionButton(String text, Color color, IconData icon, String route, {bool hasPulse = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            decoration: BoxDecoration(
              color: _cardBackgroundColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: hasPulse ? [
                BoxShadow(
                  color: color.withOpacity(0.1 + (_pulseController.value * 0.1)),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ] : null,
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      text,
                      style: GoogleFonts.poppins(
                        color: _textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: color,
                  size: 18,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the meals card with clean styling
  Widget _buildMealsCard(List<Map<String, dynamic>> todaysBookings) {
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
          ...mealTypes.map((meal) {
            final isBooked = todaysBookings.any((b) => b['meal'] == meal);
            return _buildMealRow(
              StringExtension(meal).capitalize().toLowerCase(),
              isBooked ? 'booked' : 'book now',
              isBooked ? _successColor : _accentColor,
              isButton: !isBooked,
              icon: _getMealIcon(meal),
              isBooked: isBooked,
            );
          }).toList(),
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

  /// Helper widget for a single row in the meals card
  Widget _buildMealRow(
    String meal,
    String status,
    Color color, {
    bool isButton = false,
    IconData? icon,
    bool isBooked = false,
  }) {
    final canBook = _canBookMeal(meal);
    final effectiveIsButton = isButton && canBook;
    final effectiveStatus = !canBook && !isBooked ? 'booking closed' : status;
    final effectiveColor = !canBook && !isBooked ? _dangerColor : color;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: mealTypes.last.toLowerCase() != meal.toLowerCase() ? 
            BorderSide(color: Colors.white.withOpacity(0.05)) : 
            BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: effectiveColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon ?? Icons.restaurant, color: effectiveColor, size: 14),
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
            ],
          ),
          
          if (effectiveIsButton)
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/book_meal_page');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: effectiveColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      effectiveStatus,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: effectiveColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.add_rounded, color: effectiveColor, size: 16),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isBooked ? Icons.check_circle_rounded : Icons.cancel_rounded, color: effectiveColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    effectiveStatus,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: effectiveColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Checks if a meal can still be booked for today
  bool _canBookMeal(String meal) {
    final mealLower = meal.toLowerCase();
    if (!_mealHours.containsKey(mealLower)) return true; // Allow if unknown meal

    final mealHour = _mealHours[mealLower]!;
    final cutoffHour = mealHour - 4;
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day, cutoffHour);
    return now.isBefore(cutoff);
  }

  /// Builds the recent activity card with dynamic data
  Widget _buildActivityCard(List<Map<String, dynamic>> activities) {
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
          if (activities.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'no recent activities',
                  style: GoogleFonts.poppins(
                    color: _textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...activities.map((activity) {
              final activityStr = activity['activity'] as String;
              final timestamp = activity['timestamp'] as Timestamp;
              final timeAgo = _getTimeAgo(timestamp.toDate());
              final icon = _getActivityIcon(activityStr);
              final color = _getActivityColor(activityStr);
              return Column(
                children: [
                  _buildActivityItem(activityStr, timeAgo, '', icon, color),
                  if (activities.last != activity)
                    Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.05),
                    ),
                ],
              );
            }).toList(),
          if (activities.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/recent_activities_page'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'view all',
                      style: GoogleFonts.poppins(
                        color: _primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays}h ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  IconData _getActivityIcon(String activity) {
    if (activity.contains('booked')) return Icons.restaurant;
    if (activity.contains('Feedback')) return Icons.star;
    return Icons.info;
  }

  Color _getActivityColor(String activity) {
    if (activity.contains('booked')) return _primaryColor;
    if (activity.contains('Feedback')) return _accentColor;
    return _secondaryAccent;
  }

    /// Activity item with refined styling
  Widget _buildActivityItem(
    String title,
    String time,
    String description,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: _textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
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
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      color: _textSecondaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

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
              _buildNavItem(Icons.menu_rounded, routeName: "/menu_page"),
              const SizedBox(width: 60), // Space for central button
              _buildNavItem(
                Icons.rate_review_rounded,
                onTap: () {
                  _showFeedbackOptions(context);
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

  /// Shows a bottom sheet with feedback options
  void _showFeedbackOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull indicator
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Feedback title
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'your ',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    Text(
                      'feedback',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _accentColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('🗣️'),
                  ],
                ),
              ),
              
              // Feedback option
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/feedback_page');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _cardBackgroundAltColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.rate_review_rounded,
                          color: _accentColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'rate your meal',
                              style: GoogleFonts.poppins(
                                color: _textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'tell us what you thought about it',
                              style: GoogleFonts.poppins(
                                color: _textSecondaryColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: _accentColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
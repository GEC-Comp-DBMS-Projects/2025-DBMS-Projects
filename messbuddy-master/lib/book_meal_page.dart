import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class BookMealPage extends StatefulWidget {
  const BookMealPage({super.key});

  @override
  _BookMealPageState createState() => _BookMealPageState();
}

class _BookMealPageState extends State<BookMealPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  
  // Matching the color palette from the other pages
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

  // State variables for the dropdowns
  String? _selectedMeal;
  String? _selectedDietaryPreference;
  String _selectedDay = 'today';
  late AnimationController _pulseController;

  // State for loading and menu items
  bool _isLoading = true;
  bool _isBooking = false;
  List<String> _mealTypes = [];
  List<Map<String, dynamic>> _bookedMeals = [];

  final List<String> _dietaryOptions = ['veg', 'non-veg'];
  final List<String> _dayOptions = ['today', 'tomorrow'];

  // Meal hours for cutoff calculation
  final Map<String, int> _mealHours = {
    'breakfast': 8,
    'lunch': 14,
    'dinner': 20,
  };

  @override
  void initState() {
    super.initState();
    _fetchTodaysMenu();
    _fetchBookings();
    
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

  /// Fetches today's menu from Firestore
  Future<void> _fetchTodaysMenu() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch for the current day of the week (e.g., 'Tuesday')
      final String currentDayOfWeek = DateFormat('EEEE').format(DateTime.now());
      final docSnapshot =
          await _firestore.collection('menu').doc(currentDayOfWeek).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>? ?? {};
        setState(() {
          // Extract meal types (keys like 'breakfast', 'lunch', 'dinner')
          _mealTypes =
              data.keys.whereType<String>().map((k) => k.toString()).toList();
          // Ensure a consistent order if needed
          _mealTypes.sort((a, b) {
            const order = ['breakfast', 'lunch', 'dinner'];
            int indexA = order.indexOf(a.toLowerCase());
            int indexB = order.indexOf(b.toLowerCase());
            if (indexA != -1 && indexB != -1) {
              return indexA.compareTo(indexB);
            } else if (indexA != -1) {
              return -1;
            } else if (indexB != -1) {
              return 1;
            }
            return a.compareTo(b); // Fallback sort
          });

        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No menu available for today ($currentDayOfWeek).',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: _cardBackgroundAltColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load menu: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _cardBackgroundAltColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  /// Fetches user's booked meals from Firestore
  Future<void> _fetchBookings() async {
    if (_currentUser == null) return;

    try {
      final doc = await _firestore.collection('bookings').doc(_currentUser.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final rawBookings = data['bookings'];
        if (rawBookings is List) {
          setState(() {
            _bookedMeals = rawBookings.map((e) => Map<String, dynamic>.from(e)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch bookings: $e');
    }
  }

  /// Handles booking confirmation logic
  Future<void> _confirmBooking() async {
    if (_selectedMeal == null || _selectedDietaryPreference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'please select both a meal and a preference.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _cardBackgroundAltColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'you must be logged in to book a meal.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _cardBackgroundAltColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      // Determine booking date
      DateTime bookingDate = DateTime.now();
      if (_selectedDay == 'tomorrow') {
        bookingDate = bookingDate.add(const Duration(days: 1));
      }
      final formattedDate = DateFormat('yyyy-MM-dd').format(bookingDate);

      // Check booking cutoff time (4 hours before meal)
      final mealLower = _selectedMeal!.toLowerCase();
      if (_mealHours.containsKey(mealLower)) {
        final mealHour = _mealHours[mealLower]!;
        final cutoffHour = mealHour - 4;
        final cutoff = DateTime(bookingDate.year, bookingDate.month, bookingDate.day, cutoffHour);
        final now = DateTime.now();
        if (now.isAfter(cutoff)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Booking for ${StringExtension(_selectedMeal!).capitalize()} on $_selectedDay is closed. You can only book until 4 hours before the meal time.',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: _cardBackgroundAltColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          setState(() {
            _isBooking = false;
          });
          return;
        }
      }

      // Check if already booked (only one preference per meal per day)
      final alreadyBooked = _bookedMeals.any((b) =>
          b['date'] == formattedDate &&
          b['meal'] == _selectedMeal);
      
      if (alreadyBooked) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'this meal is already booked for the selected day. you can only book one preference per meal.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: _cardBackgroundAltColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        setState(() {
          _isBooking = false;
        });
        return;
      }

      // Calculate price
      int price = 0;
      final meal = _selectedMeal!.toLowerCase();
      final pref = _selectedDietaryPreference!.toLowerCase();

      // Example pricing logic (adapt as needed)
      if (meal == 'breakfast') {
        price = 50;
      } else if (pref == 'veg') {
        price = 70;
      } else if (pref == 'non-veg') {
        price = 80;
      }

      // Create booking record
      final bookingData = {
        'meal': _selectedMeal,
        'preference': _selectedDietaryPreference,
        'price': price,
        'timestamp': Timestamp.now(),
        'date': formattedDate,
        'day_type': _selectedDay,
      };

      final bookingRef =
          _firestore.collection('bookings').doc(_currentUser.uid);

      // --- Update User's Personal Bookings ---
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(bookingRef);

        if (!doc.exists) {
          transaction.set(bookingRef, {
            'bookings': [bookingData],
            'total_amount': price,
            'total_meals_booked': 1,
          });
          return;
        }
        final Map<String, dynamic> existingData = doc.data() ?? {};
        final rawBookings = existingData['bookings'];
        final List<Map<String, dynamic>> currentBookings = [];
        if (rawBookings is List) {
          for (final item in rawBookings) {
            if (item is Map) {
              try {
                currentBookings.add(Map<String, dynamic>.from(item));
              } catch (_) {}
            }
          }
        }
        final rawTotal = existingData['total_amount'];
        int currentTotal = 0;
        if (rawTotal is int) {
          currentTotal = rawTotal;
        } else if (rawTotal is num) {
          currentTotal = rawTotal.toInt();
        }
        final rawMeals = existingData['total_meals_booked'];
        int currentMeals = 0;
        if (rawMeals is int) {
          currentMeals = rawMeals;
        } else if (rawMeals is num) {
          currentMeals = rawMeals.toInt();
        }
        currentBookings.add(bookingData);
        transaction.update(bookingRef, {
          'bookings': currentBookings,
          'total_amount': currentTotal + price,
          'total_meals_booked': currentMeals + 1,
        });
      });

      // ========================================================
      // ⬇️ MODIFIED CODE TO UPDATE ATTENDANCE WITH ARRAY
      // ========================================================
      // Get the reference to the meal document within the date document
      final attendanceMealRef = _firestore
          .collection('attendance')
          .doc(formattedDate) // e.g., "2025-10-28"
          .collection('meals') // New subcollection
          .doc(_selectedMeal!); // e.g., "lunch"

      // Prepare the data to add to the array
      final attendeeData = {
        'userId': _currentUser.uid,
        'preference': _selectedDietaryPreference,
        'timestamp': Timestamp.now(),
      };

      // Use FieldValue.arrayUnion to add the user to the 'attendees' array.
      // SetOptions(merge: true) ensures the document is created if it doesn't exist,
      // and updates the array field without overwriting other potential fields.
      await attendanceMealRef.set({
        'attendees': FieldValue.arrayUnion([attendeeData])
      }, SetOptions(merge: true));
      // ========================================================
      // ⬆️ END OF MODIFIED BLOCK
      // ========================================================


      // --- Update Recent Activity ---
      await _firestore.collection('recent_activity').doc(_currentUser.uid).set({
        'activities': FieldValue.arrayUnion([
          {
            'activity': '${_selectedMeal!.capitalize()} booked',
            'timestamp': Timestamp.now(),
          }
        ]),
      }, SetOptions(merge: true));

      // --- Show Success Message & Update UI ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully booked $_selectedMeal for $_selectedDay! $_selectedDietaryPreference menu 🍽️',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _cardBackgroundAltColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: 'Yay!',
            textColor: _successColor,
            onPressed: () {},
          ),
        ),
      );

      await _fetchBookings(); // Refresh the local list of booked meals
      Navigator.of(context).pop(); // Go back after success

    } catch (e, st) {
      debugPrint('Booking failed: $e');
      debugPrint('$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to book meal: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _cardBackgroundAltColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      setState(() {
        _isBooking = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final DateTime tomorrow = today.add(const Duration(days: 1));
    final String todayStr = DateFormat('yyyy-MM-dd').format(today);
    final String tomorrowStr = DateFormat('yyyy-MM-dd').format(tomorrow);

    final todaysBookings = _bookedMeals.where((b) => b['date'] == todayStr).toList();
    final tomorrowsBookings = _bookedMeals.where((b) => b['date'] == tomorrowStr).toList();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'book meal',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: _textColor,
          ),
        ),
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: _textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
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
          
          // Background accent circles
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
          _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: _accentColor,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'loading menu...',
                        style: GoogleFonts.poppins(
                          color: _textSecondaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page title
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
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
                                      'ready to eat?',
                                      style: GoogleFonts.poppins(
                                        color: _textColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Text(
                                      'book your meals in advance to avoid long queues 🍽️',
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
                        
                        const SizedBox(height: 20),
                        
                        // Enhanced Meal Status Card
                        _buildMealStatusCard(todaysBookings, tomorrowsBookings),
                        
                        const SizedBox(height: 25),
                        
                        Text(
                          'make a booking',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'fill in the details below',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: _textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 15),
                        
                        // Booking Form
                        _buildDropdownCard(
                          title: 'meal type',
                          icon: Icons.restaurant_menu_rounded,
                          hint: 'choose meal type',
                          value: _selectedMeal,
                          items: _mealTypes,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedMeal = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 15),
                        _buildDropdownCard(
                          title: 'dietary preference',
                          icon: Icons.fastfood_rounded,
                          hint: 'select dietary preference',
                          value: _selectedDietaryPreference,
                          items: _dietaryOptions,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedDietaryPreference = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 15),
                        _buildDropdownCard(
                          title: 'booking day',
                          icon: Icons.calendar_today_rounded,
                          hint: 'select day',
                          value: _selectedDay,
                          items: _dayOptions,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedDay = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.2 + (_pulseController.value * 0.1)),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  _primaryColor,
                  _secondaryAccent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: ElevatedButton(
              onPressed: _isBooking ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                disabledBackgroundColor: Colors.transparent,
              ),
              child: _isBooking
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: _textColor,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'confirm booking',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          );
        }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  Widget _buildMealStatusCard(List<Map<String, dynamic>> todaysBookings, List<Map<String, dynamic>> tomorrowsBookings) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  color: _accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'meal status',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Use IntrinsicHeight to ensure both columns have the same height
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today
                Expanded(
                  child: _buildDayColumn('today', todaysBookings),
                ),
                const SizedBox(width: 15),
                // Tomorrow
                Expanded(
                  child: _buildDayColumn('tomorrow', tomorrowsBookings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDayColumn(String day, List<Map<String, dynamic>> bookings) {
    // Calculate minimum height to ensure consistency
    double minItemHeight = 80.0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: day == 'today' ? _primaryColor.withOpacity(0.1) : _secondaryAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: day == 'today' ? _primaryColor.withOpacity(0.3) : _secondaryAccent.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            day,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: day == 'today' ? _primaryColor : _secondaryAccent,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 15),
        // Wrap meal items in a Column with fixed size options
        ..._mealTypes.map((meal) {
          final booking = bookings.firstWhere(
            (b) => b['meal'] == meal,
            orElse: () => <String, dynamic>{},
          );
          final isBooked = booking.isNotEmpty;
          final preference = booking['preference'] ?? '';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            width: double.infinity, // Ensure full width
            height: minItemHeight, // Set fixed height
            decoration: BoxDecoration(
              color: _cardBackgroundAltColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isBooked 
                  ? _successColor.withOpacity(0.3) 
                  : Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
              children: [
                Text(
                  StringExtension(meal).capitalize(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Status indicator with consistent size
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isBooked 
                      ? _successColor.withOpacity(0.1) 
                      : _dangerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isBooked 
                        ? _successColor.withOpacity(0.3) 
                        : _dangerColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isBooked ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size: 14,
                        color: isBooked ? _successColor : _dangerColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isBooked ? preference : 'not booked',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isBooked ? _successColor : _dangerColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
  
  /// Reusable widget for dropdowns with fixed height and proper sizing
  Widget _buildDropdownCard({
    required String title,
    required IconData icon,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _secondaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: _secondaryAccent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Container with fixed height for the dropdown
          Container(
            height: 56, // Fixed height for consistent sizing
            decoration: BoxDecoration(
              color: _cardBackgroundAltColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: ButtonTheme(
              alignedDropdown: true, // Align the dropdown items
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: _textSecondaryColor),
                  iconSize: 24,
                  elevation: 16,
                  dropdownColor: _cardBackgroundAltColor,
                  style: GoogleFonts.poppins(
                    color: _textColor,
                    fontSize: 15,
                  ),
                  hint: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      hint,
                      style: GoogleFonts.poppins(
                        color: _textSecondaryColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  items: items.map<DropdownMenuItem<String>>((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          item == 'veg' || item == 'non-veg' 
                            ? item 
                            : StringExtension(item).capitalize(),
                          style: GoogleFonts.poppins(
                            color: _textColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
     if (this.isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}


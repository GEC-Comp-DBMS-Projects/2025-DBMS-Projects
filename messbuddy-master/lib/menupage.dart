import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

// Main page widget that fetches and displays the menu
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});
  // Support for selecting any day's menu
  static const List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with SingleTickerProviderStateMixin {
  late Future<DocumentSnapshot> _menuFuture;
  late String _selectedDay;
  late AnimationController _pulseController;
  
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
  
  // Food type icons
  final Map<String, IconData> _foodIcons = {
    'breakfast': Icons.free_breakfast_rounded,
    'lunch': Icons.lunch_dining_rounded,
    'dinner': Icons.dinner_dining_rounded,
  };
  
  // Food type colors
  final Map<String, Color> _foodColors = {
    'breakfast': const Color(0xFFFF9E2C), // Orange
    'lunch': const Color(0xFF04E9CC), // Teal
    'dinner': const Color(0xFF7F5AF7), // Purple
  };

  // Food category icons
  final Map<String, IconData> _categoryIcons = {
    'rice': Icons.rice_bowl_rounded,
    'bread': Icons.bakery_dining_rounded,
    'curry': Icons.soup_kitchen_rounded,
    'dessert': Icons.icecream_rounded,
    'drink': Icons.local_drink_rounded,
    'fruit': Icons.emoji_food_beverage_rounded,
    'vegetable': Icons.eco_rounded,
    'snack': Icons.fastfood_rounded,
    'chicken': Icons.dining_rounded,
    'meat': Icons.set_meal_rounded,
    'fish': Icons.set_meal_rounded,
    'egg': Icons.egg_rounded,
    'dal': Icons.soup_kitchen_rounded,
    'paneer': Icons.food_bank_rounded,
    'roti': Icons.flatware_rounded,
    'paratha': Icons.flatware_rounded,
    'idli': Icons.food_bank_rounded,
    'dosa': Icons.food_bank_rounded,
    'soup': Icons.soup_kitchen_rounded,
    'salad': Icons.eco_rounded,
    'tea': Icons.emoji_food_beverage_rounded,
    'coffee': Icons.coffee_rounded,
    'juice': Icons.local_drink_rounded,
    'milk': Icons.local_cafe_rounded,
    'curd': Icons.local_cafe_rounded,
    'default': Icons.restaurant_rounded,
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = DateFormat('EEEE').format(DateTime.now());
    _menuFuture = _fetchMenuForDay(_selectedDay);
    
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

  Future<DocumentSnapshot> _fetchMenuForDay(String day) {
    return FirebaseFirestore.instance.collection('menu').doc(day).get();
  }
  
  // Get appropriate icon for food item based on keywords
  IconData _getIconForFoodItem(String item) {
    item = item.toLowerCase();
    for (final entry in _categoryIcons.entries) {
      if (item.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return _categoryIcons['default']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'menu',
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
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with day selection
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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
                              'weekly menu',
                              style: GoogleFonts.poppins(
                                color: _textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'check what\'s cooking today 🍽️',
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
                
                // Day selector
                _buildDaySelector(),
                
                // Menu content
                Expanded(
                  child: FutureBuilder<DocumentSnapshot>(
                    future: _menuFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
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
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "something went wrong!",
                            style: GoogleFonts.poppins(
                              color: _textColor,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return _buildEmptyState();
                      }

                      var menuData = snapshot.data!.data() as Map<String, dynamic>;
                      
                      // Extract menu items for each meal type
                      String breakfastItems = menuData['breakfast'] ?? 'Not available';
                      String lunchItems = menuData['lunch'] ?? 'Not available';
                      String dinnerItems = menuData['dinner'] ?? 'Not available';

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: Column(
                          children: [
                            _buildMenuCard('breakfast', breakfastItems),
                            const SizedBox(height: 20),
                            _buildMenuCard('lunch', lunchItems),
                            const SizedBox(height: 20),
                            _buildMenuCard('dinner', dinnerItems),
                            const SizedBox(height: 30),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Day selector carousel
  Widget _buildDaySelector() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: MenuPage.daysOfWeek.length,
        itemBuilder: (context, index) {
          final day = MenuPage.daysOfWeek[index];
          final isSelected = _selectedDay == day;
          
          // Check if day is today
          final today = DateFormat('EEEE').format(DateTime.now());
          final isToday = day == today;
          
          return AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = day;
                    _menuFuture = _fetchMenuForDay(day);
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    gradient: isSelected ? LinearGradient(
                      colors: [
                        _primaryColor.withOpacity(0.7),
                        _secondaryAccent.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ) : null,
                    color: isSelected ? null : _cardBackgroundColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected
                        ? _primaryColor.withOpacity(0.5)
                        : (isToday ? _accentColor.withOpacity(0.5) : Colors.transparent),
                      width: isSelected || isToday ? 1.5 : 0,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.2 + (_pulseController.value * 0.1)),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ] : null,
                  ),
                  child: Center(
                    child: Text(
                      day.substring(0, 3).toLowerCase(),
                      style: GoogleFonts.poppins(
                        color: isSelected ? _textColor : (isToday ? _accentColor : _textSecondaryColor),
                        fontSize: 15,
                        fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  // Empty state when no menu is available
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: _cardBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              size: 70,
              color: _textSecondaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "menu not available for $_selectedDay",
            style: GoogleFonts.poppins(
              color: _textColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "check back later or try another day",
            style: GoogleFonts.poppins(
              color: _textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  // Enhanced menu card with icons and visual elements
  Widget _buildMenuCard(String mealType, String menuItems) {
    final itemsList = menuItems.split('\n');
    final mealTitle = mealType.capitalize();
    final mealIcon = _foodIcons[mealType.toLowerCase()] ?? Icons.restaurant;
    final mealColor = _foodColors[mealType.toLowerCase()] ?? _primaryColor;
    
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with meal type and icon
          Container(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  mealColor.withOpacity(0.3),
                  _cardBackgroundColor,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: mealColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: mealColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    mealIcon,
                    color: mealColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  mealTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: mealColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: mealColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getMealTimeText(mealType),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: mealColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Menu items
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: itemsList.map((item) {
                // Skip empty items
                if (item.trim().isEmpty) return const SizedBox.shrink();
                
                // Get appropriate icon for food item
                final itemIcon = _getIconForFoodItem(item);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: mealColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          itemIcon,
                          color: mealColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.trim(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: _textSecondaryColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  // Get time text for meal type
  String _getMealTimeText(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return '8:00 - 9:00';
      case 'lunch':
        return '1:00 - 2:00';
      case 'dinner':
        return '8:00 - 9:00';
      default:
        return '';
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Matching the color palette from your BookMealPage
  final Color _backgroundColor = const Color(0xFF0A0A0A);
  final Color _cardBackgroundColor = const Color(0xFF161616);
  final Color _cardBackgroundAltColor = const Color(0xFF1A1A1A);
  final Color _primaryColor = const Color(0xFFFF2D55); // Hot pink
  final Color _accentColor = const Color(0xFF04E9CC); // Refined mint
  final Color _secondaryAccent = const Color(0xFF7F5AF7); // Purple
  final Color _textColor = Colors.white;
  final Color _textSecondaryColor = Colors.white70;
  final Color _successColor = const Color(0xFF33FF99); // Mint green

  // State variables
  String _selectedMeal = 'breakfast'; // Default selected meal
  bool _isLoading = true;
  List<Map<String, dynamic>> _attendees = [];

  @override
  void initState() {
    super.initState();
    // Fetch attendees for the default meal when the page loads
    _fetchAttendees();
  }

  /// Fetches attendees for the currently selected meal and today's date
  Future<void> _fetchAttendees() async {
    setState(() {
      _isLoading = true;
      _attendees = []; // Clear the list while loading
    });

    try {
      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // 1. Get the single meal document (e.g., 'lunch')
      final mealDoc = await _firestore
          .collection('attendance')
          .doc(today)
          .collection('meals') // Use 'meals' subcollection
          .doc(_selectedMeal) // Get the document for the selected meal
          .get();

      if (!mealDoc.exists) {
        // No document for this meal, so no attendees
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 2. Get the 'attendees' array from the document
      final data = mealDoc.data();
      final List<dynamic> attendeesArray = data?['attendees'] ?? [];

      if (attendeesArray.isEmpty) {
        // The array is empty, so no attendees
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 3. Create a list of futures to fetch each user's data
      List<Future<Map<String, dynamic>>> futures = [];

      for (final attendeeData in attendeesArray) {
        if (attendeeData is Map<String, dynamic>) {
          final userId = attendeeData['userId'] as String?;
          final preference = attendeeData['preference'] as String? ?? 'N/A';
          // ========================================================
          // ⬇️ GET THE NEW 'attended' FIELD
          // ========================================================
          final attended = attendeeData['attended'] as bool? ?? false; // Default to false
          // ========================================================
          
          if (userId != null) {
            // ========================================================
            // ⬇️ PASS 'attended' STATUS TO THE HELPER
            // ========================================================
            futures.add(_fetchUserData(userId, preference, attended));
            // ========================================================
          }
        }
      }

      // 4. Wait for all user data to be fetched
      final results = await Future.wait(futures);

      // 5. Update the state with the combined list
      setState(() {
        _attendees = results;
        _isLoading = false;
      });

    } catch (e) {
      debugPrint('Error fetching attendees: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load attendees: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _cardBackgroundAltColor,
        ),
      );
    }
  }

  /// Helper function to fetch a single user's data from the 'users' collection
  Future<Map<String, dynamic>> _fetchUserData(String userId, String preference, bool attended) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return {
          'id': userId,
          'name': userData['name'] ?? 'Unknown User', // Use 'name' field
          'preference': preference,
          'attended': attended, // ⬅️ Add attended status to the list
        };
      } else {
        return {
          'id': userId,
          'name': 'User not found',
          'preference': preference,
          'attended': attended, // ⬅️ Add attended status to the list
        };
      }
    } catch (e) {
      debugPrint('Error fetching user data for $userId: $e');
      return {
        'id': userId,
        'name': 'Error loading name',
        'preference': preference,
        'attended': attended, // ⬅️ Add attended status to the list
      };
    }
  }

  // ========================================================
  // ⬇️ NEW FUNCTION TO UPDATE ATTENDANCE
  // ========================================================
  /// Toggles the 'attended' status for a user in Firestore
  Future<void> _toggleAttendance(String userId, bool currentStatus) async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final docRef = _firestore
        .collection('attendance')
        .doc(today)
        .collection('meals')
        .doc(_selectedMeal);

    final bool newStatus = !currentStatus;

    try {
      // Use a transaction to safely read-modify-write the array
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) return;

        final data = doc.data();
        final List<dynamic> attendeesArray = data?['attendees'] ?? [];

        // Find and update the specific user in the array
        final List<Map<String, dynamic>> newAttendeesArray = [];
        for (var item in attendeesArray) {
          if (item is Map<String, dynamic>) {
            if (item['userId'] == userId) {
              // This is the user, update their status
              item['attended'] = newStatus;
            }
            newAttendeesArray.add(item);
          }
        }
        // Write the entire updated array back
        transaction.update(docRef, {'attendees': newAttendeesArray});
      });

      // Optimistically update the local UI to feel fast
      setState(() {
        final index = _attendees.indexWhere((a) => a['id'] == userId);
        if (index != -1) {
          _attendees[index]['attended'] = newStatus;
        }
      });
    } catch (e) {
      debugPrint("Failed to update attendance: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e', style: GoogleFonts.poppins()),
          backgroundColor: _cardBackgroundAltColor,
        ),
      );
    }
  }
  // ========================================================
  // ⬆️ END OF NEW FUNCTION
  // ========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'attendance',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
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
      body: Column(
        children: [
          _buildMealSelector(),
          Expanded(
            child: _buildAttendeeList(),
          ),
        ],
      ),
    );
  }

  /// Builds the "Breakfast", "Lunch", "Dinner" selection buttons
  Widget _buildMealSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: SegmentedButton<String>(
        selected: {_selectedMeal},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _selectedMeal = newSelection.first;
          });
          _fetchAttendees(); // Fetch data for the new selection
        },
        style: SegmentedButton.styleFrom(
          backgroundColor: _cardBackgroundAltColor,
          selectedBackgroundColor: _primaryColor,
          selectedForegroundColor: _textColor,
          foregroundColor: _textSecondaryColor,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        segments: const [
          ButtonSegment(
            value: 'breakfast',
            label: Text('Breakfast'),
            icon: Icon(Icons.free_breakfast_rounded),
          ),
          ButtonSegment(
            value: 'lunch',
            label: Text('Lunch'),
            icon: Icon(Icons.lunch_dining_rounded),
          ),
          ButtonSegment(
            value: 'dinner',
            label: Text('Dinner'),
            icon: Icon(Icons.dinner_dining_rounded),
          ),
        ],
      ),
    );
  }

  /// Builds the list of attendees based on the current state
  Widget _buildAttendeeList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: _accentColor),
      );
    }

    if (_attendees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_food_rounded, color: _textSecondaryColor, size: 60),
            const SizedBox(height: 16),
            Text(
              'no attendees found',
              style: GoogleFonts.poppins(
                color: _textSecondaryColor,
                fontSize: 16,
              ),
            ),
            Text(
              'no one has booked $_selectedMeal for today.',
              style: GoogleFonts.poppins(
                color: _textSecondaryColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // If we have data, build the list
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _attendees.length,
      itemBuilder: (context, index) {
        final attendee = _attendees[index];
        final bool isVeg = attendee['preference'] == 'veg';
        // ========================================================
        // ⬇️ GET STATUS & ID FOR THE BUTTON
        // ========================================================
        final bool hasAttended = attendee['attended'] as bool;
        final String userId = attendee['id'] as String;
        // ========================================================
        
        return Card(
          color: _cardBackgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isVeg
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              child: Icon(
                isVeg ? Icons.eco_rounded : Icons.fastfood_rounded,
                color: isVeg ? Colors.green[300] : Colors.red[300],
                size: 20,
              ),
            ),
            title: Text(
              attendee['name'],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: _textColor,
              ),
            ),
            subtitle: Text(
              attendee['preference'],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                color: _textSecondaryColor,
              ),
            ),
         
            trailing: IconButton(
              icon: Icon(
                hasAttended
                    ? Icons.check_circle_rounded  // The "tick"
                    : Icons.radio_button_unchecked_rounded, // The "cross" (or pending)
                color: hasAttended ? _successColor : _textSecondaryColor,
                size: 28,
              ),
              onPressed: () {
                // Call the toggle function
                _toggleAttendance(userId, hasAttended);
              },
            ),
          ),
        );
      },
    );
  }
}

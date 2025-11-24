import 'package:app/screens/events/chatbot.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/AddEventDialog.dart';
import '../models/EventDetailsDialog.dart';
import 'events/all_event.dart';
import 'package:app/screens/profile.dart';
import 'events/my_space_page.dart';

class HomePage extends StatefulWidget {
  final String role;
  final String uid;

  const HomePage({super.key, required this.role, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isDarkMode = true; // Track theme mode

  Stream<QuerySnapshot> get _eventsStream => _firestore
      .collection('crowdr')
      .doc('events')
      .collection('events')
      .orderBy('createdAt', descending: true)
      .snapshots();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Toggle theme mode
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  // Filter events based on search query
  List<QueryDocumentSnapshot> _filterEvents(List<QueryDocumentSnapshot> events) {
    if (_searchQuery.isEmpty) {
      return events;
    }
    
    return events.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = (data['title'] ?? '').toString().toLowerCase();
      final description = (data['description'] ?? '').toString().toLowerCase();
      final location = (data['location'] ?? '').toString().toLowerCase();
      final category = (data['category'] ?? '').toString().toLowerCase();
      
      return title.contains(_searchQuery) ||
             description.contains(_searchQuery) ||
             location.contains(_searchQuery) ||
             category.contains(_searchQuery);
    }).toList();
  }

  void _addEvent() {
    showDialog(
      context: context,
      builder: (context) => AddEventDialog(
        onAdd: (eventData) async {
          await _firestore
              .collection('crowdr')
              .doc('events')
              .collection('events')
              .add({
            'title': eventData['title'],
            'description': eventData['description'],
            'location': eventData['location'],
            'date': eventData['date'],
            'createdBy': FirebaseAuth.instance.currentUser!.uid,
            'time': eventData['time'],
            'category': eventData['category'],
            'contactNumber': eventData['contactNumber'],
            'fee': eventData['fee'],
            'organizerId': widget.uid,
            'createdAt': Timestamp.fromDate(eventData['createdAt']),
            'attendeesCount': 0,
          });
        },
        uid: widget.uid,
        role: widget.role,
      ),
    );
  }

  void _editEvent(Map<String, dynamic> eventData, String docId) {
    showDialog(
      context: context,
      builder: (context) => AddEventDialog(
        eventData: eventData,
        onAdd: (updatedData) async {
          await _firestore
              .collection('crowdr')
              .doc('events')
              .collection('events')
              .doc(docId)
              .update({
            'title': updatedData['title'],
            'description': updatedData['description'],
            'location': updatedData['location'],
            'date': updatedData['date'],
            'time': updatedData['time'],
            'category': updatedData['category'],
            'contactNumber': updatedData['contactNumber'],
            'fee': updatedData['fee'],
          });
        },
        uid: widget.uid,
        role: widget.role,
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> eventData, String eventId, bool isOwner) {
    showDialog(
      context: context,
      builder: (context) => EventDetailsDialog(
        eventData: eventData,
        eventId: eventId,
        isOwner: isOwner,
      ),
    );
  }

  void _logout() async {
    await _auth.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOrganizer = widget.role.toLowerCase() == "organizer";

    // Theme colors
    final backgroundColor = _isDarkMode ? Colors.black : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black;
    final textColorSecondary = _isDarkMode ? Colors.white70 : Colors.black54;
    final textColorTertiary = _isDarkMode ? Colors.white54 : Colors.black45;
    final cardColor = _isDarkMode ? Colors.grey[850] : Colors.grey[200];
    final searchBarColor = _isDarkMode ? Colors.grey[900] : Colors.grey[300];
    final gradientStart = _isDarkMode ? const Color(0xFF5A00FF) : const Color(0xFFB39DDB);
    final gradientEnd = _isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: isOrganizer
          ? FloatingActionButton(
              backgroundColor: Colors.yellow[700],
              onPressed: _addEvent,
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _eventsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Something went wrong", style: TextStyle(color: textColor)));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: textColor));
            }

            final allEvents = snapshot.data!.docs;
            final filteredEvents = _filterEvents(allEvents);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Gradient Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [gradientStart, gradientEnd],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Crowdr.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  onPressed: _toggleTheme,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProfilePage(
                                          uid: widget.uid,
                                          role: widget.role,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 🔹 Working Search bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: searchBarColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search for artists, events and festivals...",
                              hintStyle: TextStyle(color: textColorTertiary),
                              icon: Icon(Icons.search, color: textColorTertiary),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear, color: textColorTertiary),
                                      onPressed: () {
                                        _searchController.clear();
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 🔹 Navigation Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _NavItem(
                              icon: Icons.home,
                              label: "HOME",
                              active: true,
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HomePage(role: widget.role, uid: widget.uid),
                                  ),
                                );
                              },
                            ),
                            _NavItem(
                              icon: Icons.music_note,
                              label: "EVENTS",
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AllEventsPage(uid: widget.uid),
                                  ),
                                );
                              },
                            ),
                            _NavItem(
                              icon: Icons.chat_bubble_outline,
                              label: "CHATBOT",
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatbotPage(
                                      uid: widget.uid,
                                      role: widget.role,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _NavItem(
                              icon: Icons.person_outline,
                              label: "MY-SPACE",
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MySpacePage(
                                      role: widget.role,
                                      uid: widget.uid,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 🔹 Search Results Info
                  if (_searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        "Found ${filteredEvents.length} event${filteredEvents.length != 1 ? 's' : ''} for '$_searchQuery'",
                        style: TextStyle(color: textColorSecondary, fontSize: 14),
                      ),
                    ),

                  // 🔹 Display search results or regular sections
                  if (_searchQuery.isNotEmpty)
                    _buildEventSection("Search Results", filteredEvents, textColor, textColorSecondary, textColorTertiary, cardColor)
                  else ...[
                    _buildEventSection("Featured Events", filteredEvents, textColor, textColorSecondary, textColorTertiary, cardColor),
                    _buildEventSection("Events based on interest", filteredEvents, textColor, textColorSecondary, textColorTertiary, cardColor),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventSection(String title, List<QueryDocumentSnapshot> events, Color textColor, Color textColorSecondary, Color textColorTertiary, Color? cardColor) {
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            "No events found",
            style: TextStyle(color: textColorSecondary, fontSize: 16),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
              if (_searchQuery.isEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllEventsPage(uid: widget.uid),
                      ),
                    );
                  },
                  child: const Text("View All", style: TextStyle(color: Colors.yellow)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: events.length,
              itemBuilder: (context, index) {
                final doc = events[index];
                final data = doc.data() as Map<String, dynamic>;
                final isOwner = data['organizerId'] == widget.uid;

                return GestureDetector(
                  onTap: () => _showEventDetails(data, doc.id, isOwner),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Placeholder event image
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            image: const DecorationImage(
                              image: AssetImage('assets/event1.jpeg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['title'] ?? 'Untitled Event',
                                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("📅 ${data['date'] ?? ''} ${data['time'] ?? ''}",
                                  style: TextStyle(color: textColorSecondary, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text("📍 ${data['location'] ?? ''}",
                                  style: TextStyle(color: textColorTertiary, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? Colors.blue : Colors.grey),
          Text(label, style: TextStyle(color: active ? Colors.blue : Colors.grey)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:frontend/custom_header.dart';
import 'package:frontend/notifications.dart';
import 'package:google_fonts/google_fonts.dart';

class JobListingScreen extends StatefulWidget {
  const JobListingScreen({Key? key}) : super(key: key);

  @override
  State<JobListingScreen> createState() => _JobListingScreenState();
}

class _JobListingScreenState extends State<JobListingScreen> {
  int _selectedIndex = 1;
  final Color primaryColor = const Color(0xFF5D9493);
  final Color secondaryColor = const Color(0xFF8CA1A4);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);

  String _selectedFilter = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> jobs = [
    {
      'title': 'Software Engineer',
      'company': 'Innovate Inc.',
      'location': 'Bengaluru, India',
      'tags': ['Full Time', 'Remote'],
      'initial': 'G',
    },
    {
      'title': 'Associate Software Engineer',
      'company': 'Innovate Inc.',
      'location': 'Pune, India',
      'tags': ['Full Time', 'Remote'],
      'initial': 'G',
    },
    {
      'title': 'Associate Analyst',
      'company': 'Germinate',
      'location': 'Goa, India',
      'tags': ['Full Time', 'On-site'],
      'initial': 'G',
    },
    {
      'title': 'Full Stack Web Developer',
      'company': 'Innovate Inc.',
      'location': 'Pune, India',
      'tags': ['Full Time', 'On-site'],
      'initial': 'G',
    },
    {
      'title': 'Project Manager',
      'company': 'Innovate Inc.',
      'location': 'Goa, India',
      'tags': ['Full Time', 'On-site'],
      'initial': 'G',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [secondaryColor, grayColor, primaryColor],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Dynamic Island
                  Container(
                    width: 150,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                  // Header
                  CustomAppHeader(onProfileTap: ()=> setState(()=> _selectedIndex=4) , onNotificationTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage())), primaryColor: primaryColor, darkColor: darkColor, lightColor: lightColor),
                  // Search Bar
                  _buildSearchBar(),
                  // Filter Chips
                  _buildFilterChips(),
                  SizedBox(height: 16),
                  // Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Find Jobs',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: lightColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Job List
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: jobs.length,
                      itemBuilder: (context, index) => _buildJobCard(jobs[index]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: _buildFloatingNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: lightColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: darkColor.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: GoogleFonts.montserrat(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search by role, company, or keyword',
            hintStyle: GoogleFonts.montserrat(
              color: grayColor.withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon: Icon(Icons.menu, color: grayColor),
            suffixIcon: Icon(Icons.search, color: grayColor),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Full Time', 'Internship', 'Remote', 'On-site'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) => _buildFilterChip(filter)).toList(),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedFilter = isSelected ? '' : label;
      }),
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.2)
              : lightColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : grayColor.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            color: isSelected ? primaryColor : darkColor,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: darkColor.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    job['initial'],
                    style: GoogleFonts.montserrat(
                      color: primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'],
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      job['company'],
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: grayColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      job['location'],
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: grayColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: (job['tags'] as List<String>).map((tag) {
              final isRemote = tag == 'Remote';
              final isOnsite = tag == 'On-site';
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isRemote || isOnsite
                        ? primaryColor.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: isRemote || isOnsite ? primaryColor : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: lightColor,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply Now',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bookmark_outline,
                  color: primaryColor,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: darkColor.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavIcon(Icons.home_outlined, 0),
          _buildNavIcon(Icons.search, 1),
          _buildNavIcon(Icons.bookmark_outline, 2),
          _buildNavIcon(Icons.notifications_outlined, 3),
          _buildNavIcon(Icons.person_outline, 4),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Icon(
        icon,
        size: 28,
        color: _selectedIndex == index ? primaryColor : grayColor,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
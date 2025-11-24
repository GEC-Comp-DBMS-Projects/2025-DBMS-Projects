import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  // --- Theme ---
  final Color primaryColor = const Color(0xFF5D9493);
  final Color secondaryColor = const Color(0xFF8CA1A4);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);

  // --- State ---
  List<dynamic> _allStudents = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String _selectedFilter = 'All'; // 'All', 'Placed', 'Unplaced'
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> fetchStudents() async {
    final token = await getToken();
    if (token.isEmpty) {
      print('No token found');
      setState(() => _isLoading = false);
      return;
    }

    final url = Uri.parse('https://campusnest-backend-lkue.onrender.com/api/v1/tpo/students');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Students data: $data');
        setState(() {
          _allStudents = data['students'] ?? [];
          _stats = data['statistics'] ?? {};
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching students: $e');
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> getFilteredStudents() {
    List<dynamic> filtered = _allStudents;

    if (_selectedFilter == 'Placed') {
      filtered = _allStudents.where((s) => (s['placementStatus'] ?? '').toString().toLowerCase() == 'placed').toList();
    } else if (_selectedFilter == 'Unplaced') {
      filtered = _allStudents.where((s) => (s['placementStatus'] ?? '').toString().toLowerCase() != 'placed').toList();
    }

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((s) {
        final name = "${s['firstName'] ?? ''} ${s['lastName'] ?? ''}".toLowerCase();
        final skills = (s['skills'] as List<dynamic>? ?? []).join(' ').toLowerCase();
        return name.contains(query) || skills.contains(query);
      }).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = getFilteredStudents();
    final total = _stats['totalStudents'] ?? 0;
    final placed = _stats['placedStudents'] ?? 0;
    final placementRate = total > 0 ? (placed / total * 100) : 0.0;

    return Scaffold(
      backgroundColor: Colors.transparent, // For gradient background
      body: Column(
        children: [
          // Header
          _buildHeader(total, placementRate),
          // Filter Chips
          _buildFilterChips(),
          // List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : _allStudents.isEmpty
                    ? const Center(child: Text("No students found."))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          return _buildStudentCard(filteredStudents[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
  
  // --- UI Widgets ---
  
  Widget _buildHeader(int totalStudents, double rate) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student Directory', style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: darkColor)),
            const SizedBox(height: 12),
            Text(
              'Total Students: $totalStudents • Placement Rate: ${rate.toStringAsFixed(1)}%',
              style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              style: GoogleFonts.montserrat(color: darkColor),
              decoration: InputDecoration(
                hintText: 'Search by name or skill...',
                hintStyle: GoogleFonts.montserrat(color: grayColor),
                prefixIcon: Icon(Icons.search, color: primaryColor),
                filled: true,
                fillColor: lightColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center align the chips
        children: [
          _buildFilterChip('All'),
          const SizedBox(width: 8),
          _buildFilterChip('Placed'),
          const SizedBox(width: 8),
          _buildFilterChip('Unplaced'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : lightColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8)] : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(color: isSelected ? lightColor : darkColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final isPlaced = (student['placementStatus'] ?? '').toLowerCase() == 'placed';
    final List<dynamic> skills = student['skills'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${student['firstName'] ?? ''} ${student['lastName'] ?? ''}',
                    style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: darkColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${student['rollNumber'] ?? ''} | ${student['department'] ?? ''}',
                    style: GoogleFonts.montserrat(fontSize: 13, color: grayColor),
                  ),
                   const SizedBox(height: 4),
                  Text(
                    'CGPA: ${student['cgpa'] ?? 'N/A'}',
                    style: GoogleFonts.montserrat(fontSize: 13, color: grayColor),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPlaced ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  student['placementStatus'] ?? 'Unplaced',
                  style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: isPlaced ? Colors.green.shade700 : Colors.red.shade700),
                ),
              ),
            ],
          ),
          if (skills.isNotEmpty) const Divider(height: 24),
          if (skills.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.take(15).map((skill) => Chip( // Show a max of 15 skills
                label: Text(skill.toString(), style: GoogleFonts.montserrat(color: primaryColor, fontWeight: FontWeight.w500, fontSize: 12)),
                backgroundColor: primaryColor.withOpacity(0.1),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
        ],
      ),
    );
  }
}
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/admin/admin_profile.dart';
import 'package:frontend/custom_header.dart';
import 'package:frontend/notifications.dart';
import 'package:frontend/toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StudentDetailsPage extends StatelessWidget {
  final String studentId;
  const StudentDetailsPage({Key? key, required this.studentId}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Student $studentId")));
}

class AddStudentPage extends StatelessWidget {
  const AddStudentPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Add New Student")));
}
// ----------------------------

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
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
    _fetchStudents();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    final token = await _getToken();
    if (token.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
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

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        setState(() {
          _allStudents = data['students'] ?? [];
          _stats = data['statistics'] ?? {};
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print('Error fetching students: $e');
    }
  }

  List<dynamic> getFilteredStudents() {
    List<dynamic> filtered = _allStudents;

    // 1. Filter by placement status (from chips)
    if (_selectedFilter == 'Placed') {
      filtered = _allStudents.where((s) => (s['placementStatus'] ?? '').toString().toLowerCase() == 'placed').toList();
    } else if (_selectedFilter == 'Unplaced') {
      filtered = _allStudents.where((s) => (s['placementStatus'] ?? '').toString().toLowerCase() != 'placed').toList();
    }

    // 2. Filter by search query (from search bar)
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((s) {
        final name = "${s['firstName'] ?? ''} ${s['lastName'] ?? ''}".toLowerCase();
        final department = (s['department'] ?? '').toString().toLowerCase();
        return name.contains(query) || department.contains(query);
      }).toList();
    }

    return filtered;
  }

  Future<void> _uploadCsv() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Opening file picker..."))
    );

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null) {
        AppToast.error(context, "No file selected.");
        return;
      }

      Uint8List fileBytes = result.files.single.bytes!;
      String fileName = result.files.single.name;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Uploading $fileName to cloud..."))
      );

      // 2. Upload to Cloudinary
      String cloudName = "dd6jsu194"; // Your Cloudinary name
      String uploadPreset = "campusNest"; // Your upload preset
      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(fileBytes, filename: fileName),
        "upload_preset": uploadPreset,
      });

      var cloudinaryResponse = await Dio().post(
        "https://api.cloudinary.com/v1_1/$cloudName/raw/upload",
        data: formData,
      );

      if (cloudinaryResponse.statusCode != 200) {
        throw Exception("Cloudinary upload failed.");
      }
      
      String csvFileUrl = cloudinaryResponse.data["secure_url"];

      final token = await _getToken();
      final url = Uri.parse("https://campusnest-backend-lkue.onrender.com/api/v1/admin/students/upload-csv");
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'csvUrl': csvFileUrl}),
      );

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          AppToast.success(context, "Students added successfully!");
          _fetchStudents(); // Refresh the list
        } else {
          AppToast.error(context, "Backend Error: ${response.body}");
        }
      }

    } catch (e) {
      if (mounted) {
        AppToast.error(context, "An error occurred: $e");
      }
    }
  }

  // --- UI Build ---
  @override
  Widget build(BuildContext context) {
    final filteredStudents = getFilteredStudents();
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _buildFloatingActionButton(),
      body: Column(
        children: [
          CustomAppHeader(
              onProfileTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminProfilePage(),
                ),
              ),
              onNotificationTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              ),
              primaryColor: primaryColor,
              darkColor: darkColor,
              lightColor: lightColor,
            ),
          _buildHeader(),
          _buildSearchAndFilters(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
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

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Show menu with options
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
              MediaQuery.of(context).size.width - 150, // from left
              MediaQuery.of(context).size.height - 200, // from top
              0, 0
          ),
          items: [
            PopupMenuItem(
              value: 'add_single',
              child: Row(children: [const Icon(Icons.person_add_alt_1_outlined), const SizedBox(width: 8), const Text('Add Single Student')]),
            ),
            PopupMenuItem(
              value: 'upload_csv',
              child: Row(children: [const Icon(Icons.upload_file_outlined), const SizedBox(width: 8), const Text('Upload CSV')]),
            ),
          ],
        ).then((value) {
          if (value == 'add_single') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddStudentPage()));
          } else if (value == 'upload_csv') {
            _uploadCsv();
          }
        });
      },
      backgroundColor: primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

   Widget _buildHeader() {
    final total = _stats['totalStudents'] ?? 0;
    final placed = _stats['placedStudents'] ?? 0;
    final placementRate = total > 0 ? (placed / total * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Student Directory', style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: darkColor)),
          const SizedBox(height: 12),
          Text(
            'Total Students: $total • Placement Rate: ${placementRate.toStringAsFixed(1)}%',
            style: GoogleFonts.montserrat(fontSize: 14, color: grayColor, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            style: GoogleFonts.montserrat(color: darkColor),
            decoration: InputDecoration(
              hintText: 'Search by name, department...',
              hintStyle: GoogleFonts.montserrat(color: grayColor),
              prefixIcon: Icon(Icons.search, color: primaryColor),
              filled: true,
              fillColor: lightColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          // Filter Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterChip('All'),
              const SizedBox(width: 8),
              _buildFilterChip('Placed'),
              const SizedBox(width: 8),
              _buildFilterChip('Unplaced'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : lightColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 5)] : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            color: isSelected ? lightColor : darkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            style: GoogleFonts.montserrat(color: darkColor),
            decoration: InputDecoration(
              hintText: 'Search by name, department...',
              hintStyle: GoogleFonts.montserrat(color: grayColor),
              prefixIcon: Icon(Icons.search, color: primaryColor),
              filled: true,
              fillColor: lightColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterChip('All'),
              const SizedBox(width: 8),
              _buildFilterChip('Placed'),
              const SizedBox(width: 8),
              _buildFilterChip('Unplaced'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final isPlaced = (student['placementStatus'] ?? '').toLowerCase() == 'placed';
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => StudentDetailsPage(studentId: student['id'])));
      },
      child: Container(
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
              children: [
                Expanded(
                  child: Text(
                    '${student['firstName'] ?? ''} ${student['lastName'] ?? ''}',
                    style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: darkColor),
                  ),
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
            const SizedBox(height: 8),
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
      ),
    );
  }
}
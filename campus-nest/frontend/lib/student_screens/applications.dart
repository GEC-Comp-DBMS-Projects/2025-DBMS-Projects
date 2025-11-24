import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/custom_header.dart';
import 'package:frontend/notifications.dart';
import 'package:frontend/student_screens/app_deets.dart';
import 'package:frontend/student_screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with TickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF5D9493);
  final Color secondaryColor = const Color(0xFF8CA1A4);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);

  List<dynamic> applications = [];
  List<dynamic> filteredApplications = [];
  bool isLoading = true;
  String selectedFilter = 'All';
  late AnimationController _animationController;

  final List<String> filterOptions = [
    'All',
    'Applied',
    'Shortlisted',
    'Interviewed',
    'Offered',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    fetchApplications();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> fetchApplications() async {
    setState(() {
      isLoading = true;
    });

    final token = await getToken();
    if (token.isEmpty) {
      print('No token found');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
      'https://campusnest-backend-lkue.onrender.com/api/v1/student/applications',
    );

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
        print('Applications Data: $data');

        setState(() {
          applications = data ?? [];
          filteredApplications = applications;
          isLoading = false;
        });
        _animationController.forward(from: 0.0);
      } else {
        print('Failed to load applications: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching applications: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterApplications(String status) {
    setState(() {
      selectedFilter = status;
      if (status == 'All') {
        filteredApplications = applications;
      } else {
        filteredApplications = applications
            .where(
              (app) =>
                  app['status']?.toString().toLowerCase() ==
                  status.toLowerCase(),
            )
            .toList();
      }
    });
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'applied':
        return Colors.blue;
      case 'shortlisted':
        return Colors.orange;
      case 'interviewed':
        return Colors.purple;
      case 'offered':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return grayColor;
    }
  }

  IconData getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'applied':
        return Icons.send;
      case 'shortlisted':
        return Icons.list_alt;
      case 'interviewed':
        return Icons.people;
      case 'offered':
        return Icons.celebration;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, primaryColor, darkColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppHeader(
                onProfileTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
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

              _buildTitleHeader(),
              _buildFilterChips(),

              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(lightColor),
                        ),
                      )
                    : filteredApplications.isEmpty
                    ? _buildEmptyState()
                    : _buildApplicationsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Applications',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${filteredApplications.length} ${selectedFilter != "All" ? selectedFilter : ""} application${filteredApplications.length != 1 ? 's' : ''}',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final choice = await showModalBottomSheet<String>(
              context: context,
              builder: (context) {
                return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  ListTile(
                    leading: const Icon(Icons.arrow_downward),
                    title: const Text('Newest first (Descending)'),
                    onTap: () => Navigator.pop(context, 'desc'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.arrow_upward),
                    title: const Text('Oldest first (Ascending)'),
                    onTap: () => Navigator.pop(context, 'asc'),
                  ),
                  ],
                ),
                );
              },
              );

              if (choice == null) return;

              setState(() {
              int compareByDate(dynamic a, dynamic b) {
                DateTime da = (a != null && a['appliedOn'] != null)
                  ? DateTime.tryParse(a['appliedOn'].toString()) ??
                    DateTime.fromMillisecondsSinceEpoch(0)
                  : DateTime.fromMillisecondsSinceEpoch(0);
                DateTime db = (b != null && b['appliedOn'] != null)
                  ? DateTime.tryParse(b['appliedOn'].toString()) ??
                    DateTime.fromMillisecondsSinceEpoch(0)
                  : DateTime.fromMillisecondsSinceEpoch(0);
                return da.compareTo(db);
              }

              if (choice == 'asc') {
                filteredApplications.sort(compareByDate);
                applications.sort(compareByDate);
              } else {
                filteredApplications.sort((a, b) => -compareByDate(a, b));
                applications.sort((a, b) => -compareByDate(a, b));
              }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: lightColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.filter_list, color: lightColor, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filterOptions.length,
        itemBuilder: (context, index) {
          final filter = filterOptions[index];
          final isSelected = selectedFilter == filter;
          return GestureDetector(
            onTap: () => filterApplications(filter),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? lightColor : lightColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? lightColor : lightColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                filter,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? primaryColor : lightColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: lightColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.inbox, size: 64, color: lightColor),
          ),
          const SizedBox(height: 24),
          Text(
            'No Applications Found',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: lightColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            selectedFilter == 'All'
                ? 'Start applying to jobs to see them here'
                : 'No $selectedFilter applications yet',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              color: lightColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: filteredApplications.length,
      itemBuilder: (context, index) {
        final animation = CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            (index * 0.1).clamp(0.0, 1.0),
            1.0,
            curve: Curves.easeOut,
          ),
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.3, 0),
              end: Offset.zero,
            ).animate(animation),
            child: _buildApplicationCard(filteredApplications[index]),
          ),
        );
      },
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final status = application['status']?.toString() ?? 'Unknown';
    final statusColor = getStatusColor(status);
    final statusIcon = getStatusIcon(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: darkColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    application['companyName']
                            ?.toString()
                            .substring(0, 1)
                            .toUpperCase() ??
                        'C',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application['role'] ?? 'Role Not Specified',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      application['companyName'] ?? 'Company Name',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: grayColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: grayColor.withOpacity(0.2)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: grayColor),
              const SizedBox(width: 6),
              Text(
                'Applied: ${application['appliedOn'] != null ? DateFormat('d MMM yyyy').format(DateTime.parse(application['appliedOn'])) : 'N/A'}',
                style: GoogleFonts.montserrat(fontSize: 13, color: grayColor),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApplicationDetailsScreen(
                          applicationId: application['id'],
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'View Details',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

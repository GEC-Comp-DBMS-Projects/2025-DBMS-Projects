import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/custom_header.dart';
import 'package:frontend/custom_pallete.dart';
import 'package:frontend/notifications.dart';
import 'package:frontend/recruiter_screens/recruiter_profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../toast.dart';

class RecruiterApplicationsScreen extends StatefulWidget {
  const RecruiterApplicationsScreen({Key? key}) : super(key: key);

  @override
  State<RecruiterApplicationsScreen> createState() =>
      _RecruiterApplicationsScreenState();
}

class _RecruiterApplicationsScreenState
    extends State<RecruiterApplicationsScreen>
    with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF5D9493);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);

  bool _isLoadingDrives = true;
  bool _isLoadingApplicants = false;
  List<dynamic> _allJobDrives = [];
  String? _selectedJobDriveId;
  List<dynamic> _applicants = [];
  Set<String> _selectedApplicantIds = {};
  late AnimationController _actionBarController;
  late Animation<Offset> _actionBarAnimation;

  @override
  void initState() {
    super.initState();
    _fetchJobDrivesList();
    _actionBarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _actionBarAnimation =
        Tween<Offset>(begin: const Offset(0, 2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _actionBarController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _actionBarController.dispose();
    super.dispose();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _fetchJobDrivesList() async {
    setState(() => _isLoadingDrives = true);
    final token = await _getToken();
    if (token.isEmpty) {
      if (mounted) setState(() => _isLoadingDrives = false);
      return;
    }
    final url = Uri.parse(
      'https://campusnest-backend-lkue.onrender.com/api/v1/rec/job-drives',
    );
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _allJobDrives = jsonDecode(response.body)['jobDrives'] ?? [];
          _isLoadingDrives = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingDrives = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingDrives = false);
    }
  }

  Future<void> _fetchApplicantsForDrive(String jobId) async {
    setState(() {
      _isLoadingApplicants = true;
      _applicants = [];
      _selectedApplicantIds.clear();
    });
    final token = await _getToken();
    final url = Uri.parse(
      'https://campusnest-backend-lkue.onrender.com/api/v1/rec/job-drives/$jobId',
    );
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _applicants = jsonDecode(response.body)['candidates'] ?? [];
          _isLoadingApplicants = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingApplicants = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingApplicants = false);
    }
  }

  Future<void> _updateApplicantStatus(String newStatus) async {
    if (_selectedJobDriveId == null || _selectedApplicantIds.isEmpty) return;

    final token = await _getToken();
    final url = Uri.parse(
      'https://campusnest-backend-lkue.onrender.com/api/v1/rec/job-drives/$_selectedJobDriveId/students/status',
    );

    final List<Map<String, String>> payload = _selectedApplicantIds.map((id) {
      return {'id': id, 'status': newStatus};
    }).toList();

    final body = jsonEncode(payload);
    print(body);

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
      if (response.statusCode == 200 && mounted) {
        AppToast.success(
          context,
          '${_selectedApplicantIds.length} applicant(s) updated to "$newStatus"',
        );
        _fetchApplicantsForDrive(_selectedJobDriveId!);
      } else {
        AppToast.error(context, 'Failed to update status: ${response.body}');
      }
    } catch (e) {
      AppToast.error(context, 'An error occurred: $e');
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedApplicantIds.contains(id)) {
        _selectedApplicantIds.remove(id);
        if (_selectedApplicantIds.isEmpty) {
          _actionBarController.reverse();
        }
      } else {
        if (_selectedApplicantIds.isEmpty) {
          _actionBarController.forward();
        }
        _selectedApplicantIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedApplicantIds.length == _applicants.length) {
        _selectedApplicantIds.clear();
        _actionBarController.reverse();
      } else {
        _selectedApplicantIds = _applicants
            .map((c) => c['student']['_id'] as String)
            .toSet();
        if (_selectedApplicantIds.isNotEmpty) {
          _actionBarController.forward();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Column(
            children: [
              CustomAppHeader(
                onProfileTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecruiterProfileScreen(),
                    ),
                  ),
                },
                primaryColor: CustomPallete.primaryColor,
                darkColor: CustomPallete.darkColor,
                lightColor: CustomPallete.lightColor,
                onNotificationTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  ),
                },
              ),
              _buildHeader(),
              _buildJobDriveSelector(),
              if (_applicants.isNotEmpty) _buildSelectAllBar(),
              Expanded(
                child: _isLoadingApplicants
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: primaryColor,
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Loading applicants...",
                              style: GoogleFonts.montserrat(color: grayColor),
                            ),
                          ],
                        ),
                      )
                    : _applicants.isEmpty
                    ? _buildEmptyState()
                    : _buildApplicantsList(),
              ),
            ],
          ),
          if (_selectedApplicantIds.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: SlideTransition(
                position: _actionBarAnimation,
                child: _buildActionBar(),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: lightColor.withOpacity(0.7),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Applications',
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: darkColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Review and manage candidate applications',
              style: GoogleFonts.montserrat(fontSize: 14, color: grayColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDriveSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: _selectedJobDriveId,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: 'Job Drive',
            labelStyle: GoogleFonts.montserrat(
              color: grayColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(Icons.work_outline_rounded, color: primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          hint: _isLoadingDrives
              ? Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text("Loading drives..."),
                  ],
                )
              : const Text("Choose a drive"),
          items: _allJobDrives.map<DropdownMenuItem<String>>((drive) {
            return DropdownMenuItem<String>(
              value: drive['_id'],
              child: Text(
                drive['position'] ?? 'Unknown Position',
                style: GoogleFonts.montserrat(
                  color: darkColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedJobDriveId = newValue);
              _fetchApplicantsForDrive(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSelectAllBar() {
    final allSelected = _selectedApplicantIds.length == _applicants.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Checkbox(
              value: allSelected,
              onChanged: (value) => _selectAll(),
              activeColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              allSelected ? 'Deselect All' : 'Select All',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: darkColor,
              ),
            ),
            const Spacer(),
            Text(
              '${_applicants.length} applicants',
              style: GoogleFonts.montserrat(color: grayColor, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: lightColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 64,
              color: grayColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedJobDriveId == null
                ? "Select a job drive to see applicants"
                : "No applicants yet",
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: darkColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedJobDriveId == null
                ? "Choose a drive from the dropdown above"
                : "Applications will appear here once students apply",
            style: GoogleFonts.montserrat(color: grayColor, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantsList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 160),
      itemCount: _applicants.length,
      itemBuilder: (context, index) {
        final candidate = _applicants[index];
        final student = candidate['student'];
        final isSelected = _selectedApplicantIds.contains(student['_id']);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: GestureDetector(
            onTap: () => _toggleSelection(student['_id']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withOpacity(0.12)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? primaryColor.withOpacity(0.15)
                        : Colors.black.withOpacity(0.04),
                    blurRadius: isSelected ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (bool? value) =>
                          _toggleSelection(student['_id']),
                      activeColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (student['firstName']?[0] ?? '?').toUpperCase(),
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
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
                          "${student['firstName']} ${student['lastName']}",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            color: darkColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 14,
                              color: grayColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (() {
                                final raw = (student['department'] ?? '').toString().toLowerCase().trim();
                                if (raw.isEmpty) return 'N/A';
                                if (raw.contains('computer') && raw.contains('science') || raw == 'cs') return 'CS';
                                if (raw.contains('mechan') || raw == 'mech') return 'Mech';
                                if (raw.contains('elect') || raw == 'ece') return 'ECE';
                                if (raw.contains('information') || raw == 'it') return 'IT';
                                if (raw.contains('civil')) return 'Civil';
                                return student['department'].toString();
                              }()),
                              style: GoogleFonts.montserrat(
                                color: grayColor,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.stars_rounded,
                              size: 14,
                              color: grayColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "CGPA: ${student['cgpa'] ?? 'N/A'}",
                              style: GoogleFonts.montserrat(
                                color: grayColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(candidate['status']),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'interviewed': 
        badgeColor = Colors.deepPurple;
        icon = Icons.people_alt_rounded;
        break;
      case 'selected':
        badgeColor = const Color(0xFF00C853); 
        icon = Icons.check_circle_rounded;
        break;
      case 'shortlisted':
        badgeColor = Colors.orange;
        icon = Icons.star_rounded;
        break;
      case 'rejected':
        badgeColor = Colors.red;
        icon = Icons.cancel_rounded;
        break;
      case 'applied':
      default:
        badgeColor = Colors.blue;
        icon = Icons.send_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: GoogleFonts.montserrat(
              color: badgeColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: darkColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF5D9493),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${_selectedApplicantIds.length}',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Selected',
                style: GoogleFonts.montserrat(
                  color: lightColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (String status) {
              _updateApplicantStatus(status);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Interviewed',
                child: Text('Set to Interviewed'),
              ),
              const PopupMenuItem<String>(
                value: 'Shortlisted',
                child: Text('Set to Shortlisted'),
              ),
              const PopupMenuItem<String>(
                value: 'Selected',
                child: Text('Set to Selected'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'Rejected',
                child: Text('Set to Rejected'),
              ),
            ],
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Actions',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _actionButton(
  //   String label,
  //   Color color,
  //   IconData icon,
  //   VoidCallback onPressed,
  // ) {
  //   return ElevatedButton.icon(
  //     onPressed: onPressed,
  //     icon: Icon(icon, size: 18),
  //     label: Text(
  //       label,
  //       style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
  //     ),
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: color,
  //       foregroundColor: Colors.white,
  //       shape: const StadiumBorder(),
  //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //       elevation: 0,
  //     ),
  //   );
  // }
}

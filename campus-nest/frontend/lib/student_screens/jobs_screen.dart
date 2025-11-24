import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/custom_header.dart';
import 'package:frontend/notifications.dart';
import 'package:frontend/student_screens/jobdeets_screen.dart';
import 'package:frontend/student_screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class JobsPage extends StatefulWidget {
  const JobsPage({Key? key}) : super(key: key);

  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> with TickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF5D9493);
  final Color secondaryColor = const Color(0xFF8CA1A4);
  final Color darkColor = const Color(0xFF21464E);
  final Color lightColor = const Color(0xFFF8F9F9);
  final Color grayColor = const Color(0xFFA1B5B7);

  bool isLoading = true;
  List<dynamic> jobsData = [];
  List<dynamic> filteredJobs = [];
  TextEditingController searchController = TextEditingController();
  late AnimationController _animationController;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    fetchJobs();
    searchController.addListener(filterJobs);
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.removeListener(filterJobs);
    searchController.dispose();
    super.dispose();
  }

  // void filterJobs() {
  //   final search = searchController.text.toLowerCase();
  //   setState(() {
  //     if (search.isEmpty) {
  //       filteredJobs = jobsData;
  //     } else {
  //       filteredJobs = jobsData.where((job) {
  //         final position = job['job']['position']?.toString().toLowerCase() ?? '';
  //         final company = job['job']['company_name']?['name']?.toString().toLowerCase() ?? '';
  //         final location = job['job']['location']?.toString().toLowerCase() ?? '';
  //         return position.contains(search) || company.contains(search) || location.contains(search);
  //       }).toList();
  //     }
  //   });
  // }

  void filterJobs() {
    final search = searchController.text.toLowerCase();
    final locationQuery = _locationController.text.toLowerCase();
    final skillQuery = _skillController.text.toLowerCase();

    setState(() {
      filteredJobs = jobsData.where((jobData) {
        final job = jobData['job'];
        
        bool statusMatch = true;
        if (_statusFilter == 'Applied') {
          statusMatch = jobData['has_applied'] == true;
        } else if (_statusFilter == 'Bookmarked') {
          statusMatch = jobData['isBookmarked'] == true;
        }

        final position = job['position']?.toString().toLowerCase() ?? '';
        final company = job['company_name']?['name']?.toString().toLowerCase() ?? '';
        final textSearchMatch = search.isEmpty || position.contains(search) || company.contains(search);

        final locationMatch = locationQuery.isEmpty ||
            (job['location']?.toString().toLowerCase().contains(locationQuery) ?? false);

        final skills = job['eligibility']?['skills'] as List<dynamic>? ?? [];
        final skillMatch = skillQuery.isEmpty ||
            skills.any((skill) => skill.toString().toLowerCase().contains(skillQuery));

        return statusMatch && textSearchMatch && locationMatch && skillMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, 
            end: Alignment.bottomCenter,
            colors: [Colors.white, primaryColor, darkColor],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppHeader(
                onProfileTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                primaryColor: primaryColor,
                darkColor: darkColor,
                lightColor: lightColor,
                onNotificationTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsPage()))
              ),
              _buildTitleHeader(),
              _buildSearchBar(),
              _buildFilterChips(),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(lightColor)))
                    : filteredJobs.isEmpty
                        ? _buildEmptyState()
                        : _buildJobsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row( 
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find Your Next Job',
                  style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: darkColor), 
                ),
                const SizedBox(height: 4),
                Text(
                  searchController.text.isEmpty
                      ? '${filteredJobs.length} job opportunities'
                      : 'Found ${filteredJobs.length} result${filteredJobs.length != 1 ? 's' : ''}',
                  style: GoogleFonts.montserrat(fontSize: 14, color: darkColor.withOpacity(0.7)), 
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showFilterSheet(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: darkColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Icon(Icons.filter_list_alt, color: primaryColor, size: 24),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildFilterChips() {
    final filters = ['All', 'Applied', 'Bookmarked'];
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 8, bottom: 8, left: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _statusFilter == filter;
          return GestureDetector(
            onTap: () {
              setState(() => _statusFilter = filter);
              filterJobs(); 
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : lightColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8)] : [],
              ),
              child: Text(
                filter,
                style: GoogleFonts.montserrat(
                  color: isSelected ? lightColor : darkColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Advanced Filters', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: darkColor)),
                const SizedBox(height: 24),
                TextField(
                  controller: _locationController,
                  decoration: _inputDecoration('Filter by Location (e.g., Pune)'),
                  style: GoogleFonts.montserrat(color: darkColor),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _skillController,
                  decoration: _inputDecoration('Filter by Skill (e.g., Python)'),
                  style: GoogleFonts.montserrat(color: darkColor),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _locationController.clear();
                          _skillController.clear();
                          filterJobs();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(side: BorderSide(color: grayColor), minimumSize: const Size(double.infinity, 50)),
                        child: Text('Clear', style: GoogleFonts.montserrat(color: grayColor)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50)),
                        onPressed: () {
                          filterJobs();
                          Navigator.pop(context);
                        },
                        child: Text('Apply Filters', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: lightColor)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.montserrat(color: grayColor),
      filled: true,
      fillColor: primaryColor.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: TextField(
        controller: searchController,
        style: GoogleFonts.montserrat(fontSize: 15, color: darkColor),
        decoration: InputDecoration(
          hintText: 'Search by position, company...',
          hintStyle: GoogleFonts.montserrat(fontSize: 15, color: grayColor),
          prefixIcon: Icon(Icons.search, color: primaryColor),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: grayColor),
                  onPressed: () => searchController.clear(),
                )
              : null,
          filled: true,
          fillColor: lightColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildJobsList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      itemCount: filteredJobs.length,
      itemBuilder: (context, index) {
        final animation = CurvedAnimation(
          parent: _animationController,
          curve: Interval((index * 0.1).clamp(0.0, 1.0), 1.0, curve: Curves.easeOut),
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(animation),
            child: _buildJobCard(filteredJobs[index]),
          ),
        );
      },
    );
  }
  
  Widget _buildJobCard(Map<String, dynamic> job) {
    final deadline = DateTime.tryParse(job['job']['application_deadline'] ?? '');
    final daysLeft = deadline?.difference(DateTime.now()).inDays ?? -1;
    final isUrgent = daysLeft <= 7 && daysLeft >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: darkColor.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text(
                  _getCompanyInitial(job['job']['company_name']?['name'] ?? 'C'),
                  style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(job['job']['position'] ?? 'Job Title', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: darkColor)),
              const SizedBox(height: 4),
              Text(job['job']['company_name']?['name'] ?? 'Company Name', style: GoogleFonts.montserrat(fontSize: 14, color: grayColor, fontWeight: FontWeight.w500)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.orange.withOpacity(0.1) : primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(isUrgent ? Icons.access_time : Icons.calendar_today, size: 14, color: isUrgent ? Colors.orange : primaryColor),
                const SizedBox(width: 4),
                Text(
                  isUrgent ? '$daysLeft days left' : (deadline != null ? DateFormat('d MMM').format(deadline) : 'N/A'),
                  style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: isUrgent ? Colors.orange : primaryColor),
                ),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          Divider(color: grayColor.withOpacity(0.2)),
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.location_on_outlined, size: 16, color: grayColor),
            const SizedBox(width: 6),
            Text(job['job']['location'] ?? 'Location', style: GoogleFonts.montserrat(fontSize: 13, color: grayColor)),
            const Spacer(),
            Icon(Icons.school_outlined, size: 16, color: grayColor),
            const SizedBox(width: 6),
            Text('CGPA: ${job['job']['eligibility']?['min_cgpa']?.toString() ?? 'N/A'}', style: GoogleFonts.montserrat(fontSize: 13, color: grayColor)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.attach_money, size: 16, color: grayColor),
            const SizedBox(width: 6),
            Text(job['job']['salary_range']?.toString() ?? 'N/A', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: primaryColor)),
            const Spacer(),
            Text('Posted ${_getTimeAgo(job['job']['created_at'])}', style: GoogleFonts.montserrat(fontSize: 13, color: grayColor)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => _toggleBookmark(job['job']['id']),
              style: OutlinedButton.styleFrom(foregroundColor: primaryColor, side: BorderSide(color: primaryColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(job['isBookmarked'] == true ? Icons.bookmark : Icons.bookmark_border, size: 18),
                const SizedBox(width: 6),
                Text(job['isBookmarked'] == true ? 'Saved' : 'Save', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
              ]),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailsPage(jobId: job['job']['id'])));
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: lightColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
              child: Text('View Details', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
            )),
          ]),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: lightColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
        child: Icon(searchController.text.isNotEmpty ? Icons.search_off : Icons.work_off_outlined, size: 64, color: lightColor),
      ),
      const SizedBox(height: 24),
      Text(searchController.text.isNotEmpty ? 'No Jobs Found' : 'No Jobs Available', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w600, color: lightColor)),
      const SizedBox(height: 12),
      Text(searchController.text.isNotEmpty ? 'Try different keywords or clear the search' : 'Check back later for new opportunities', style: GoogleFonts.montserrat(fontSize: 15, color: lightColor.withOpacity(0.7)), textAlign: TextAlign.center),
      if (searchController.text.isNotEmpty) ...[
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => searchController.clear(),
          icon: const Icon(Icons.clear),
          label: const Text('Clear Search'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor, 
            foregroundColor: lightColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    ]));
  }

  String _getCompanyInitial(String companyName) => companyName.isNotEmpty ? companyName[0].toUpperCase() : 'C';
  String _getTimeAgo(String? dateStr) {
    if (dateStr == null) return 'recently';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return 'recently';

    final difference = DateTime.now().difference(date);
    if (difference.inDays > 30) return '${(difference.inDays / 30).floor()} mo ago';
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    return 'just now';
  }
void _toggleBookmark(dynamic jobId) {
  setState(() {
    for (var job in jobsData) {
      if (job['job']['id'] == jobId) {
        job['isBookmarked'] = !(job['isBookmarked'] ?? false);
        break;
      }
    }
    filterJobs();
  });
  _saveBookmarkStatus();
}

  Future<void> _saveBookmarkStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  final List<String> bookmarkedIds = jobsData
      .where((job) => job['isBookmarked'] == true)
      .map((job) => job['job']['id'] as String)
      .toList();
      
  await prefs.setStringList('bookmarked_jobs', bookmarkedIds);
}

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }
  Future<void> fetchJobs() async {
    setState(() => isLoading = true);
    final token = await getToken();
    if (token.isEmpty) { setState(() => isLoading = false); return; }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarkedIds = prefs.getStringList('bookmarked_jobs') ?? [];
    Set<String> bookmarkSet = bookmarkedIds.toSet();

    final url = Uri.parse('https://campusnest-backend-lkue.onrender.com/api/v1/student/jobs');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Jobs: $data");
        for (var job in data) {
        if (bookmarkSet.contains(job['job']['id'])) {
          job['isBookmarked'] = true;
        } else {
          job['isBookmarked'] = false;
        }
      }
        setState(() { jobsData = data ?? []; isLoading = false; });
        filterJobs();
        _animationController.forward(from: 0.0);
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }
}
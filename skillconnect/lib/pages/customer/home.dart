import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillconnect/pages/customer/jobs.dart';
import 'package:skillconnect/pages/customer/notifications.dart';
import 'package:skillconnect/pages/customer/profile.dart';
import 'package:skillconnect/pages/customer/ser_agents.dart';
import 'package:skillconnect/pages/customer/services.dart';
import 'package:intl/intl.dart';
import 'package:skillconnect/pages/customer/review.dart';

class Service {
  final String name;
  final String imageUrl;

  Service(this.name, this.imageUrl);
}

// --- ADDED: Job Model ---
class Job {
  final String jobId;
  final String title;
  final String status;
  final String agentId;
  final String userId;
  final Timestamp createdAt;
  final bool hasReview;

  Job({
    required this.jobId,
    required this.title,
    required this.status,
    required this.agentId,
    required this.userId,
    required this.createdAt,
    required this.hasReview,
  });

  factory Job.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Job(
      jobId: doc.id,
      title: data['title'] ?? 'No Title',
      status: data['status'] ?? 'Unknown',
      agentId: data['agent_id'] ?? '',
      userId: data['user_id'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
      hasReview: data['has_review'] ?? false,
    );
  }
}
// --- END: Job Model ---

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  static const Color darkBlue = Color(0xFF2E4A68);
  static const Color white = Colors.white;

  final List<IconData> _icons = [
    Icons.home_outlined,
    Icons.receipt_long_outlined,
    Icons.person_outline,
  ];

  final List<String> _labels = ["Home", "Jobs", "Profile"];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: darkBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // curved center bump
          Positioned(
            top: 0,
            child: Container(
              height: 80,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: darkBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
          ),

          // main row for icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_icons.length, (index) {
              bool isSelected = widget.currentIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onTabSelected(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        height: isSelected ? 50 : 45,
                        width: isSelected ? 50 : 45,
                        decoration: BoxDecoration(
                          color: isSelected ? white : Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          _icons[index],
                          color: isSelected ? darkBlue : white,
                          size: isSelected ? 28 : 24,
                        ),
                      ),
                      Text(
                        _labels[index],
                        style: TextStyle(
                          color: isSelected
                              ? white
                              : white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          height: 3,
                          width: 40,
                          decoration: BoxDecoration(
                            color: white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});
  @override
  CustomerHomePageState createState() => CustomerHomePageState();
}

class CustomerHomePageState extends State<CustomerHomePage> {
  // --- State Variables ---
  String? _userName;
  String? _userCity;
  String? _userProfilePicUrl;
  bool _isDataLoading = true;
  int _currentIndex = 0;

  // --- UI Color Scheme ---
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color paleBlue = Color(0xFFA7CCED);
  static const Color grayBlue = Color(0xFF82A0BC);

  // --- Quick Services Data ---
  final List<Service> quickServices = [
    Service(
      'AC Repair',
      'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/2x/external-cleaning-labour-day-vitaliy-gorbachev-flat-vitaly-gorbachev.png',
    ),
    Service(
      'Plumbing',
      'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/2x/external-plumber-labour-day-vitaliy-gorbachev-flat-vitaly-gorbachev.png',
    ),
    Service(
      'More',
      'https://img.icons8.com/external-itim2101-flat-itim2101/2x/external-painter-male-occupation-avatar-itim2101-flat-itim2101.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("No user logged in");
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && mounted) {
        setState(() {
          _userName = userDoc.get('name');
          _userCity = userDoc.get('city');
          _userProfilePicUrl = userDoc.get('profilePicUrl');
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user data: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDataLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      const JobsPage(),
      const CustomerProfile(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isDataLoading
          ? const Center(child: CircularProgressIndicator(color: lightBlue))
          : pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            const SizedBox(height: 32),
            Text(
              'Hello, ${_userName ?? 'User'} 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'What service do you need today?',
              style: TextStyle(fontSize: 16, color: grayBlue),
            ),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildQuickServicesGrid(),
            const SizedBox(height: 24), // --- ADDED ---
            _buildReviewableJobsSection(), // --- ADDED ---
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    String initial = _userName != null && _userName!.isNotEmpty
        ? _userName![0].toUpperCase()
        : 'U';

    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: paleBlue,
          backgroundImage:
              _userProfilePicUrl != null && _userProfilePicUrl!.isNotEmpty
              ? NetworkImage(_userProfilePicUrl!)
              : null,
          child: (_userProfilePicUrl == null || _userProfilePicUrl!.isEmpty)
              ? Text(
                  initial,
                  style: const TextStyle(
                    color: darkBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Location',
                style: TextStyle(fontSize: 12, color: grayBlue),
              ),
              Row(
                children: [
                  const Icon(Icons.location_on, color: lightBlue, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _userCity ?? 'Not set',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .where(
                'receiver_id',
                isEqualTo: FirebaseAuth.instance.currentUser?.uid,
              )
              .where(
                'status',
                isEqualTo: 'unread',
              ) // Requires a composite index
              .snapshots(),
          builder: (context, snapshot) {
            int unreadCount = 0;
            if (snapshot.hasData) {
              unreadCount = snapshot.data!.docs.length;
            }
            return Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    );
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: darkBlue,
                      size: 24,
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search for services...',
          hintStyle: TextStyle(fontSize: 16, color: grayBlue),
          prefixIcon: Icon(Icons.search, color: grayBlue, size: 24),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildQuickServicesGrid() {
    return Row(
      children: quickServices.map((service) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (service.name == 'More') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SelectService(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AvailableAgentsPage(selectedService: service.name),
                  ),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(8),
                    child: service.name == 'More'
                        ? const Icon(
                            Icons.arrow_forward,
                            color: lightBlue,
                            size: 28,
                          )
                        : Image.network(
                            service.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.work,
                                size: 28,
                                color: lightBlue,
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: darkBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewableJobsSection() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('user_id', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'Completed')
          .where('has_review', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: lightBlue,
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return const Text('Error loading jobs.');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink(); // No jobs to review
        }

        final jobDocs = snapshot.data!.docs;
        final jobs = jobDocs.map((doc) => Job.fromFirestore(doc)).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Provide Reviews',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 16),
            ...jobs.map((job) => ReviewableJobCard(job: job)),
          ],
        );
      },
    );
  }
}

class ReviewableJobCard extends StatefulWidget {
  final Job job;
  const ReviewableJobCard({super.key, required this.job});

  @override
  State<ReviewableJobCard> createState() => _ReviewableJobCardState();
}

class _ReviewableJobCardState extends State<ReviewableJobCard> {
  // --- UI Color Scheme (from CustomerHomePageState) ---
  static const Color darkBlue = Color(0xFF304D6D);
  static const Color lightBlue = Color(0xFF63ADF2);
  static const Color grayBlue = Color(0xFF82A0BC);

  String? _agentName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAgentName();
  }

  Future<void> _fetchAgentName() async {
    try {
      if (widget.job.agentId.isEmpty) {
        setState(() {
          _agentName = 'Unknown Agent';
          _isLoading = false;
        });
        return;
      }
      DocumentSnapshot agentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.job.agentId)
          .get();

      if (agentDoc.exists && mounted) {
        setState(() {
          _agentName = agentDoc.get('name');
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _agentName = 'Error';
          _isLoading = false;
        });
      }
      if (kDebugMode) {
        print("Error fetching agent name: $e");
      }
    }
  }

  void _navigateToReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewPage(
          jobId: widget.job.jobId,
          workerId: widget.job.agentId,
          workerName: _agentName ?? 'Worker',
          isEditing: widget.job.hasReview,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return grayBlue;
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: grayBlue, size: 16),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, color: darkBlue)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.job.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                ),
                Chip(
                  label: Text(widget.job.status),
                  backgroundColor: _getStatusColor(
                    widget.job.status,
                  ).withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: _getStatusColor(widget.job.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              DateFormat('d MMM yyyy').format(widget.job.createdAt.toDate()),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.person_outline,
              _isLoading ? 'Loading...' : _agentName ?? 'Unknown',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _navigateToReview,
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: const Text('Provide a Review'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: lightBlue),
                  foregroundColor: lightBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

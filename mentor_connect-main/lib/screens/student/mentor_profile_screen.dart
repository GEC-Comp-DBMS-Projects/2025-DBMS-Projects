import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/chat_service.dart';
import '../../services/mentorship_service.dart';
import '../../services/review_service.dart';
import '../../models/user_model.dart';
import '../../models/mentorship_form_model.dart';
import '../../models/review_model.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../reviews/add_review_screen.dart';

class MentorProfileScreen extends StatefulWidget {
  final String mentorId;
  const MentorProfileScreen({Key? key, required this.mentorId})
      : super(key: key);

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final ChatService _chatService = ChatService();
  late TabController _tabController;
  UserModel? _mentor;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isCreatingChat = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to show/hide FAB
    });
    _loadMentorData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMentorData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final mentor = await _firestoreService.getUser(widget.mentorId);

      setState(() {
        _mentor = mentor;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _startChat() async {
    if (_mentor == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;

    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to send messages')),
        );
      }
      return;
    }

    setState(() {
      _isCreatingChat = true;
    });

    try {
      // Create or get existing chat
      final chatId = await _chatService.createOrGetChat(
        mentorId: _mentor!.uid,
        studentId: currentUser.uid,
        participantNames: {
          currentUser.uid: currentUser.name,
          _mentor!.uid: _mentor!.name,
        },
        participantImages: {
          currentUser.uid: currentUser.profileImage,
          _mentor!.uid: _mentor!.profileImage,
        },
      );

      if (mounted) {
        setState(() {
          _isCreatingChat = false;
        });

        // Navigate to chat detail screen
        Navigator.pushNamed(
          context,
          AppRoutes.chatDetail,
          arguments: {
            'chatId': chatId,
            'otherUserId': _mentor!.uid,
            'otherUserName': _mentor!.name,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCreatingChat = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mentor Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _mentor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mentor Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 64, color: AppTheme.errorColor),
              const SizedBox(height: 16),
              Text(
                'Error loading mentor profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Mentor not found',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadMentorData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicatorColor: AppTheme.primaryColor,
                  tabs: const [
                    Tab(text: 'About'),
                    Tab(text: 'Forms'),
                    Tab(text: 'Reviews'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAboutTab(),
            _buildFormsTab(),
            _buildReviewsTab(),
          ],
        ),
      ),
      floatingActionButton: _buildReviewFAB(),
    );
  }

  Widget? _buildReviewFAB() {
    // Only show FAB on Reviews tab
    if (_tabController.index != 2) return null;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.firebaseUser?.uid;

    if (currentUserId == null) return null;

    return FutureBuilder<bool>(
      future: Future.wait([
        MentorshipService().hasActiveMentorship(currentUserId, widget.mentorId),
        ReviewService().hasUserReviewedUser(currentUserId, widget.mentorId),
      ]).then((results) => results[0] && !results[1]),
      builder: (context, snapshot) {
        final canReview = snapshot.data ?? false;

        if (!canReview) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddReviewScreen(
                  revieweeId: widget.mentorId,
                  revieweeName: _mentor?.name ?? 'Mentor',
                  revieweeRole: 'mentor',
                ),
              ),
            );
          },
          icon: const Icon(Icons.star),
          label: const Text('Write Review'),
          backgroundColor: Colors.amber.shade700,
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: _mentor?.profileImage != null
                  ? NetworkImage(_mentor!.profileImage!)
                  : null,
              child: _mentor?.profileImage == null
                  ? Text(
                      _mentor?.name.substring(0, 1).toUpperCase() ?? 'M',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            // Name
            Text(
              _mentor?.name ?? 'Mentor',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 4),
                Text(
                  '${_mentor?.rating?.toStringAsFixed(1) ?? '0.0'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${_mentor?.totalRatings ?? 0} reviews)',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Message',
                    onTap: _isCreatingChat ? () {} : _startChat,
                  ),
                  _buildActionButton(
                    icon: Icons.video_call_outlined,
                    label: 'Meeting',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.scheduleMeeting,
                        arguments: {
                          'otherUserId': widget.mentorId,
                          'otherUserName': _mentor?.name ?? 'Mentor',
                          'otherUserRole': 'mentor',
                        },
                      );
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.star_outline,
                    label: 'Review',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.addReview,
                        arguments: {
                          'mentorId': widget.mentorId,
                          'mentorName': _mentor?.name ?? 'Mentor',
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio
          if (_mentor?.bio != null && _mentor!.bio!.isNotEmpty) ...[
            _buildSectionTitle('About'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _mentor!.bio!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Expertise
          if (_mentor?.expertise != null && _mentor!.expertise.isNotEmpty) ...[
            _buildSectionTitle('Expertise'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _mentor!.expertise.map((exp) {
                    return Chip(
                      label: Text(exp),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      labelStyle: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Contact Information
          _buildSectionTitle('Contact'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.email_outlined,
                        color: AppTheme.primaryColor),
                    title: const Text('Email'),
                    subtitle: Text(
                      _mentor?.email ?? 'N/A',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_mentor?.phone != null && _mentor!.phone!.isNotEmpty)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.phone_outlined,
                          color: AppTheme.primaryColor),
                      title: const Text('Phone'),
                      subtitle: Text(
                        _mentor!.phone!,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Stats
          _buildSectionTitle('Statistics'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people_outline,
                  label: 'Mentees',
                  value: '0', // TODO: Get actual count
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.event_available,
                  label: 'Sessions',
                  value: '0', // TODO: Get actual count
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24), // Add padding at bottom
        ],
      ),
    );
  }

  Widget _buildFormsTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.uid;

    return StreamBuilder<List<MentorshipForm>>(
      stream: _firestoreService.getFormsByMentor(widget.mentorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 64, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                Text(
                  'Error loading forms',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final forms = snapshot.data ?? [];
        final activeForms = forms.where((form) => form.isActive).toList();

        if (activeForms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.description_outlined,
                    size: 64, color: AppTheme.textSecondary),
                const SizedBox(height: 16),
                Text(
                  'No active forms',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'This mentor hasn\'t created any forms yet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeForms.length,
          itemBuilder: (context, index) {
            return _buildFormCard(context, activeForms[index], currentUserId);
          },
        );
      },
    );
  }

  Widget _buildFormCard(
      BuildContext context, MentorshipForm form, String? currentUserId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: currentUserId != null
            ? () async {
                // Check if already submitted
                final hasSubmitted =
                    await _firestoreService.hasStudentSubmittedToMentor(
                        currentUserId, widget.mentorId);

                if (!context.mounted) return;

                if (hasSubmitted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You have already applied to this mentor'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                  return;
                }

                // Navigate to fill form
                Navigator.pushNamed(
                  context,
                  AppRoutes.fillForm,
                  arguments: {
                    'formId': form.formId,
                    'mentorId': widget.mentorId,
                  },
                );
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          form.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${form.questions.length} questions',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              if (form.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  form.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Accepting Applications',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return StreamBuilder<List<Review>>(
      stream: _firestoreService.getReviewsByMentor(widget.mentorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 64, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                Text(
                  'Error loading reviews',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rate_review_outlined,
                    size: 64, color: AppTheme.textSecondary),
                const SizedBox(height: 16),
                Text(
                  'No reviews yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to review this mentor',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            return _buildReviewCard(reviews[index]);
          },
        );
      },
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    review.studentName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.studentName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        _formatDate(review.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                // Rating stars
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 18,
                    );
                  }),
                ),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.comment!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Custom delegate for sticky tabs
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

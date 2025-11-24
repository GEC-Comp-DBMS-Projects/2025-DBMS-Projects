import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../models/meeting_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/meeting_service.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class StudentMeetingsScreen extends StatefulWidget {
  const StudentMeetingsScreen({Key? key}) : super(key: key);

  @override
  State<StudentMeetingsScreen> createState() => _StudentMeetingsScreenState();
}

class _StudentMeetingsScreenState extends State<StudentMeetingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MeetingService _meetingService = MeetingService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.firebaseUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Meetings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: userId.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Not Logged In',
              message: 'Please log in to view your meetings.',
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingMeetings(userId),
                _buildPastMeetings(userId),
              ],
            ),
    );
  }

  Widget _buildUpcomingMeetings(String userId) {
    return StreamBuilder<List<Meeting>>(
      stream: _meetingService.getUserMeetings(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: 'Loading meetings...');
        }

        if (snapshot.hasError) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: 'Error',
            message: 'Failed to load meetings: ${snapshot.error}',
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.event_busy,
            title: 'No Upcoming Meetings',
            message: 'You don\'t have any upcoming meetings scheduled.',
          );
        }

        // Filter upcoming meetings
        final now = DateTime.now();
        final upcomingMeetings = snapshot.data!
            .where((meeting) =>
                meeting.dateTime.isAfter(now) &&
                meeting.status != 'cancelled' &&
                meeting.status != 'completed')
            .toList();

        upcomingMeetings.sort((a, b) => a.dateTime.compareTo(b.dateTime));

        if (upcomingMeetings.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.event_available,
            title: 'No Upcoming Meetings',
            message: 'You don\'t have any meetings scheduled.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: upcomingMeetings.length,
            itemBuilder: (context, index) {
              final meeting = upcomingMeetings[index];
              return _buildMeetingCard(meeting, userId);
            },
          ),
        );
      },
    );
  }

  Widget _buildPastMeetings(String userId) {
    return StreamBuilder<List<Meeting>>(
      stream: _meetingService.getUserMeetings(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: 'Loading meetings...');
        }

        if (snapshot.hasError) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: 'Error',
            message: 'Failed to load meetings: ${snapshot.error}',
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.history,
            title: 'No Past Meetings',
            message: 'You don\'t have any past meetings.',
          );
        }

        // Filter past meetings
        final now = DateTime.now();
        final pastMeetings = snapshot.data!
            .where((meeting) =>
                meeting.dateTime.isBefore(now) ||
                meeting.status == 'cancelled' ||
                meeting.status == 'completed')
            .toList();

        pastMeetings.sort((a, b) => b.dateTime.compareTo(a.dateTime));

        if (pastMeetings.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.history,
            title: 'No Past Meetings',
            message: 'You don\'t have any past meetings yet.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pastMeetings.length,
            itemBuilder: (context, index) {
              final meeting = pastMeetings[index];
              return _buildMeetingCard(meeting, userId);
            },
          ),
        );
      },
    );
  }

  Widget _buildMeetingCard(Meeting meeting, String userId) {
    final isMentor = meeting.mentorId == userId;
    final otherUserName = isMentor ? meeting.studentName : meeting.mentorName;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (meeting.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Pending Approval';
        break;
      case 'approved':
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Approved';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Cancelled';
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.done_all;
        statusText = 'Completed';
        break;
      case 'postponed':
        statusColor = Colors.purple;
        statusIcon = Icons.update;
        statusText = 'Postponed';
        break;
      default:
        statusColor = AppTheme.textSecondary;
        statusIcon = Icons.info;
        statusText = meeting.status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.meetingDetail,
            arguments: meeting.meetingId,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meeting.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isMentor ? Icons.person : Icons.person_outline,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isMentor ? 'With: $otherUserName' : 'With: $otherUserName',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a')
                        .format(meeting.dateTime),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    meeting.meetingType == 'online'
                        ? Icons.video_call
                        : Icons.location_on,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      meeting.meetingType == 'online'
                          ? 'Online Meeting'
                          : meeting.location.isNotEmpty
                              ? meeting.location
                              : 'Physical Meeting',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (meeting.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  meeting.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

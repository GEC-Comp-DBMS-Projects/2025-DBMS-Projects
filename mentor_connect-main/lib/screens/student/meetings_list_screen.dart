import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentorship_app/models/meeting_model.dart';
import 'package:mentorship_app/services/meeting_service.dart';
import 'package:mentorship_app/widgets/empty_state_widget.dart';
import 'package:mentorship_app/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import 'package:mentorship_app/providers/auth_provider.dart';
import 'package:mentorship_app/config/routes.dart';

class MeetingsListScreen extends StatefulWidget {
  const MeetingsListScreen({super.key});

  @override
  State<MeetingsListScreen> createState() => _MeetingsListScreenState();
}

class _MeetingsListScreenState extends State<MeetingsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _meetingService = MeetingService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Meetings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending', icon: Icon(Icons.pending_actions)),
            Tab(text: 'Upcoming', icon: Icon(Icons.event)),
            Tab(text: 'Past', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingMeetings(userId),
          _buildUpcomingMeetings(userId),
          _buildPastMeetings(userId),
        ],
      ),
    );
  }

  Widget _buildPendingMeetings(String userId) {
    return StreamBuilder<List<Meeting>>(
      stream: _meetingService.getPendingMeetings(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final meetings = snapshot.data ?? [];

        if (meetings.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.pending_actions,
            title: 'No Pending Meetings',
            message: 'You have no meeting requests waiting for response',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: meetings.length,
          itemBuilder: (context, index) {
            return _buildMeetingCard(meetings[index], userId);
          },
        );
      },
    );
  }

  Widget _buildUpcomingMeetings(String userId) {
    return StreamBuilder<List<Meeting>>(
      stream: _meetingService.getUpcomingMeetings(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final meetings = snapshot.data ?? [];

        if (meetings.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.event,
            title: 'No Upcoming Meetings',
            message: 'You have no scheduled meetings',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: meetings.length,
          itemBuilder: (context, index) {
            return _buildMeetingCard(meetings[index], userId);
          },
        );
      },
    );
  }

  Widget _buildPastMeetings(String userId) {
    return StreamBuilder<List<Meeting>>(
      stream: _meetingService.getPastMeetings(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final meetings = snapshot.data ?? [];

        if (meetings.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.history,
            title: 'No Past Meetings',
            message: 'You have no past meetings',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: meetings.length,
          itemBuilder: (context, index) {
            return _buildMeetingCard(meetings[index], userId);
          },
        );
      },
    );
  }

  Widget _buildMeetingCard(Meeting meeting, String userId) {
    final isOrganizer = meeting.requestedBy == 'mentor'
        ? meeting.mentorId == userId
        : meeting.studentId == userId;

    final otherPartyName =
        meeting.mentorId == userId ? meeting.studentName : meeting.mentorName;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (meeting.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Pending';
        break;
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Accepted';
        break;
      case 'declined':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Declined';
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusIcon = Icons.done_all;
        statusText = 'Completed';
        break;
      case 'cancelled':
        statusColor = Colors.grey;
        statusIcon = Icons.block;
        statusText = 'Cancelled';
        break;
      case 'postponed':
        statusColor = Colors.purple;
        statusIcon = Icons.update;
        statusText = 'Postponed';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = meeting.status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.meetingDetail,
            arguments: meeting.meetingId,
          );
        },
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                meeting.description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    isOrganizer
                        ? 'With: $otherPartyName'
                        : 'Requested by: $otherPartyName',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy - hh:mm a')
                        .format(meeting.dateTime),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    meeting.isOnline ? Icons.videocam : Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      meeting.isOnline
                          ? (meeting.location.isEmpty
                              ? 'Online Meeting'
                              : meeting.location)
                          : meeting.location,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${meeting.duration} min',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (meeting.isPending && !isOrganizer)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notification_important,
                              size: 16,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Awaiting your response',
                              style: TextStyle(
                                color: Colors.blue.shade700,
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
            ],
          ),
        ),
      ),
    );
  }
}

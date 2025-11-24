import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_page.dart';

class MySpacePage extends StatefulWidget {
  final String? role;
  final String? uid;

  const MySpacePage({super.key, this.role, this.uid});

  @override
  State<MySpacePage> createState() => _MySpacePageState();
}

class _MySpacePageState extends State<MySpacePage> {
  Future<String> _getUserRole(String uid) async {
    // If role is passed directly, use it
    if (widget.role != null && widget.role!.isNotEmpty) {
      return widget.role!;
    }

    // Otherwise fetch from Firestore
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      
      if (userDoc.exists && userDoc.data() != null) {
        return userDoc.data()?['role'] ?? 'attendee';
      }
      return 'attendee';
    } catch (e) {
      print('Error fetching user role: $e');
      return 'attendee';
    }
  }

  void _showEditAttendeesDialog(
      BuildContext context, String eventId, Map<String, dynamic> eventData) {
    final TextEditingController attendeesController = TextEditingController(
      text: eventData['attendeesCount']?.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Attendees Count'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event: ${eventData['title']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Fee: ₹${eventData['fee'] ?? 0}'),
            const SizedBox(height: 16),
            TextField(
              controller: attendeesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of Attendees',
                border: OutlineInputBorder(),
                hintText: 'Enter attendees count',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final count = int.tryParse(attendeesController.text) ?? 0;
              
              await FirebaseFirestore.instance
                  .collection('crowdr')
                  .doc('events')
                  .collection('events')
                  .doc(eventId)
                  .update({'attendeesCount': count});

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Attendees count updated successfully')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;

        if (user == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("My Space"),
              backgroundColor: Colors.deepPurple,
            ),
            body: const Center(child: Text("Please log in to view your events")),
          );
        }

        final currentUid = widget.uid ?? user.uid;

        return FutureBuilder<String>(
          future: _getUserRole(currentUid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final userRole = roleSnapshot.data ?? 'attendee';
            final isOrganizer = userRole.toLowerCase() == 'organizer';

            print('MySpace - User Role: $userRole, isOrganizer: $isOrganizer, UID: $currentUid');

            return Scaffold(
              appBar: AppBar(
                title: Text(isOrganizer ? "My Organized Events" : "My Attended Events"),
                backgroundColor: Colors.deepPurple,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                          role: userRole,
                          uid: currentUid,
                        ),
                      ),
                    );
                  },
                ),
              ),
              body: isOrganizer
                  ? _buildOrganizerView(currentUid)
                  : _buildAttendeeView(currentUid),
            );
          },
        );
      },
    );
  }

  // View for Organizers - shows events they created
  Widget _buildOrganizerView(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('crowdr')
          .doc('events')
          .collection('events')
          .where('organizerId', isEqualTo: uid)
          .snapshots(),
      builder: (context, eventSnapshot) {
        if (eventSnapshot.hasError) {
          return Center(
              child: Text("Something went wrong: ${eventSnapshot.error}"));
        }

        if (eventSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!eventSnapshot.hasData || eventSnapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text("You haven't organized any events yet"));
        }

        final events = eventSnapshot.data!.docs;

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final eventData = events[index].data() as Map<String, dynamic>;
            final eventId = events[index].id;
            final isPaidEvent = (eventData['fee'] ?? 0) > 0;

            return Card(
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: ListTile(
                title: Text(
                  eventData['title'] ?? 'Untitled Event',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(eventData['description'] ?? 'No description'),
                    const SizedBox(height: 6),
                    Text(
                      "Date: ${eventData['date'] ?? 'N/A'}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Attendees: ${eventData['attendeesCount'] ?? 0}",
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    if (isPaidEvent)
                      Text(
                        "Fee: ₹${eventData['fee']}",
                        style: const TextStyle(color: Colors.green),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPaidEvent)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditAttendeesDialog(context, eventId, eventData);
                        },
                        tooltip: 'Edit Attendees',
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('crowdr')
                            .doc('events')
                            .collection('events')
                            .doc(eventId)
                            .delete();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Event deleted successfully')),
                          );
                        }
                      },
                      tooltip: 'Delete Event',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // View for Attendees - shows events they're attending
  Widget _buildAttendeeView(String uid) {
    print('Building attendee view for UID: $uid');
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('crowdr')
          .doc('events')
          .collection('events')
          .snapshots(),
      builder: (context, eventSnapshot) {
        if (eventSnapshot.hasError) {
          return Center(
              child: Text("Something went wrong: ${eventSnapshot.error}"));
        }

        if (eventSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!eventSnapshot.hasData) {
          return const Center(child: Text("No events found"));
        }

        // Filter events where the user is an attendee
        final attendingEvents = eventSnapshot.data!.docs.where((doc) {
          final eventData = doc.data() as Map<String, dynamic>;
          final attendees = eventData['attendees'] as List<dynamic>? ?? [];
          
          print('Event: ${eventData['title']}, Attendees: $attendees, Checking UID: $uid');
          
          return attendees.contains(uid);
        }).toList();

        print('Found ${attendingEvents.length} events for attendee');

        if (attendingEvents.isEmpty) {
          return const Center(
              child: Text("You haven't registered for any events yet"));
        }

        return ListView.builder(
          itemCount: attendingEvents.length,
          itemBuilder: (context, index) {
            final eventData =
                attendingEvents[index].data() as Map<String, dynamic>;
            final eventId = attendingEvents[index].id;

            return Card(
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: ListTile(
                title: Text(
                  eventData['title'] ?? 'Untitled Event',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(eventData['description'] ?? 'No description'),
                    const SizedBox(height: 6),
                    Text(
                      "Date: ${eventData['date'] ?? 'N/A'}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Location: ${eventData['location'] ?? 'N/A'}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    if ((eventData['fee'] ?? 0) > 0)
                      Text(
                        "Fee: ₹${eventData['fee']}",
                        style: const TextStyle(color: Colors.green),
                      ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.exit_to_app, color: Colors.orange),
                  onPressed: () async {
                    // Remove user from attendees list
                    final attendees =
                        List<String>.from(eventData['attendees'] ?? []);
                    attendees.remove(uid);

                    await FirebaseFirestore.instance
                        .collection('crowdr')
                        .doc('events')
                        .collection('events')
                        .doc(eventId)
                        .update({
                      'attendees': attendees,
                      'attendeesCount': attendees.length,
                    });

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Successfully unregistered from event')),
                      );
                    }
                  },
                  tooltip: 'Unregister from Event',
                ),
              ),
            );
          },
        );
      },
    );
  }
}
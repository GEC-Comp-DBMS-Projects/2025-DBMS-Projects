import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final String eventId;
  final bool isOwner;

  const EventDetailsDialog({
    super.key,
    required this.eventData,
    required this.eventId,
    required this.isOwner,
  });

  Future<void> _applyForEvent(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in to apply.")),
        );
        return;
      }

      final eventRef = FirebaseFirestore.instance
          .collection('crowdr')
          .doc('events')
          .collection('events')
          .doc(eventId);

      final appliedUsersRef = eventRef.collection('appliedUsers').doc(user.uid);

      // 🔍 Check if already applied
      final appliedSnapshot = await appliedUsersRef.get();
      if (appliedSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You have already applied for this event.")),
        );
        return;
      }

      // ✅ Apply for the event
      await appliedUsersRef.set({
        'userId': user.uid,
        'appliedAt': FieldValue.serverTimestamp(),
      });

      // ✅ Increment attendee count
      await eventRef.update({
        'attendeesCount': FieldValue.increment(1),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully applied!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error applying: $e")),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  final fee = eventData['fee'] ?? 0.0;
  final contact = eventData['contactNumber'] ?? 'N/A';
  final attendees = eventData['attendeesCount'] ?? 0;

  return AlertDialog(
    title: Text(eventData['title'] ?? 'Event Details'),
    content: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("📝 Description: ${eventData['description'] ?? ''}"),
          const SizedBox(height: 6),
          Text("📍 Location: ${eventData['location'] ?? ''}"),
          const SizedBox(height: 6),
          Text("📅 Date: ${eventData['date'] ?? ''}"),
          const SizedBox(height: 6),
          Text("🕒 Time: ${eventData['time'] ?? ''}"),
          const SizedBox(height: 6),
          Text("🏷️ Category: ${eventData['category'] ?? ''}"),
          const SizedBox(height: 6),

          if (fee > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("💰 Fee: ₹$fee"),
                const SizedBox(height: 6),
                Text("📞 Organizer Contact: $contact"),
                const SizedBox(height: 10),
                Text(
                  "💡 Please contact the organizer to apply for this paid event.",
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 8),
          Text("👥 Attendees: $attendees"),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Close"),
      ),
      if (!isOwner && fee == 0)
        ElevatedButton(
          onPressed: () => _applyForEvent(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
          ),
          child: const Text("Apply"),
        ),
    ],
  );
}
}
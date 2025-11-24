// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:note_organiser/widgets/cards/topic_card.dart';

class PendingNotesPage extends StatefulWidget {
  final String classID, subjectID, userRole;
  const PendingNotesPage({
    super.key,
    required this.classID,
    required this.subjectID,
    required this.userRole,
  });

  @override
  State<PendingNotesPage> createState() => _PendingNotesPageState();
}

class _PendingNotesPageState extends State<PendingNotesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pending Notes')),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection(
                  'classes/${widget.classID}/subjects/${widget.subjectID}/topics',
                )
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var docs = snapshot.data!.docs;

          return ListView(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  if (docs[index].data()['status'] != 'pending') {
                    return SizedBox.shrink();
                  }
                  return TopicCard(
                    data: docs[index].data(),
                    topicID: docs[index].id,
                    dbPath:
                        'classes/${widget.classID}/subjects/${widget.subjectID}/topics',
                        isPending: true,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

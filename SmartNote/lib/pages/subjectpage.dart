import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:note_organiser/pages/Pendingnote.dart';
import 'package:note_organiser/pages/addtopicpage.dart';
import 'package:note_organiser/widgets/cards/topic_card.dart';
import 'package:note_organiser/widgets/Button.dart';

class SubjectPage extends StatefulWidget {
  final String classID, subjectID, userRole;
  final Map<String, dynamic> data;
  const SubjectPage({
    super.key,
    required this.classID,
    required this.data,
    required this.subjectID,
    required this.userRole,
  });

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  bool canAdd = false;

  @override
  void initState() {
    canAdd = widget.userRole == 'editor' || widget.userRole == 'admin';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image Header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                
                widget.data['name'] ?? 'Subject',
                style: const TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Color.fromARGB(137, 255, 255, 255),
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Subject Image
                  Image.asset(
                    widget.data['image'] ?? 'assets/book9.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback gradient if image not found
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.book,
                            size: 80,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(
                    'classes/${widget.classID}/subjects/${widget.subjectID}/topics',
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                var docs = snapshot.data!.docs;
                var acceptedDocs = docs.where(
                  (doc) => doc.data()['status'] == 'accepted'
                ).toList();

                if (acceptedDocs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: acceptedDocs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TopicCard(
                        data: acceptedDocs[index].data(),
                        topicID: acceptedDocs[index].id,
                        dbPath:
                            'classes/${widget.classID}/subjects/${widget.subjectID}/topics',
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Bottom padding for FAB
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AddGroupButton(
            buttonText: "ADD NOTE",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTopicPage(
                    canUpload: canAdd,
                    path:
                        "classes/${widget.classID}/subjects/${widget.subjectID}/topics",
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          if (widget.userRole == 'editor' || widget.userRole == 'admin')
            AddGroupButton(
              buttonText: "Pending Note",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PendingNotesPage(
                      classID: widget.classID,
                      subjectID: widget.subjectID,
                      userRole: widget.userRole,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.05),
            Theme.of(context).primaryColor.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.2),
                  Theme.of(context).primaryColor.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.note_outlined,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No Topics Yet",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            "Start adding topics and notes to this subject.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}
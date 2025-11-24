import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:note_organiser/app_theme.dart';
import 'package:note_organiser/pages/classpage%20pages/classpage.dart';

class CommunityPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const CommunityPage({super.key, required this.user});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Community Classes", style: theme.textTheme.titleMedium),
        centerTitle: true,
        elevation: theme.appBarTheme.elevation,
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
      ),
      body: Column(
        children: [
          // 🔹 Static image at the top of the page
          Image.asset(
            'assets/book9.jpg',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // 🔹 Expanded StreamBuilder for the class list
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('classes').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: theme.primaryColor),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No community classes available.",
                      style: theme.appBarTheme.titleTextStyle,
                    ),
                  );
                }

                var docs =
                    snapshot.data!.docs.where((doc) {
                      var classData = doc.data() as Map<String, dynamic>;
                      bool isPublic = classData['public'] ?? false;
                      bool isEnrolled =
                          widget.user['classes']?.contains(doc.id) ?? false;
                      return isPublic && !isEnrolled;
                    }).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No new community classes to join.",
                      style: theme.textTheme.titleMedium,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var classData = docs[index].data() as Map<String, dynamic>;
                    return CommunityCard(
                      name: classData['name'] ?? 'No Name',
                      des: classData['description'] ?? 'No Description',
                      data: classData,
                      classID: docs[index].id,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CommunityCard extends StatelessWidget {
  final String name, classID;
  final String des;
  final Map<String, dynamic> data;

  const CommunityCard({
    super.key,
    required this.name,
    required this.des,
    required this.data,
    required this.classID,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ClassPage(data: data, classID: classID);
            },
          ),
        );
      },
      child: Card(
        elevation: 4.0,
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: theme.cardColor,
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primaryColor.withOpacity(0.2),
                theme.primaryColor.withOpacity(0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8.0),
              Text(
                des,
                style: theme.textTheme.titleMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

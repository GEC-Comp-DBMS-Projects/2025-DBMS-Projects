import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Replace this import with your actual detailed edit page file
import '8editpage.dart'; // <-- point this to your detailed edit page

class EditPlayer extends StatefulWidget {
  const EditPlayer({super.key});

  @override
  State<EditPlayer> createState() => _EditPlayerState();
}

class _EditPlayerState extends State<EditPlayer> {
  String searchQuery = "";
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final double topSafeArea = MediaQuery.of(context).padding.top;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.25),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Player',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF179197), Color(0xFF307380), Color(0xFF015B63)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          image: DecorationImage(
            image: AssetImage("assets/crick.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.25),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: topSafeArea + kToolbarHeight + 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 4, 32, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.17),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.24)),
                    ),
                    child: TextField(
                      onChanged: (text) => setState(() => searchQuery = text),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search Player",
                        hintStyle: TextStyle(color: Colors.white70),
                        icon: Icon(Icons.search, color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('players')
                      .orderBy("name")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading players'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      );
                    }
                    final players = snapshot.data!.docs
                        .where(
                          (doc) =>
                              searchQuery.isEmpty ||
                              doc['name'].toLowerCase().contains(
                                searchQuery.toLowerCase(),
                              ),
                        )
                        .toList();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.09),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.33),
                                width: 2.5,
                              ),
                            ),
                            constraints: BoxConstraints(minHeight: 150),
                            child: ListView.builder(
                              itemCount: players.length,
                              itemBuilder: (ctx, i) {
                                final doc = players[i];
                                final String? photoUrl = doc['photoUrl'];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: 12,
                                    right: 12,
                                    top: i == 0 ? 3 : 14,
                                    bottom: 3,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 10,
                                        sigmaY: 10,
                                      ),
                                      child: Container(
                                        height: 60,
                                        color: Colors.white.withOpacity(0.23),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.white
                                                .withOpacity(0.19),
                                            radius: 23,
                                            backgroundImage:
                                                (photoUrl != null &&
                                                    photoUrl.isNotEmpty)
                                                ? NetworkImage(photoUrl)
                                                : null,
                                            child:
                                                (photoUrl == null ||
                                                    photoUrl.isEmpty)
                                                ? Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                    size: 28,
                                                  )
                                                : null,
                                          ),
                                          title: Text(
                                            doc['name'] ?? '',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          trailing: IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.tealAccent,
                                              size: 30,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditPlayerPage(
                                                        playerDocId: doc.id,
                                                        playerData:
                                                            doc.data()
                                                                as Map<
                                                                  String,
                                                                  dynamic
                                                                >,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example skeletal EditPlayerPage2 (_not_ complete, but shows how to receive arguments)
class EditPlayerPage2 extends StatelessWidget {
  final String playerDocId;
  final Map<String, dynamic> playerData;
  const EditPlayerPage2({
    super.key,
    required this.playerDocId,
    required this.playerData,
  });

  @override
  Widget build(BuildContext context) {
    // You can show or edit the player's data here
    return Scaffold(
      appBar: AppBar(title: Text("Edit Player")),
      body: Center(
        child: Text("Edit form for ${playerData['name']} (ID: $playerDocId)"),
      ),
    );
  }
}

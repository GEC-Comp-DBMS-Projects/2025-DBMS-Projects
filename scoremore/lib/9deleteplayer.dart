import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeletePlayersPage extends StatefulWidget {
  const DeletePlayersPage({super.key});

  @override
  State<DeletePlayersPage> createState() => _DeletePlayersPageState();
}

class _DeletePlayersPageState extends State<DeletePlayersPage> {
  String searchQuery = "";
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _confirmDelete(BuildContext context, String playerId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.75),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Remove Player?', style: TextStyle(color: Colors.white)),
        content: Text(
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('players')
          .doc(playerId)
          .delete();
    }
  }

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
          'Delete Player',
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
            // Space below status bar + AppBar
            SizedBox(height: topSafeArea + kToolbarHeight + 4),
            // Search Bar
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
            // Player List
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
                                              Icons.delete,
                                              color: Color.fromARGB(
                                                255,
                                                255,
                                                37,
                                                37,
                                              ),
                                              size: 28,
                                            ),
                                            onPressed: () =>
                                                _confirmDelete(context, doc.id),
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

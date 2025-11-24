import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '11selectplayers.dart';

class StartMatchPage extends StatefulWidget {
  const StartMatchPage({super.key});

  @override
  State<StartMatchPage> createState() => _StartMatchPageState();
}

class _StartMatchPageState extends State<StartMatchPage> {
  final team1Controller = TextEditingController();
  final team2Controller = TextEditingController();

  @override
  void dispose() {
    team1Controller.dispose();
    team2Controller.dispose();
    super.dispose();
  }

  Future<String> createMatchDocument(String team1, String team2) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final matchRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('match')
        .doc();

    final matchData = {
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'not_started',
      'oversPerInnings': 5.0, // float
      'toss': {
        'elected': '', // empty string initial
        'winnerTeam': '',
      }, // empty string initial // empty string initial
      'teamA': {'name': team1, 'players': []},
      'teamB': {'name': team2, 'players': []},
    };

    await matchRef.set(matchData);
    debugPrint("✅ Match created with ID: ${matchRef.id}");
    return matchRef.id;
  }

  Widget glassTextBox({
    required String hint,
    required TextEditingController controller,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(17.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.09),
            border: Border.all(color: Colors.tealAccent, width: 1),
            borderRadius: BorderRadius.circular(17),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget glassCard(String text, {VoidCallback? onTap}) {
    final card = Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(36.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
    return onTap != null ? GestureDetector(onTap: onTap, child: card) : card;
  }

  @override
  Widget build(BuildContext context) {
    final double topSafeArea = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'START MATCH',
          style: TextStyle(
            color: Colors.white,
            shadows: [Shadow(blurRadius: 20, color: Colors.black54)],
            fontWeight: FontWeight.bold,
            fontSize: 30,
            letterSpacing: 0.68,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
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
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            26,
            topSafeArea + kToolbarHeight + 10,
            26,
            24,
          ),
          children: [
            const Center(
              child: Text(
                'Home',
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            glassTextBox(hint: "Team 1", controller: team1Controller),
            const SizedBox(height: 50),
            const Center(
              child: Text(
                "V/S",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                  letterSpacing: 2.2,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'Away',
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            glassTextBox(hint: "Team 2", controller: team2Controller),
            const SizedBox(height: 70),
            glassCard(
              "Select Players",
              onTap: () async {
                final String team1 = team1Controller.text.trim();
                final String team2 = team2Controller.text.trim();

                if (team1.isEmpty || team2.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Please fill both team names before proceeding.",
                        style: TextStyle(
                          color: Color.fromARGB(255, 12, 239, 209),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 2.2,
                        ),
                      ),
                      backgroundColor: Color.fromARGB(100, 0, 0, 0),
                    ),
                  );
                  return;
                }

                try {
                  // Create match document
                  final matchId = await createMatchDocument(team1, team2);

                  // Navigate to player selection
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectPlayersPage(
                          team1: team1,
                          team2: team2,
                          matchId: matchId,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint("❌ Error: $e");
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

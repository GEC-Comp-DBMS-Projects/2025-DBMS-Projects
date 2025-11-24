import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '15scorerecord.dart'; // Corrected import name

class SelectStrikerPage extends StatefulWidget {
  final String battingTeamName;
  final String bowlingTeamName;
  final List<String> battingPlayers;
  final List<String> bowlingPlayers;
  final String matchId;
  final int target; // Target for the second innings

  const SelectStrikerPage({
    super.key,
    required this.battingTeamName,
    required this.bowlingTeamName,
    required this.battingPlayers,
    required this.bowlingPlayers,
    required this.matchId,
    required this.target,
  });

  @override
  State<SelectStrikerPage> createState() => _SelectStrikerPageState();
}

class _SelectStrikerPageState extends State<SelectStrikerPage> {
  String? striker;
  String? nonStriker;
  String? bowler;
  bool isSaving = false;

  Widget glassDropdown({
    required String hint,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(17.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            border: Border.all(color: Colors.tealAccent, width: 1.5),
            borderRadius: BorderRadius.circular(17),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hint,
                style: const TextStyle(color: Colors.tealAccent),
              ),
              dropdownColor: Colors.black,
              iconEnabledColor: Colors.tealAccent,
              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }

  Widget glassButton(String text, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: onTap != null
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(34.0),
                border: Border.all(
                  color: onTap != null
                      ? Colors.white.withOpacity(0.35)
                      : Colors.grey.withOpacity(0.2),
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
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: onTap != null ? Colors.white : Colors.white54,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveToFirestore() async {
    if (striker == null || nonStriker == null || bowler == null) return;

    setState(() => isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final matchRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('match')
          .doc(widget.matchId);

      // Batting array for the team batting second (Team2)
      final battingArray = [
        {
          "playerName": striker,
          "OutBy": "",
          "ballsPlayed": 0,
          "fours": 0,
          "runs scored": 0,
          "sixes": 0,
          "strikeRate": 0.0,
        },
        {
          "playerName": nonStriker,
          "OutBy": "",
          "ballsPlayed": 0,
          "fours": 0,
          "runs scored": 0,
          "sixes": 0,
          "strikeRate": 0.0,
        },
      ];

      // Bowling array for the team bowling second (Team1)
      final bowlingArray = [
        {
          "playerName": bowler,
          "Wides": 0,
          "noBalls": 0,
          "maidens": 0,
          "runsGiven": 0,
          "wickets": 0,
          "economy": 0.0,
          "overs": 0.0,
        },
      ];

      // Update the document with second innings data
      await matchRef.update({
        "finalSummary.Team2.batting": battingArray,
        "finalSummary.Team1.Bowling": bowlingArray,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FlutterScoreInputPage(
              battingTeam: widget.battingTeamName, // Team B is now batting
              bowlingTeam: widget.bowlingTeamName, // Team A is now bowling
              isSecondInnings: true, // This is key
              target: widget.target, // Pass the target
              matchId: widget.matchId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topSafeArea = MediaQuery.of(context).padding.top;

    List<String> nonStrikerOptions = List.from(widget.battingPlayers);
    if (striker != null) {
      nonStrikerOptions.remove(striker);
    }

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Second Innings',
          style: TextStyle(
            color: Colors.white,
            shadows: [Shadow(blurRadius: 20, color: Colors.black54)],
            fontWeight: FontWeight.bold,
            fontSize: 28,
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/crick.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            28,
            topSafeArea + kToolbarHeight + 12,
            28,
            29,
          ),
          children: [
            const SizedBox(height: 17),
            Text(
              '${widget.battingTeamName} striker',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 15),
            glassDropdown(
              hint: 'Select Striker',
              items: widget.battingPlayers,
              value: striker,
              onChanged: (val) {
                setState(() {
                  striker = val;
                  if (nonStriker == val) nonStriker = null;
                });
              },
            ),
            const SizedBox(height: 40),
            Text(
              '${widget.battingTeamName} non-striker',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 15),
            glassDropdown(
              hint: 'Select Non-Striker',
              items: nonStrikerOptions,
              value: nonStriker,
              onChanged: (val) => setState(() => nonStriker = val),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 40.0,
              ),
              child: Divider(
                color: Colors.white.withOpacity(0.4),
                thickness: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              '${widget.bowlingTeamName} opening bowler',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 15),
            glassDropdown(
              hint: 'Select Bowler',
              items: widget.bowlingPlayers,
              value: bowler,
              onChanged: (val) => setState(() => bowler = val),
            ),
            const SizedBox(height: 60),
            glassButton(
              isSaving ? "Starting..." : "Start Chase",
              onTap:
                  (striker != null &&
                      nonStriker != null &&
                      bowler != null &&
                      !isSaving)
                  ? saveToFirestore
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

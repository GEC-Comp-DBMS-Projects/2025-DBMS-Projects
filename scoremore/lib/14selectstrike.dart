import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '15scoreRecord.dart'; // Make sure FlutterScoreInputPage is imported from here or your file

class SelectStrikerPage extends StatefulWidget {
  final String battingTeamName;
  final String bowlingTeamName;
  final List<String> battingPlayers;
  final List<String> bowlingPlayers;
  final String matchId;
  final int? target;

  const SelectStrikerPage({
    super.key,
    required this.battingTeamName,
    required this.bowlingTeamName,
    required this.battingPlayers,
    required this.bowlingPlayers,
    required this.matchId,
    this.target,
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
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(34.0),
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
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
          .collection('match') // per your requirement, singular
          .doc(widget.matchId);

      final battingArray = [
        {
          "playerName": striker,
          "OutBy": "",
          "ballsPlayed": 0,
          "fours": 0,
          "runs scored": 0,
          "sixes": 0,
          "strikeRate": 0,
        },
        {
          "playerName": nonStriker,
          "OutBy": "",
          "ballsPlayed": 0,
          "fours": 0,
          "runs scored": 0,
          "sixes": 0,
          "strikeRate": 0,
        },
      ];

      final bowlingArray = [
        {
          "playerName": bowler,
          "Wides": 0,
          "noBalls": 0,
          "maidens": 0,
          "runsGiven": 0,
          "wickets": 0,
          "economy": 0,
        },
      ];

      await matchRef.set({
        "finalSummary": {
          "Winner": "",
          "mom": "",
          "Team1": {
            "TeamRuns": 0,
            "teamWickets": 0,
            "Overs": 0,
            "RunRate": 0,
            "Extras": {"wides": 0, "noballs": 0},
            "batting": battingArray,
            "Bowling": [],
            "fallofWickets": [
              {"runs": 0, "over": 0},
            ],
          },
          "Team2": {
            "TeamRuns": 0,
            "teamWickets": 0,
            "Overs": 0,
            "RunRate": 0,
            "Extras": {"wides": 0, "noballs": 0},
            "batting": [],
            "Bowling": bowlingArray,
            "fallofWickets": [
              {"runs": 0, "over": 0},
            ],
          },
        },
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FlutterScoreInputPage(
              battingTeam: widget.battingTeamName,
              bowlingTeam: widget.bowlingTeamName,
              isSecondInnings: false,
              target: null,
              matchId: widget.matchId,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving: $e")));
    } finally {
      setState(() => isSaving = false);
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
          'Select Striker & Bowler',
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
              isSaving ? "Saving..." : "Proceed",
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

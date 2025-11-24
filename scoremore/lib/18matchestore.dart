import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '4home.dart';
import '19scorecard.dart';
import '15scorerecord.dart';

class MatchListPage extends StatefulWidget {
  const MatchListPage({super.key});

  @override
  State<MatchListPage> createState() => _MatchListPageState();
}

class _MatchListPageState extends State<MatchListPage> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.25),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'scoremore',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(blurRadius: 20, color: Colors.black.withOpacity(0.8)),
            ],
            fontSize: 35,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/crick.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.25),
              BlendMode.darken,
            ),
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('match')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.tealAccent),
              );
            }
            final matches = snapshot.data!.docs;
            if (matches.isEmpty) {
              return Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: EdgeInsets.all(36),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sports_cricket,
                            color: Colors.white,
                            size: 60,
                          ),
                          SizedBox(height: 18),
                          Text(
                            "No Matches Found",
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                12,
                kToolbarHeight + MediaQuery.of(context).padding.top + 20,
                12,
                100,
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemCount: matches.length,
              itemBuilder: (context, idx) {
                final match = matches[idx];
                final data = match.data() as Map<String, dynamic>;

                // Parse date/time
                DateTime? createdDate;
                if (data['createdAt'] is Timestamp) {
                  createdDate = (data['createdAt'] as Timestamp).toDate();
                }
                String dayStr = createdDate != null
                    ? "${createdDate.day.toString().padLeft(2, '0')}-${createdDate.month.toString().padLeft(2, '0')}-${createdDate.year}"
                    : "Unknown Date";
                String timeStr = createdDate != null
                    ? "${createdDate.hour.toString().padLeft(2, '0')}:${createdDate.minute.toString().padLeft(2, '0')} ${createdDate.hour >= 12 ? 'PM' : 'AM'}"
                    : "";

                // Get team names
                String teamAName = data['teamA']?['name'] ?? 'Team A';
                String teamBName = data['teamB']?['name'] ?? 'Team B';

                // Determine batting order based on toss
                String? elected = data['toss']?['choice'];
                String? tossWinner = data['toss']?['winner'];

                String battingFirstTeam = teamAName;
                String battingSecondTeam = teamBName;

                if (tossWinner != null && elected != null) {
                  if (elected == 'Bat') {
                    battingFirstTeam = tossWinner;
                    battingSecondTeam = (tossWinner == teamAName)
                        ? teamBName
                        : teamAName;
                  } else {
                    battingFirstTeam = (tossWinner == teamAName)
                        ? teamBName
                        : teamAName;
                    battingSecondTeam = tossWinner;
                  }
                }

                // Get scores
                var team1Data = data['finalSummary']?['Team1'] ?? {};
                var team2Data = data['finalSummary']?['Team2'] ?? {};

                int team1Runs = team1Data['TeamRuns'] ?? 0;
                int team1Wickets = team1Data['teamWickets'] ?? 0;
                double team1Overs = (team1Data['Overs'] ?? 0).toDouble();

                int team2Runs = team2Data['TeamRuns'] ?? 0;
                int team2Wickets = team2Data['teamWickets'] ?? 0;
                double team2Overs = (team2Data['Overs'] ?? 0).toDouble();

                String formatOvers(double overs) {
                  int completeOvers = overs.floor();
                  int balls = ((overs - completeOvers) * 10).round();
                  return '$completeOvers.$balls';
                }

                String status = data['status'] ?? 'not-started';
                bool isFinished = status == 'finished';
                String statusText = data['statusText'] ?? '';

                return ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            child: Row(
                              children: [
                                Text(
                                  dayStr,
                                  style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  timeStr,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.sports_cricket,
                                      size: 18,
                                      color: Colors.tealAccent,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        battingFirstTeam,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$team1Runs - $team1Wickets',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      '  (${formatOvers(team1Overs)})',
                                      style: TextStyle(
                                        color: Colors.tealAccent,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.sports_cricket,
                                      size: 18,
                                      color: Colors.tealAccent,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        battingSecondTeam,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$team2Runs - $team2Wickets',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      '  (${formatOvers(team2Overs)})',
                                      style: TextStyle(
                                        color: Colors.tealAccent,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                if (statusText.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                      bottom: 6,
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        color: Colors.tealAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: isFinished
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () =>
                                              _showScorecard(context, match),
                                          child: const Text(
                                            'Scorecard',
                                            style: TextStyle(
                                              color: Colors.tealAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () =>
                                              _confirmDelete(context, match.id),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () =>
                                              _continueMatch(context, match),
                                          child: const Text(
                                            'Continue',
                                            style: TextStyle(
                                              color: Colors.tealAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () =>
                                              _endMatch(context, match),
                                          child: const Text(
                                            'End Match',
                                            style: TextStyle(
                                              color: Colors.tealAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.0,
                ),
              ),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _currentIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: const Color.fromARGB(255, 196, 198, 198),
              selectedLabelStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(fontSize: 14),
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 28),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sports_cricket, size: 28),
                  label: "Matches",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.live_tv, size: 28),
                  label: "Live Score",
                ),
              ],
              onTap: (int idx) {
                setState(() => _currentIndex = idx);
                if (idx == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ScoreMoreHome()),
                  );
                } else if (idx == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UnderConstructionPage()),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  void _continueMatch(BuildContext context, DocumentSnapshot match) async {
    final data = match.data() as Map<String, dynamic>;

    // Get match details
    String teamAName = data['teamA']?['name'] ?? 'Team A';
    String teamBName = data['teamB']?['name'] ?? 'Team B';
    List<String> teamAPlayers = List<String>.from(
      data['teamA']?['players'] ?? [],
    );
    List<String> teamBPlayers = List<String>.from(
      data['teamB']?['players'] ?? [],
    );

    // Check which innings is currently in progress
    var team1Data = data['finalSummary']?['Team1'] ?? {};
    var team2Data = data['finalSummary']?['Team2'] ?? {};

    double team1Overs = (team1Data['Overs'] ?? 0).toDouble();
    double team2Overs = (team2Data['Overs'] ?? 0).toDouble();

    int oversPerInnings = data['oversPerInnings'] ?? 20;

    // Determine batting order based on toss
    String? elected = data['toss']?['choice'];
    String? tossWinner = data['toss']?['winner'];

    String battingFirstTeam = teamAName;
    String bowlingFirstTeam = teamBName;
    List<String> battingFirstPlayers = teamAPlayers;
    List<String> bowlingFirstPlayers = teamBPlayers;

    if (tossWinner != null && elected != null) {
      if (elected == 'Bat') {
        battingFirstTeam = tossWinner;
        bowlingFirstTeam = (tossWinner == teamAName) ? teamBName : teamAName;
        battingFirstPlayers = (tossWinner == teamAName)
            ? teamAPlayers
            : teamBPlayers;
        bowlingFirstPlayers = (tossWinner == teamAName)
            ? teamBPlayers
            : teamAPlayers;
      } else {
        battingFirstTeam = (tossWinner == teamAName) ? teamBName : teamAName;
        bowlingFirstTeam = tossWinner;
        battingFirstPlayers = (tossWinner == teamAName)
            ? teamBPlayers
            : teamAPlayers;
        bowlingFirstPlayers = (tossWinner == teamAName)
            ? teamAPlayers
            : teamBPlayers;
      }
    }

    // FIXED: Check if first innings is complete
    bool isSecondInnings =
        team1Overs >= oversPerInnings ||
        (team1Data['teamWickets'] ?? 0) >= battingFirstPlayers.length - 1;

    if (!isSecondInnings) {
      // Continue first innings
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FlutterScoreInputPage(
            battingTeam: battingFirstTeam,
            bowlingTeam: bowlingFirstTeam,
            isSecondInnings: false,
            target: null,
            matchId: match.id,
          ),
        ),
      );
    } else {
      // Continue second innings
      int target = (team1Data['TeamRuns'] ?? 0) + 1;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FlutterScoreInputPage(
            battingTeam: bowlingFirstTeam,
            bowlingTeam: battingFirstTeam,
            isSecondInnings: true,
            target: target,
            matchId: match.id,
          ),
        ),
      );
    }
  }

  void _endMatch(BuildContext context, DocumentSnapshot match) async {
    await match.reference.update({'status': 'finished'});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Match ended')));
  }

  void _showScorecard(BuildContext context, DocumentSnapshot match) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScorecardPage(matchId: match.id)),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String matchId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Delete Match?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              onPressed: () => Navigator.pop(ctx, false),
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    );

    if (shouldDelete == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('match')
          .doc(matchId)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Match deleted')));
    }
  }
}

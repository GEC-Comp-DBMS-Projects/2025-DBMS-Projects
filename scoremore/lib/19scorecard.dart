import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScorecardPage extends StatelessWidget {
  final String matchId;

  const ScorecardPage({super.key, required this.matchId});

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
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'SCORECARD',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(blurRadius: 20, color: Colors.black.withOpacity(0.8)),
                ],
                fontSize: 28,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('match')
                  .doc(matchId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                final statusText = data?['statusText'] ?? '';
                return Text(
                  statusText,
                  style: TextStyle(color: Colors.tealAccent, fontSize: 12),
                );
              },
            ),
          ],
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
              Colors.black.withOpacity(0.35),
              BlendMode.darken,
            ),
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('match')
              .doc(matchId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(color: Colors.tealAccent),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final team1Data = data['finalSummary']?['Team1'] ?? {};
            final team2Data = data['finalSummary']?['Team2'] ?? {};

            final teamAName = data['teamA']?['name'] ?? 'Team A';
            final teamBName = data['teamB']?['name'] ?? 'Team B';

            final team1Batting =
                (team1Data['batting'] as List?)?.cast<Map<String, dynamic>>() ??
                [];
            final team1Bowling =
                (team2Data['Bowling'] as List?)?.cast<Map<String, dynamic>>() ??
                [];
            final team2Batting =
                (team2Data['batting'] as List?)?.cast<Map<String, dynamic>>() ??
                [];
            final team2Bowling =
                (team1Data['Bowling'] as List?)?.cast<Map<String, dynamic>>() ??
                [];

            final team1Extras = team1Data['Extras'] ?? {};
            final team2Extras = team2Data['Extras'] ?? {};

            final team1Overs = (team1Data['Overs'] ?? 0).toDouble();
            final team1Runs = team1Data['TeamRuns'] ?? 0;
            final team1Wickets = team1Data['teamWickets'] ?? 0;
            final team1RunRate =
                team1Data['RunRate']?.toStringAsFixed(1) ?? '0.0';

            final team2Runs = team2Data['TeamRuns'] ?? 0;
            final team2Wickets = team2Data['teamWickets'] ?? 0;
            final team2Overs = (team2Data['Overs'] ?? 0).toDouble();
            final team2RunRate =
                team2Data['RunRate']?.toStringAsFixed(1) ?? '0.0';

            // Format overs display (e.g., 3.2 = 3 overs 2 balls)
            String formatOvers(double overs) {
              int completeOvers = overs.floor();
              int balls = ((overs - completeOvers) * 10).round();
              return '$completeOvers.$balls';
            }

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  kToolbarHeight + MediaQuery.of(context).padding.top + 20,
                  12,
                  100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Team 1 Section
                    _buildTeamHeaderGlass(
                      teamAName.toUpperCase(),
                      team1Runs,
                      team1Wickets,
                      formatOvers(team1Overs),
                      team1RunRate,
                    ),
                    SizedBox(height: 8),
                    _buildBattingTableGlass(team1Batting),
                    SizedBox(height: 8),
                    _buildExtrasGlass(team1Extras),
                    SizedBox(height: 20),

                    // Team 2 Bowling
                    _buildBowlingTableGlass(team1Bowling),
                    SizedBox(height: 24),

                    // Team 2 Section
                    _buildTeamHeaderGlass(
                      teamBName.toUpperCase(),
                      team2Runs,
                      team2Wickets,
                      formatOvers(team2Overs),
                      team2RunRate,
                    ),
                    SizedBox(height: 8),
                    _buildBattingTableGlass(team2Batting),
                    SizedBox(height: 8),
                    _buildExtrasGlass(team2Extras),
                    SizedBox(height: 20),

                    // Team 1 Bowling
                    _buildBowlingTableGlass(team2Bowling),
                    SizedBox(height: 20),
                  ],
                ),
              ),
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
              currentIndex: 1,
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
                if (idx == 0) Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
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
          child: child,
        ),
      ),
    );
  }

  Widget _buildTeamHeaderGlass(
    String teamName,
    int runs,
    int wickets,
    String overs,
    String runRate,
  ) {
    return _buildGlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            teamName,
            style: TextStyle(
              color: Colors.tealAccent,
              fontSize: 20,
              shadows: [
                Shadow(blurRadius: 20, color: Colors.black.withOpacity(0.9)),
              ],
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                '$runs/$wickets ($overs)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  shadows: [
                    Shadow(
                      blurRadius: 20,
                      color: Colors.black.withOpacity(0.9),
                    ),
                  ],
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'RR: $runRate',
                style: TextStyle(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 20,
                      color: Colors.black.withOpacity(0.9),
                    ),
                  ],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExtrasGlass(Map<String, dynamic> extras) {
    final noBalls = extras['noballs'] ?? 0;
    final wides = extras['wides'] ?? 0;
    final totalExtras = noBalls + wides;

    return _buildGlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Extras: $totalExtras',
            style: TextStyle(
              color: Colors.white,
              shadows: [
                Shadow(blurRadius: 20, color: Colors.black.withOpacity(0.8)),
              ],
              fontSize: 15,
            ),
          ),
          Text(
            '${noBalls}NB, ${wides}wd',
            style: TextStyle(
              color: const Color.fromARGB(255, 255, 255, 255),
              shadows: [
                Shadow(blurRadius: 20, color: Colors.black.withOpacity(0.8)),
              ],
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattingTableGlass(List<Map<String, dynamic>> batting) {
    return _buildGlassCard(
      child: Table(
        border: TableBorder.all(color: Colors.white.withOpacity(0.2), width: 1),
        columnWidths: {
          0: FlexColumnWidth(2.5),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(0.8),
          4: FlexColumnWidth(0.8),
          5: FlexColumnWidth(1.2),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05)),
            children: [
              _buildTableHeader('Batter'),
              _buildTableHeader('Runs'),
              _buildTableHeader('Balls'),
              _buildTableHeader('4s'),
              _buildTableHeader('6s'),
              _buildTableHeader('SR'),
            ],
          ),
          ...batting.map((player) {
            final name = player['playerName'] ?? 'Unknown';
            final outBy = player['OutBy'] ?? '';
            final displayName = outBy.isEmpty
                ? '$name\nnot out'
                : '$name\n$outBy';
            return TableRow(
              children: [
                _buildTableCell(displayName),
                _buildTableCell((player['runs scored'] ?? 0).toString()),
                _buildTableCell((player['ballsPlayed'] ?? 0).toString()),
                _buildTableCell((player['fours'] ?? 0).toString()),
                _buildTableCell((player['sixes'] ?? 0).toString()),
                _buildTableCell(
                  player['strikeRate']?.toStringAsFixed(1) ?? '0.0',
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBowlingTableGlass(List<Map<String, dynamic>> bowling) {
    return _buildGlassCard(
      child: Table(
        border: TableBorder.all(color: Colors.white.withOpacity(0.2), width: 1),
        columnWidths: {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.2),
          4: FlexColumnWidth(1.2),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05)),
            children: [
              _buildTableHeader('Bowler'),
              _buildTableHeader('Overs'),
              _buildTableHeader('Runs'),
              _buildTableHeader('Wickets'),
              _buildTableHeader('Economy'),
            ],
          ),
          ...bowling.map((bowler) {
            return TableRow(
              children: [
                _buildTableCell(bowler['playerName'] ?? 'Unknown'),
                _buildTableCell(bowler['overs']?.toStringAsFixed(1) ?? '0.0'),
                _buildTableCell((bowler['runsGiven'] ?? 0).toString()),
                _buildTableCell((bowler['wickets'] ?? 0).toString()),
                _buildTableCell(bowler['economy']?.toStringAsFixed(1) ?? '0.0'),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.tealAccent,
          fontSize: 13,
          shadows: [
            Shadow(
              blurRadius: 20,
              color: const Color.fromARGB(255, 19, 220, 170).withOpacity(0.8),
            ),
          ],
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          shadows: [
            Shadow(blurRadius: 20, color: Colors.black.withOpacity(0.8)),
          ],
          fontSize: 13,
        ),
        textAlign: text.contains('\n') ? TextAlign.left : TextAlign.center,
      ),
    );
  }
}

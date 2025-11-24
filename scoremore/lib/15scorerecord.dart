import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '16secondinnings.dart';
import '19scorecard.dart';

class FlutterScoreInputPage extends StatefulWidget {
  final String battingTeam;
  final String bowlingTeam;
  final bool isSecondInnings;
  final int? target;
  final String matchId;

  const FlutterScoreInputPage({
    super.key,
    required this.battingTeam,
    required this.bowlingTeam,
    this.isSecondInnings = false,
    this.target,
    required this.matchId,
  });

  @override
  _FlutterScoreInputPageState createState() => _FlutterScoreInputPageState();
}

class _FlutterScoreInputPageState extends State<FlutterScoreInputPage> {
  int totalScore = 0;
  int wickets = 0;
  int overs = 0;
  int balls = 0;
  int maxOvers = 20;
  bool isInningsEnded = false;
  String result = '';

  // Extras
  int wides = 0;
  int noBalls = 0;

  // Current players
  String? striker;
  String? nonStriker;
  String? currentBowler;

  // Player stats maps
  Map<String, Map<String, dynamic>> batsmenStats = {};
  Map<String, Map<String, dynamic>> bowlerStats = {};

  // Ball by ball record
  List<String> currentOverBalls = [];
  List<Map<String, dynamic>> ballHistory = [];

  // Available players
  List<String> battingPlayers = [];
  List<String> bowlingPlayers = [];
  List<String> availableBatsmen = [];

  bool isLoading = true;

  static const List<List<String>> buttonGrid = [
    ["DOT", "3", "OUT", "BYE"],
    ["1", "4", "WIDE", "LEG\nBYE"],
    ["2", "6", "  NO\nBALL", "UNDO"],
  ];

  @override
  void initState() {
    super.initState();
    loadMatchData();
  }

  Future<void> loadMatchData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final matchDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('match')
          .doc(widget.matchId)
          .get();

      if (!matchDoc.exists) return;

      final data = matchDoc.data()!;
      final oversPerInningsValue = data['oversPerInnings'];
      setState(() {
        maxOvers = (oversPerInningsValue ?? 20).toInt();
      });

      // Determine which team is batting based on widget parameters
      String battingTeamKey = widget.isSecondInnings ? 'Team2' : 'Team1';
      String bowlingTeamKey = widget.isSecondInnings ? 'Team1' : 'Team2';

      final teamData = data['finalSummary']?[battingTeamKey];
      final bowlingTeamData = data['finalSummary']?[bowlingTeamKey];

      // Load existing scores
      totalScore = (teamData?['TeamRuns'] ?? 0).toInt();
      wickets = (teamData?['teamWickets'] ?? 0).toInt();

      // Calculate overs and balls
      double oversDecimal = (teamData?['Overs'] ?? 0).toDouble();
      overs = oversDecimal.floor();
      balls = ((oversDecimal - overs) * 10).round();

      // Load extras
      wides = (teamData?['Extras']?['wides'] ?? 0).toInt();
      noBalls = (teamData?['Extras']?['noballs'] ?? 0).toInt();

      // Load batting lineup
      final battingList = List<Map<String, dynamic>>.from(
        teamData?['batting'] ?? [],
      );

      // Get team players based on widget.battingTeam and widget.bowlingTeam names
      String teamAName = data['teamA']?['name'] ?? 'Team A';
      String teamBName = data['teamB']?['name'] ?? 'Team B';

      // Match the widget team names to actual database teams
      if (widget.battingTeam == teamAName) {
        battingPlayers = List<String>.from(data['teamA']?['players'] ?? []);
        bowlingPlayers = List<String>.from(data['teamB']?['players'] ?? []);
      } else {
        battingPlayers = List<String>.from(data['teamB']?['players'] ?? []);
        bowlingPlayers = List<String>.from(data['teamA']?['players'] ?? []);
      }

      // Initialize batsmen stats
      for (var bat in battingList) {
        String playerName = bat['playerName'];
        batsmenStats[playerName] = {
          'runs': (bat['runs scored'] ?? 0).toInt(),
          'balls': (bat['ballsPlayed'] ?? 0).toInt(),
          'fours': (bat['fours'] ?? 0).toInt(),
          'sixes': (bat['sixes'] ?? 0).toInt(),
          'strikeRate': (bat['strikeRate'] ?? 0).toDouble(),
          'outBy': bat['OutBy'] ?? '',
        };
      }

      // Find current striker and non-striker
      for (var bat in battingList) {
        if (bat['OutBy'] == '') {
          if (striker == null) {
            striker = bat['playerName'];
          } else if (nonStriker == null) {
            nonStriker = bat['playerName'];
            break;
          }
        }
      }

      // Load bowling stats
      final bowlingList = List<Map<String, dynamic>>.from(
        bowlingTeamData?['Bowling'] ?? [],
      );
      for (var bowl in bowlingList) {
        String playerName = bowl['playerName'];
        bowlerStats[playerName] = {
          'overs': (bowl['overs'] ?? 0.0).toDouble(),
          'runs': (bowl['runsGiven'] ?? 0).toInt(),
          'wickets': (bowl['wickets'] ?? 0).toInt(),
          'maidens': (bowl['maidens'] ?? 0).toInt(),
          'wides': (bowl['Wides'] ?? 0).toInt(),
          'noBalls': (bowl['noBalls'] ?? 0).toInt(),
          'economy': (bowl['economy'] ?? 0.0).toDouble(),
        };
      }

      // Find current bowler (last one in the list who bowled)
      if (bowlingList.isNotEmpty) {
        currentBowler = bowlingList.last['playerName'];
      }

      // Calculate available batsmen
      availableBatsmen = battingPlayers.where((player) {
        return !batsmenStats.containsKey(player) ||
            batsmenStats[player]!['outBy'] == '';
      }).toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading match data: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading match: $e')));
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void buttonTap(String label) {
    if (isInningsEnded) return;

    setState(() {
      bool isBallCounted = true;
      int runsScored = 0;
      bool isWicket = false;
      bool isExtra = false;
      String ballType = label;
      bool shouldSwapStrike = false;

      switch (label) {
        case 'DOT':
          runsScored = 0;
          currentOverBalls.add('•');
          break;
        case '1':
          runsScored = 1;
          currentOverBalls.add('1');
          shouldSwapStrike = true;
          break;
        case '2':
          runsScored = 2;
          currentOverBalls.add('2');
          break;
        case '3':
          runsScored = 3;
          currentOverBalls.add('3');
          shouldSwapStrike = true;
          break;
        case '4':
          runsScored = 4;
          batsmenStats[striker]!['fours'] =
              (batsmenStats[striker]!['fours'] as num).toInt() + 1;
          currentOverBalls.add('4');
          break;
        case '6':
          runsScored = 6;
          batsmenStats[striker]!['sixes'] =
              (batsmenStats[striker]!['sixes'] as num).toInt() + 1;
          currentOverBalls.add('6');
          break;
        case 'WIDE':
          runsScored = 1;
          wides++;
          isExtra = true;
          isBallCounted = false;
          currentOverBalls.add('Wd');
          bowlerStats[currentBowler]!['wides'] =
              (bowlerStats[currentBowler]!['wides'] as num).toInt() + 1;
          break;
        case 'NO BALL':
          runsScored = 1;
          noBalls++;
          isExtra = true;
          isBallCounted = false;
          currentOverBalls.add('Nb');
          bowlerStats[currentBowler]!['noBalls'] =
              (bowlerStats[currentBowler]!['noBalls'] as num).toInt() + 1;
          break;
        case 'OUT':
          isWicket = true;
          isBallCounted = true;
          currentOverBalls.add('W');
          handleWicket();
          break;
        case 'BYES':
        case 'LEG BYES':
          showRunsDialog(label);
          return;
        case 'UNDO':
          undoLastBall();
          return;
      }

      // Update scores
      totalScore += runsScored;

      if (!isExtra && !isWicket) {
        batsmenStats[striker]!['runs'] =
            (batsmenStats[striker]!['runs'] as num).toInt() + runsScored;
        batsmenStats[striker]!['balls'] =
            (batsmenStats[striker]!['balls'] as num).toInt() + 1;
        updateStrikeRate(striker!);
      }

      if (!isWicket) {
        bowlerStats[currentBowler]!['runs'] =
            (bowlerStats[currentBowler]!['runs'] as num).toInt() + runsScored;
      }

      // Record ball
      ballHistory.add({
        'type': ballType,
        'runs': runsScored,
        'striker': striker,
        'bowler': currentBowler,
        'isWicket': isWicket,
        'over': overs,
        'ball': balls,
      });

      // Swap strike if needed
      if (shouldSwapStrike) {
        swapStrike();
      }

      // Increment ball count (including wickets now)
      if (isBallCounted) {
        balls++;
        if (balls == 6) {
          completeOver();
        }
      }

      // Update bowler economy
      updateBowlerStats();

      // Check innings end
      checkInningsEnd();

      // Save to Firestore
      saveToFirestore();
    });
  }

  void swapStrike() {
    String? temp = striker;
    striker = nonStriker;
    nonStriker = temp;
  }

  void completeOver() {
    balls = 0;
    overs++;
    currentOverBalls.clear();

    // Auto swap striker
    swapStrike();

    // Give option to change bowler
    showChangeBowlerDialog();
  }

  void showChangeBowlerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          'End of Over',
          style: TextStyle(color: Colors.tealAccent),
        ),
        content: const Text(
          'Change bowler?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              double bowlerOvers = (bowlerStats[currentBowler]!['overs'] as num)
                  .toDouble();
              int maxOversPerBowler = (maxOvers / 5).ceil();
              if (bowlerOvers >= maxOversPerBowler) {
                showBowlerSelectionDialog();
              }
            },
            child: const Text('No', style: TextStyle(color: Colors.tealAccent)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showBowlerSelectionDialog();
            },
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.tealAccent),
            ),
          ),
        ],
      ),
    );
  }

  void handleWicket() {
    wickets++;
    showOutTypeDialog();
  }

  void showOutTypeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String outType = 'Bowled';
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                backgroundColor: Colors.black.withOpacity(0.85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: const Text(
                  'Wicket Type',
                  style: TextStyle(color: Colors.tealAccent),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$striker is out!',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.10),
                            border: Border.all(
                              color: Colors.tealAccent,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: outType,
                              dropdownColor: Colors.black87,
                              items:
                                  [
                                        'Bowled',
                                        'Caught',
                                        'LBW',
                                        'Run Out',
                                        'Stumped',
                                        'Hit Wicket',
                                      ]
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(
                                            type,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) =>
                                  setStateDialog(() => outType = val!),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        // FIXED: Mark batsman as out
                        batsmenStats[striker]!['outBy'] =
                            '$outType b $currentBowler';
                        if (outType != 'Run Out') {
                          bowlerStats[currentBowler]!['wickets'] =
                              (bowlerStats[currentBowler]!['wickets'] as num)
                                  .toInt() +
                              1;
                        }

                        // Check if all out (wickets == total players - 1)
                        if (wickets < battingPlayers.length - 1) {
                          showNewBatsmanDialog();
                        } else {
                          // FIXED: When last wicket falls, mark the non-striker as "not out"
                          // The striker is already marked as out above
                          if (nonStriker != null &&
                              batsmenStats.containsKey(nonStriker!)) {
                            if (batsmenStats[nonStriker!]!['outBy'] == '') {
                              batsmenStats[nonStriker!]!['outBy'] = 'not out';
                            }
                          }
                          checkInningsEnd();
                        }
                      });
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.tealAccent),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void showNewBatsmanDialog() {
    List<String> available = battingPlayers
        .where((player) {
          if (!batsmenStats.containsKey(player)) return true;
          if (batsmenStats[player]!['outBy'] == '') return false;
          return false;
        })
        .where((p) => p != striker && p != nonStriker)
        .toList();

    if (available.isEmpty) {
      checkInningsEnd();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String? newBatsman;
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                backgroundColor: Colors.black.withOpacity(0.85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: const Text(
                  'Select New Batsman',
                  style: TextStyle(color: Colors.tealAccent),
                ),
                content: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        border: Border.all(
                          color: Colors.tealAccent,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: const Text(
                            'Select Batsman',
                            style: TextStyle(color: Colors.white70),
                          ),
                          dropdownColor: Colors.black87,
                          value: newBatsman,
                          items: available
                              .map(
                                (player) => DropdownMenuItem(
                                  value: player,
                                  child: Text(
                                    player,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setStateDialog(() => newBatsman = val),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: newBatsman == null
                        ? null
                        : () {
                            setState(() {
                              striker = newBatsman;
                              if (!batsmenStats.containsKey(striker!)) {
                                batsmenStats[striker!] = {
                                  'runs': 0,
                                  'balls': 0,
                                  'fours': 0,
                                  'sixes': 0,
                                  'strikeRate': 0.0,
                                  'outBy': '',
                                };
                              }
                            });
                            Navigator.pop(context);
                          },
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.tealAccent),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void showBowlerSelectionDialog() {
    List<String> available = bowlingPlayers
        .where((p) => p != currentBowler)
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String? newBowler;
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                backgroundColor: Colors.black.withOpacity(0.85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: const Text(
                  'Select New Bowler',
                  style: TextStyle(color: Colors.tealAccent),
                ),
                content: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        border: Border.all(
                          color: Colors.tealAccent,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: const Text(
                            'Select Bowler',
                            style: TextStyle(color: Colors.white70),
                          ),
                          dropdownColor: Colors.black87,
                          value: newBowler,
                          items: available
                              .map(
                                (player) => DropdownMenuItem(
                                  value: player,
                                  child: Text(
                                    player,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setStateDialog(() => newBowler = val),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: newBowler == null
                        ? null
                        : () {
                            setState(() {
                              currentBowler = newBowler;
                              if (!bowlerStats.containsKey(currentBowler!)) {
                                bowlerStats[currentBowler!] = {
                                  'overs': 0.0,
                                  'runs': 0,
                                  'wickets': 0,
                                  'maidens': 0,
                                  'wides': 0,
                                  'noBalls': 0,
                                  'economy': 0.0,
                                };
                              }
                            });
                            Navigator.pop(context);
                          },
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.tealAccent),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void showRunsDialog(String type) {
    showDialog(
      context: context,
      builder: (context) {
        int runs = 1;
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            '$type Runs',
            style: const TextStyle(color: Colors.tealAccent),
          ),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [1, 2, 3, 4]
                        .map(
                          (r) => ElevatedButton(
                            onPressed: () {
                              setStateDialog(() {
                                runs = r;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.tealAccent,
                            ),
                            child: Text('$r'),
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  totalScore += runs;
                  balls++;
                  if (runs % 2 == 1) swapStrike();
                  if (balls == 6) completeOver();

                  currentOverBalls.add('$runs$type');
                  bowlerStats[currentBowler]!['runs'] =
                      (bowlerStats[currentBowler]!['runs'] as num).toInt() +
                      runs;
                  updateBowlerStats();
                  saveToFirestore();
                });
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.tealAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  void undoLastBall() {
    if (ballHistory.isEmpty) return;

    setState(() {
      var lastBall = ballHistory.removeLast();

      // Reverse score
      totalScore -= (lastBall['runs'] as num).toInt();

      // Reverse batsman stats if not extra
      if (lastBall['type'] != 'WIDE' && lastBall['type'] != 'NO BALL') {
        if (!lastBall['isWicket']) {
          batsmenStats[lastBall['striker']]!['runs'] =
              (batsmenStats[lastBall['striker']]!['runs'] as num).toInt() -
              (lastBall['runs'] as num).toInt();
          batsmenStats[lastBall['striker']]!['balls'] =
              (batsmenStats[lastBall['striker']]!['balls'] as num).toInt() - 1;
          updateStrikeRate(lastBall['striker']);
        }
      }

      // Reverse bowler stats
      bowlerStats[lastBall['bowler']]!['runs'] =
          (bowlerStats[lastBall['bowler']]!['runs'] as num).toInt() -
          (lastBall['runs'] as num).toInt();

      // Reverse ball count
      if (lastBall['type'] != 'WIDE' && lastBall['type'] != 'NO BALL') {
        if (balls == 0) {
          balls = 5;
          overs--;
        } else {
          balls--;
        }
      }

      if (currentOverBalls.isNotEmpty) {
        currentOverBalls.removeLast();
      }

      updateBowlerStats();
      saveToFirestore();
    });
  }

  void updateStrikeRate(String batsman) {
    int runs = (batsmenStats[batsman]!['runs'] as num).toInt();
    int ballsFaced = (batsmenStats[batsman]!['balls'] as num).toInt();

    if (ballsFaced > 0) {
      batsmenStats[batsman]!['strikeRate'] = double.parse(
        ((runs / ballsFaced) * 100).toStringAsFixed(2),
      );
    }
  }

  void updateBowlerStats() {
    if (currentBowler == null) return;

    double totalOvers = overs + (balls / 10.0);
    bowlerStats[currentBowler]!['overs'] = double.parse(
      totalOvers.toStringAsFixed(1),
    );

    if (totalOvers > 0) {
      int bowlerRuns = (bowlerStats[currentBowler]!['runs'] as num).toInt();
      double bowlerTotalOvers = (bowlerStats[currentBowler]!['overs'] as num)
          .toDouble();
      if (bowlerTotalOvers > 0) {
        double economy = bowlerRuns / bowlerTotalOvers;
        bowlerStats[currentBowler]!['economy'] = double.parse(
          economy.toStringAsFixed(2),
        );
      }
    }
  }

  void checkInningsEnd() {
    // Check if all out (wickets == total players - 1)
    if (wickets >= battingPlayers.length - 1 || overs >= maxOvers) {
      setState(() {
        isInningsEnded = true;
      });

      // FIXED: Mark remaining not-out batsman as "not out"
      if (wickets >= battingPlayers.length - 1) {
        for (var entry in batsmenStats.entries) {
          if (entry.value['outBy'] == '') {
            entry.value['outBy'] = 'not out';
          }
        }
      }

      showInningsEndDialog();
    }

    // FIXED: Check if target chase failed in second innings
    if (widget.isSecondInnings &&
        widget.target != null &&
        (wickets >= battingPlayers.length - 1 || overs >= maxOvers)) {
      if (totalScore < widget.target!) {
        setState(() {
          isInningsEnded = true;
        });
        showMatchLostDialog();
        return;
      }
    }

    // Check if target is chased
    if (widget.target != null && totalScore >= widget.target!) {
      setState(() {
        isInningsEnded = true;
      });
      showMatchWonDialog();
    }
  }

  void showInningsEndDialog() {
    // FIXED: If second innings and failed to chase, show different dialog
    if (widget.isSecondInnings &&
        widget.target != null &&
        totalScore < widget.target!) {
      showMatchLostDialog();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: Colors.black.withOpacity(0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              widget.isSecondInnings ? 'Match Ended' : 'Innings Ended',
              style: const TextStyle(color: Colors.tealAccent),
            ),
            content: Text(
              'Final Score: $totalScore/$wickets in $overs.$balls overs',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (widget.isSecondInnings) {
                    final uid = FirebaseAuth.instance.currentUser!.uid;
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('match')
                        .doc(widget.matchId)
                        .update({'status': 'finished'});

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScorecardPage(matchId: widget.matchId),
                      ),
                    );
                  } else {
                    // End of first innings, navigate to second innings
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectStrikerPage(
                          battingTeamName: widget.bowlingTeam,
                          bowlingTeamName: widget.battingTeam,
                          battingPlayers: bowlingPlayers,
                          bowlingPlayers: battingPlayers,
                          matchId: widget.matchId,
                          target: totalScore + 1,
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.tealAccent),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // FIXED: New dialog for when Team2 fails to chase
  void showMatchLostDialog() {
    int runsDifference = widget.target! - totalScore - 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: Colors.black.withOpacity(0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Match Ended',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.bowlingTeam} won the match',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'by $runsDifference runs!',
                  style: const TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // Set status to 'finished'
                  final uid = FirebaseAuth.instance.currentUser!.uid;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('match')
                      .doc(widget.matchId)
                      .update({'status': 'finished'});

                  // Navigate to scorecard
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScorecardPage(matchId: widget.matchId),
                    ),
                  );
                },
                child: const Text(
                  'View Scorecard',
                  style: TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showMatchWonDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: Colors.black.withOpacity(0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Match Ended',
              style: TextStyle(
                color: Colors.tealAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.battingTeam} won the match',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'by ${battingPlayers.length - 1 - wickets} wickets!',
                  style: const TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final uid = FirebaseAuth.instance.currentUser!.uid;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('match')
                      .doc(widget.matchId)
                      .update({'status': 'finished'});

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScorecardPage(matchId: widget.matchId),
                    ),
                  );
                },
                child: const Text(
                  'View Scorecard',
                  style: TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> saveToFirestore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final matchRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('match')
          .doc(widget.matchId);

      String battingTeamKey = widget.isSecondInnings ? 'Team2' : 'Team1';
      String bowlingTeamKey = widget.isSecondInnings ? 'Team1' : 'Team2';

      // Prepare batting array
      List<Map<String, dynamic>> battingArray = batsmenStats.entries.map((
        entry,
      ) {
        return {
          "playerName": entry.key,
          "OutBy": entry.value['outBy'],
          "ballsPlayed": entry.value['balls'],
          "fours": entry.value['fours'],
          "runs scored": entry.value['runs'],
          "sixes": entry.value['sixes'],
          "strikeRate": entry.value['strikeRate'],
        };
      }).toList();

      // Prepare bowling array
      List<Map<String, dynamic>> bowlingArray = bowlerStats.entries.map((
        entry,
      ) {
        return {
          "playerName": entry.key,
          "Wides": entry.value['wides'],
          "noBalls": entry.value['noBalls'],
          "maidens": entry.value['maidens'],
          "overs": entry.value['overs'],
          "runsGiven": entry.value['runs'],
          "wickets": entry.value['wickets'],
          "economy": entry.value['economy'],
        };
      }).toList();

      double totalOversDecimal = overs + (balls / 10.0);
      double runRate = totalOversDecimal > 0
          ? totalScore / totalOversDecimal
          : 0;

      await matchRef.update({
        "finalSummary.$battingTeamKey.TeamRuns": totalScore,
        "finalSummary.$battingTeamKey.teamWickets": wickets,
        "finalSummary.$battingTeamKey.Overs": double.parse(
          totalOversDecimal.toStringAsFixed(1),
        ),
        "finalSummary.$battingTeamKey.RunRate": double.parse(
          runRate.toStringAsFixed(2),
        ),
        "finalSummary.$battingTeamKey.Extras.wides": wides,
        "finalSummary.$battingTeamKey.Extras.noballs": noBalls,
        "finalSummary.$battingTeamKey.batting": battingArray,
        "finalSummary.$bowlingTeamKey.Bowling": bowlingArray,
      });
    } catch (e) {
      print('Error saving to Firestore: $e');
    }
  }

  Widget glassContainer({
    required Widget child,
    double blur = 10,
    double opacity = 0.13,
    Color border = Colors.transparent,
    double borderRadius = 18,
    double borderWidth = 1.6,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            border: Border.all(color: border, width: borderWidth),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
      );
    }

    double totalOversDecimal = overs + (balls / 10.0);
    double crr = totalOversDecimal > 0 ? totalScore / totalOversDecimal : 0;
    double rrr = 0;

    if (widget.target != null && totalOversDecimal < maxOvers) {
      double remainingBalls = ((maxOvers * 6) - ((overs * 6) + balls))
          .toDouble();
      if (remainingBalls > 0) {
        double remainingOvers = remainingBalls / 6.0;
        rrr = (widget.target! - totalScore) / remainingOvers;
      }
    }

    Color teal = Colors.tealAccent;

    // Get current batsmen for display
    List<MapEntry<String, Map<String, dynamic>>> currentBatsmen = [];
    if (striker != null && batsmenStats.containsKey(striker)) {
      currentBatsmen.add(MapEntry(striker!, batsmenStats[striker]!));
    }
    if (nonStriker != null && batsmenStats.containsKey(nonStriker)) {
      currentBatsmen.add(MapEntry(nonStriker!, batsmenStats[nonStriker]!));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
        elevation: 0,
        centerTitle: true,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/crick.png',
              fit: BoxFit.cover,
              color: const Color.fromARGB(89, 0, 0, 0),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Score Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 1,
                    vertical: 0,
                  ),
                  child: glassContainer(
                    border: const Color.fromARGB(90, 255, 255, 255),
                    borderRadius: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 7,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${widget.battingTeam}:",
                                style: TextStyle(
                                  color: teal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "CRR:",
                                style: TextStyle(color: teal, fontSize: 17),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                crr.toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              if (widget.target != null) ...[
                                const SizedBox(width: 15),
                                Text(
                                  "RRR:",
                                  style: TextStyle(color: teal, fontSize: 17),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  rrr.toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(width: 13),
                                Text(
                                  "Target:",
                                  style: TextStyle(color: teal, fontSize: 17),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  widget.target.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "$totalScore/$wickets",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 38,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "${overs}.${balls} ($maxOvers)",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          if (widget.target != null)
                            Text(
                              "${widget.battingTeam} need ${widget.target! - totalScore} from ${(maxOvers * 6) - (overs * 6 + balls)} balls",
                              style: TextStyle(
                                color: teal,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),
                ),

                // Batting Table
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 1,
                    vertical: 0,
                  ),
                  child: glassContainer(
                    border: const Color.fromARGB(90, 255, 255, 255),
                    opacity: 0.18,
                    borderRadius: 5,
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                        4: FlexColumnWidth(1),
                        5: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                          ),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                "Batter",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                "Runs",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                "Balls",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                "4s",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                "6s",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                "SR",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        ...currentBatsmen.map((entry) {
                          String displayName = entry.key;
                          if (entry.key == striker) displayName += '*';

                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  "${entry.value['runs']}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  "${entry.value['balls']}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  "${entry.value['fours']}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  "${entry.value['sixes']}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  "${(entry.value['strikeRate'] as num).toStringAsFixed(1)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),

                // Bowler Table
                if (currentBowler != null &&
                    bowlerStats.containsKey(currentBowler))
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 1,
                      vertical: 0,
                    ),
                    child: glassContainer(
                      border: const Color.fromARGB(90, 255, 255, 255),
                      opacity: 0.18,
                      borderRadius: 5,
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                          4: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.23),
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  "Bowler",
                                  style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  "Overs",
                                  style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  "Runs",
                                  style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  "Wickets",
                                  style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  "Economy",
                                  style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  currentBowler!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  "${bowlerStats[currentBowler]!['overs']}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  "${bowlerStats[currentBowler]!['runs']}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  "${bowlerStats[currentBowler]!['wickets']}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  "${(bowlerStats[currentBowler]!['economy'] as num).toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                if (currentOverBalls.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 1,
                    ),
                    child: glassContainer(
                      border: const Color.fromARGB(90, 255, 255, 255),
                      borderRadius: 15,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'THIS OVER',
                              style: TextStyle(
                                color: Colors.tealAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: currentOverBalls.length,
                              itemBuilder: (context, index) {
                                String ball = currentOverBalls[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: ClipOval(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 12,
                                        sigmaY: 12,
                                      ),
                                      child: Container(
                                        width: 50,
                                        height: 25,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.12),
                                          border: Border.all(
                                            color: Colors.tealAccent,
                                            width: 2,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          ball,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                // Keypad
                Expanded(
                  child: glassContainer(
                    border: const Color.fromARGB(
                      171,
                      255,
                      255,
                      255,
                    ).withOpacity(0.7),
                    borderRadius: 22,
                    opacity: 0.09,
                    blur: 15,
                    child: GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      padding: const EdgeInsets.all(10),
                      children: buttonGrid.expand((row) => row).map((label) {
                        return GestureDetector(
                          onTap: () => buttonTap(label),
                          child: glassContainer(
                            blur: 12,
                            opacity: 0.10,
                            border: Colors.white.withOpacity(0.6),
                            borderRadius: 12,
                            borderWidth: 1.4,
                            child: Center(
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Scorecard Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ScorecardPage(matchId: widget.matchId),
                            ),
                          );
                        },
                        child: Container(
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.tealAccent.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.tealAccent.withOpacity(0.2),
                                blurRadius: 15,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.article_outlined,
                                color: Colors.tealAccent,
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'SCORECARD',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.tealAccent,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

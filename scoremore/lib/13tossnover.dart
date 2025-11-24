import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '14selectstrike.dart';

class TossAndOver extends StatefulWidget {
  final String team1;
  final String team2;
  final String matchId;

  const TossAndOver({
    super.key,
    required this.team1,
    required this.team2,
    required this.matchId,
  });

  @override
  State<TossAndOver> createState() => _TossAndOverState();
}

class _TossAndOverState extends State<TossAndOver>
    with SingleTickerProviderStateMixin {
  final oversController = TextEditingController();
  String? tossWinner;
  String? tossChoice;
  bool manualTossSelected = true;

  final List<String> tossChoices = ['Bat', 'Field'];
  final List<String> coinSides = ['Heads', 'Tails'];
  String? headsTeam;
  String? tailsTeam;
  bool isAnimating = false;
  bool showHeads = true;
  String? tossResultText;
  late AnimationController _controller;
  late Animation<double> _animation;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation =
        Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          )
          ..addListener(() => setState(() {}))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              isAnimating = false;
              decideToss();
            }
          });
  }

  @override
  void dispose() {
    oversController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void startToss() {
    if (headsTeam == null || tailsTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Select both Heads and Tails teams!",
            style: TextStyle(
              color: Colors.tealAccent,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 2.2,
            ),
          ),
        ),
      );
      return;
    }
    isAnimating = true;
    tossWinner = null;
    tossChoice = null;
    tossResultText = null;
    _controller.forward(from: 0);
    setState(() {});
  }

  void decideToss() {
    bool result = random.nextBool();
    showHeads = result;
    tossWinner = result ? headsTeam : tailsTeam;
    tossResultText = "${tossWinner!} won the toss";
    tossChoice = null; // Let user choose Bat/Field after toss result
    setState(() {});
  }

  Widget glassTextBox({
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
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
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
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

  Widget glassButton({required String text, VoidCallback? onTap}) {
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

  Widget glassDropdown({
    required String hint,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.09),
            border: Border.all(color: Colors.tealAccent, width: 1),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Center(
                child: Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              dropdownColor: const Color(0xFF101616),
              style: const TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              borderRadius: BorderRadius.circular(15),
              iconEnabledColor: Colors.tealAccent,
              isExpanded: true,
              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(
                        e,
                        style: TextStyle(
                          color: e == value ? Colors.tealAccent : Colors.white,
                          fontWeight: FontWeight.bold,
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

  Future<void> proceedToNext() async {
    final overs = double.tryParse(oversController.text);
    if (overs == null || overs <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number of overs')),
      );
      return;
    }
    if (tossWinner == null || tossChoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the toss selections')),
      );
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final matchRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('match')
          .doc(widget.matchId);

      final snapshot = await matchRef.get();
      if (!snapshot.exists) {
        throw Exception("Match not found");
      }

      Map<String, dynamic> tossMap = {
        "winner": tossWinner,
        "choice": tossChoice,
        "tossMode": manualTossSelected ? 'Manual' : 'Digital',
      };

      await matchRef.update({'oversPerInnings': overs, 'toss': tossMap});

      final data = snapshot.data()!;
      final teamA = data['teamA'];
      final teamB = data['teamB'];

      late String battingTeamName;
      late String bowlingTeamName;
      late List<dynamic> battingPlayers;
      late List<dynamic> bowlingPlayers;

      if (tossWinner == teamA['name']) {
        if (tossChoice == 'Bat') {
          battingTeamName = teamA['name'];
          bowlingTeamName = teamB['name'];
          battingPlayers = List<String>.from(teamA['players']);
          bowlingPlayers = List<String>.from(teamB['players']);
        } else {
          battingTeamName = teamB['name'];
          bowlingTeamName = teamA['name'];
          battingPlayers = List<String>.from(teamB['players']);
          bowlingPlayers = List<String>.from(teamA['players']);
        }
      } else {
        if (tossChoice == 'Bat') {
          battingTeamName = teamB['name'];
          bowlingTeamName = teamA['name'];
          battingPlayers = List<String>.from(teamB['players']);
          bowlingPlayers = List<String>.from(teamA['players']);
        } else {
          battingTeamName = teamA['name'];
          bowlingTeamName = teamB['name'];
          battingPlayers = List<String>.from(teamA['players']);
          bowlingPlayers = List<String>.from(teamB['players']);
        }
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectStrikerPage(
            battingTeamName: battingTeamName,
            bowlingTeamName: bowlingTeamName,
            battingPlayers: battingPlayers.cast<String>(),
            bowlingPlayers: bowlingPlayers.cast<String>(),
            matchId: widget.matchId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error proceeding: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topSafeArea = MediaQuery.of(context).padding.top;
    final teams = [widget.team1, widget.team2];

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Start Match',
          style: TextStyle(
            color: Colors.white,
            shadows: [Shadow(blurRadius: 20, color: Colors.black54)],
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/crick.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
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
                'Overs Per Innings',
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            glassTextBox(
              hint: "Enter overs",
              controller: oversController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Toss Mode',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(
                      'Manual Toss',
                      style: TextStyle(
                        color: manualTossSelected
                            ? Colors.tealAccent
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: true,
                    groupValue: manualTossSelected,
                    selected: manualTossSelected,
                    activeColor: Colors.tealAccent,
                    onChanged: (val) {
                      setState(() {
                        manualTossSelected = val!;
                        tossWinner = null;
                        headsTeam = null;
                        tailsTeam = null;
                        tossChoice = null;
                        tossResultText = null;
                        isAnimating = false;
                        showHeads = true;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(
                      'Digital Toss',
                      style: TextStyle(
                        color: !manualTossSelected
                            ? Colors.tealAccent
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: false,
                    groupValue: manualTossSelected,
                    selected: !manualTossSelected,
                    activeColor: Colors.tealAccent,
                    onChanged: (val) {
                      setState(() {
                        manualTossSelected = val!;
                        tossWinner = null;
                        headsTeam = null;
                        tailsTeam = null;
                        tossChoice = null;
                        tossResultText = null;
                        isAnimating = false;
                        showHeads = true;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            if (manualTossSelected) ...[
              //const Center(
              //  child: Text(
              //    'Toss won by',
              //     style: TextStyle(
              //       fontSize: 22,
              //       color: Colors.tealAccent,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
              DropdownButton<String>(
                value: tossWinner,
                hint: Text(
                  'Select Team',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
                isExpanded: true,
                dropdownColor: const Color(0xFF101616),
                style: const TextStyle(fontWeight: FontWeight.bold),
                iconEnabledColor: Colors.tealAccent,
                items: teams
                    .map(
                      (t) => DropdownMenuItem<String>(
                        value: t,
                        child: Text(
                          t,
                          style: TextStyle(
                            color: t == tossWinner
                                ? Colors.tealAccent
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => tossWinner = val),
              ),
              if (tossWinner != null)
                DropdownButton<String>(
                  value: tossChoice,
                  hint: const Text(
                    'Bat/Field',
                    style: TextStyle(color: Colors.tealAccent),
                  ),
                  isExpanded: true,
                  dropdownColor: const Color(0xFF101616),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  iconEnabledColor: Colors.tealAccent,
                  items: tossChoices
                      .map(
                        (choice) => DropdownMenuItem<String>(
                          value: choice,
                          child: Text(
                            choice,
                            style: TextStyle(
                              color: choice == tossChoice
                                  ? Colors.tealAccent
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => tossChoice = val),
                ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Heads',
                          style: TextStyle(
                            color: Colors.tealAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        glassDropdown(
                          hint: "Select",
                          items: teams,
                          value: headsTeam,
                          onChanged: (val) {
                            setState(() {
                              headsTeam = val;
                              if (tailsTeam == val) tailsTeam = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Tails',
                          style: TextStyle(
                            color: Colors.tealAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        glassDropdown(
                          hint: "Select",
                          items: teams.where((t) => t != headsTeam).toList(),
                          value: tailsTeam,
                          onChanged: (val) => setState(() => tailsTeam = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (_, __) {
                    double turns = _animation.value * 6;
                    double angle = turns * pi;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateY(angle),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white.withOpacity(0.10),
                        child: ClipOval(
                          child: Image.asset(
                            showHeads ? "assets/HEADS.png" : "assets/TAILS.png",
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              glassButton(
                text: isAnimating ? "Flipping..." : "Toss Coin",
                onTap: isAnimating ? null : startToss,
              ),
              if (tossResultText != null) ...[
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    tossResultText!,
                    style: const TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Center(
                //   child: Text(
                //     'Toss won by',
                //     style: TextStyle(
                //       fontSize: 22,
                //       color: Colors.tealAccent,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                //),
                // Not a dropdown, just show winner as text
                // Center(
                //   child: Text(
                //     tossWinner ?? "",
                //     style: TextStyle(
                //       fontSize: 20,
                //       color: Colors.white,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                DropdownButton<String>(
                  value: tossChoice,
                  hint: const Text(
                    'Bat/Field',
                    style: TextStyle(color: Colors.tealAccent),
                  ),
                  isExpanded: true,
                  dropdownColor: const Color(0xFF101616),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  iconEnabledColor: Colors.tealAccent,
                  items: tossChoices
                      .map(
                        (choice) => DropdownMenuItem<String>(
                          value: choice,
                          child: Text(
                            choice,
                            style: TextStyle(
                              color: choice == tossChoice
                                  ? Colors.tealAccent
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => tossChoice = val),
                ),
              ],
            ],
            const SizedBox(height: 30),
            glassButton(text: "Proceed", onTap: proceedToNext),
          ],
        ),
      ),
    );
  }
}
